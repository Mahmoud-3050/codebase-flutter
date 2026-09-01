import 'dart:convert';

import 'package:language/language.dart';
import 'package:language/testing.dart';
import 'package:language/src/data/asset_language_loader.dart';
import 'package:language/src/data/language_yaml_loader.dart';
import 'package:language/src/domain/language_config.dart';
import 'package:language/src/domain/language_file_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final source = assets[key];
    if (source == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}

class FakeLanguageStorage implements LanguageStorage {
  String? languageCode;

  @override
  Future<String?> getLanguageCode() async => languageCode;

  @override
  Future<void> saveLanguageCode(String code) async {
    languageCode = code;
  }
}

class RecordingLanguageChangeListener implements LanguageChangeListener {
  final List<LanguageModel> calls = [];

  @override
  void onLanguageChanged(LanguageModel language) {
    calls.add(language);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testConfig = LanguageConfig(
    jsonAssetPaths: ['assets/lang/en.json', 'assets/lang/ar.json'],
  );

  setUp(() {
    resetLanguage();
  });

  tearDown(() {
    resetLanguage();
  });

  group('LanguageFileParser Tests', () {
    test('Valid file names parse correctly into LanguageModel', () {
      final arLang = LanguageFileParser.parse('ar.json');
      expect(arLang.code, equals('ar'));
      expect(arLang.countryCode, isNull);
      expect(arLang.fullCode, equals('ar'));
      expect(arLang.locale, equals(const Locale('ar')));

      final arEgLang = LanguageFileParser.parse('ar_EG.json');
      expect(arEgLang.code, equals('ar'));
      expect(arEgLang.countryCode, equals('EG'));
      expect(arEgLang.fullCode, equals('ar_EG'));
      expect(arEgLang.locale, equals(const Locale('ar', 'EG')));

      final enUsLang = LanguageFileParser.parse('en_US.json');
      expect(enUsLang.code, equals('en'));
      expect(enUsLang.countryCode, equals('US'));
      expect(enUsLang.fullCode, equals('en_US'));
    });

    test('isValidLanguageCode matches JSON file stems', () {
      expect(LanguageFileParser.isValidLanguageCode('ar'), isTrue);
      expect(LanguageFileParser.isValidLanguageCode('ar_EG'), isTrue);
      expect(LanguageFileParser.isValidLanguageCode('AR'), isFalse);
      expect(LanguageFileParser.isValidLanguageCode('ar-EG'), isFalse);
      expect(LanguageFileParser.isValidLanguageCode('ar_eg'), isFalse);
    });

    test('isValidFileName returns correct results', () {
      expect(LanguageFileParser.isValidFileName('ar.json'), isTrue);
      expect(LanguageFileParser.isValidFileName('en_US.json'), isTrue);
      expect(LanguageFileParser.isValidFileName('123.json'), isFalse);
      expect(LanguageFileParser.isValidFileName('ar-EG.json'), isFalse);
    });

    test('Invalid file names throw InvalidLanguageFileNameException', () {
      expect(
        () => LanguageFileParser.parse('123.json'),
        throwsA(isA<InvalidLanguageFileNameException>()),
      );

      expect(
        () => LanguageFileParser.parse('ar_eg.json'),
        throwsA(isA<InvalidLanguageFileNameException>()),
      );

      expect(
        () => LanguageFileParser.parse('ar-EG.json'),
        throwsA(isA<InvalidLanguageFileNameException>()),
      );

      expect(
        () => LanguageFileParser.parse('invalid_name.json'),
        throwsA(isA<InvalidLanguageFileNameException>()),
      );
    });

    test('fileNameFromPath extracts the file name from an asset path', () {
      expect(
        LanguageFileParser.fileNameFromPath('assets/lang/ar.json'),
        equals('ar.json'),
      );
      expect(LanguageFileParser.fileNameFromPath('en.json'), equals('en.json'));
    });
  });

  group('LanguageYamlLoader Tests', () {
    test('parses files and default_language from YAML', () {
      const yaml = '''
default_language: ar
files:
  - assets/lang/en.json
  - assets/lang/ar.json
''';
      final config = LanguageYamlLoader.parse(yaml);

      expect(config.jsonAssetPaths, [
        'assets/lang/en.json',
        'assets/lang/ar.json',
      ]);
      expect(config.defaultLanguage, equals(LanguageModel.ar));
      expect(config.assetPathFor(LanguageModel.en), 'assets/lang/en.json');
      expect(config.assetPathFor(LanguageModel.ar), 'assets/lang/ar.json');
      expect(config.declaredLanguages, [LanguageModel.en, LanguageModel.ar]);
    });

    test('applyConfig uses YAML default_language and files list', () {
      const yaml = '''
default_language: ar
files:
  - assets/lang/en.json
  - assets/lang/ar.json
''';
      Language.instance.applyConfig(LanguageYamlLoader.parse(yaml));

      expect(Language.instance.supportedLanguages, [
        LanguageModel.en,
        LanguageModel.ar,
      ]);
      expect(Language.instance.defaultLanguage, equals(LanguageModel.ar));
      expect(Language.instance.current, equals(LanguageModel.ar));
    });

    test('parses country-variant files and default_language full code', () {
      const yaml = '''
default_language: ar_SA
files:
  - assets/lang/en.json
  - assets/lang/ar_EG.json
  - assets/lang/ar_SA.json
''';
      final config = LanguageYamlLoader.parse(yaml);
      expect(config.defaultLanguage?.fullCode, equals('ar_SA'));
      expect(config.declaredLanguages.map((language) => language.fullCode), [
        'en',
        'ar_EG',
        'ar_SA',
      ]);
    });

    test('default_language ar selects first Arabic country file', () {
      const yaml = '''
default_language: ar
files:
  - assets/lang/en.json
  - assets/lang/ar_EG.json
  - assets/lang/ar_SA.json
''';
      final config = LanguageYamlLoader.parse(yaml);
      expect(config.defaultLanguage?.fullCode, equals('ar_EG'));
    });

    test('throws when files list is missing', () {
      expect(
        () => LanguageYamlLoader.parse('default_language: ar'),
        throwsA(isA<InvalidLanguageYamlException>()),
      );
    });

    test('throws when default_language is not in files', () {
      const yaml = '''
default_language: fr
files:
  - assets/lang/en.json
''';
      expect(
        () => LanguageYamlLoader.parse(yaml),
        throwsA(isA<InvalidLanguageYamlException>()),
      );
    });

    test('throws on invalid json file name in files', () {
      const yaml = '''
files:
  - assets/lang/invalid.json
''';
      expect(
        () => LanguageYamlLoader.parse(yaml),
        throwsA(isA<InvalidLanguageFileNameException>()),
      );
    });
  });

  group('AssetLanguageLoader Tests', () {
    test('languagesFromConfig uses declared YAML paths', () {
      final languages = AssetLanguageLoader.languagesFromConfig(testConfig);
      expect(languages, contains(LanguageModel.en));
      expect(languages, contains(LanguageModel.ar));
    });
  });

  group('Language Orchestrator Lookup Tests', () {
    test('fromCode parses code correctly', () {
      Language.instance.applyConfig(testConfig);

      expect(Language.instance.fromCode('en').code, equals('en'));
      expect(Language.instance.fromCode('ar').code, equals('ar'));
    });

    test('fromCode returns defaultLanguage for null/empty/unknown', () {
      expect(
        Language.instance.fromCode(null),
        equals(Language.instance.defaultLanguage),
      );
      expect(
        Language.instance.fromCode(''),
        equals(Language.instance.defaultLanguage),
      );
      expect(
        Language.instance.fromCode('zz'),
        equals(Language.instance.defaultLanguage),
      );
    });

    test('fromLocale parses Locale correctly', () {
      Language.instance.applyConfig(testConfig);

      expect(
        Language.instance.fromLocale(const Locale('en')).code,
        equals('en'),
      );
      expect(
        Language.instance.fromLocale(const Locale('ar', 'EG')).code,
        equals('ar'),
      );
    });
  });

  group('Language Orchestrator State Tests', () {
    test('Single source of truth accessors work correctly', () {
      Language.instance.applyConfig(
        const LanguageConfig(
          jsonAssetPaths: ['assets/lang/ar.json'],
          defaultLanguage: LanguageModel.ar,
        ),
      );

      expect(Language.instance.current, equals(LanguageModel.ar));
      expect(Language.instance.currentLocale, equals(const Locale('ar')));
      expect(Language.instance.currentCode, equals('ar'));
      expect(Language.instance.isArabic, isTrue);
      expect(Language.instance.isEnglish, isFalse);

      Language.instance.applyConfig(
        const LanguageConfig(
          jsonAssetPaths: ['assets/lang/en.json'],
          defaultLanguage: LanguageModel.en,
        ),
      );

      expect(Language.instance.current, equals(LanguageModel.en));
      expect(Language.instance.currentLocale, equals(const Locale('en')));
      expect(Language.instance.currentCode, equals('en'));
      expect(Language.instance.isArabic, isFalse);
      expect(Language.instance.isEnglish, isTrue);
    });

    test('defaultLanguage is used as fallback throughout', () {
      Language.instance.applyConfig(
        const LanguageConfig(
          jsonAssetPaths: ['assets/lang/ar.json'],
          defaultLanguage: LanguageModel.ar,
        ),
      );

      expect(Language.instance.fromCode(null), equals(LanguageModel.ar));
      expect(Language.instance.fromCode(''), equals(LanguageModel.ar));
      expect(Language.instance.fromCode('zz'), equals(LanguageModel.ar));
    });
  });

  group('Language.init Tests', () {
    test('changeLanguage throws before init', () {
      expect(
        () => Language.instance.changeLanguage(LanguageModel.ar),
        throwsA(isA<LanguageNotInitializedException>()),
      );
      expect(Language.instance.isInitialized, isFalse);
    });

    test('init uses config default language when storage is empty', () async {
      const arConfig = LanguageConfig(
        jsonAssetPaths: ['assets/lang/en.json', 'assets/lang/ar.json'],
        defaultLanguage: LanguageModel.ar,
      );
      final storage = FakeLanguageStorage();
      final listener = RecordingLanguageChangeListener();

      await Language.instance.init(
        config: arConfig,
        storage: storage,
        listener: listener,
      );

      expect(Language.instance.isInitialized, isTrue);
      expect(Language.instance.defaultLanguage, equals(LanguageModel.ar));
      expect(Language.instance.current, equals(LanguageModel.ar));
      expect(listener.calls, [LanguageModel.ar]);
    });

    test('init restores language from storage', () async {
      final storage = FakeLanguageStorage()..languageCode = 'ar';
      const enDefaultConfig = LanguageConfig(
        jsonAssetPaths: ['assets/lang/en.json', 'assets/lang/ar.json'],
        defaultLanguage: LanguageModel.en,
      );

      await Language.instance.init(config: enDefaultConfig, storage: storage);

      expect(Language.instance.current, equals(LanguageModel.ar));
    });

    test('init restores ar_EG when that file is declared', () async {
      const arEg = LanguageModel(
        code: 'ar',
        nativeName: 'العربية (EG)',
        countryCode: 'EG',
      );
      final storage = FakeLanguageStorage()..languageCode = 'ar_EG';
      const countryConfig = LanguageConfig(
        jsonAssetPaths: ['assets/lang/en.json', 'assets/lang/ar_EG.json'],
        defaultLanguage: LanguageModel.en,
      );

      await Language.instance.init(config: countryConfig, storage: storage);

      expect(Language.instance.current, equals(arEg));
      expect(Language.instance.currentCode, equals('ar_EG'));
    });

    test('init ignores stored ar when only country files exist', () async {
      const arEg = LanguageModel(
        code: 'ar',
        nativeName: 'العربية (EG)',
        countryCode: 'EG',
      );
      final storage = FakeLanguageStorage()..languageCode = 'ar';
      const countryConfig = LanguageConfig(
        jsonAssetPaths: ['assets/lang/en.json', 'assets/lang/ar_EG.json'],
        defaultLanguage: arEg,
      );

      await Language.instance.init(config: countryConfig, storage: storage);

      expect(Language.instance.current, equals(arEg));
    });

    test('init ignores stored ar_EG when only ar.json exists', () async {
      final storage = FakeLanguageStorage()..languageCode = 'ar_EG';
      const languageOnlyConfig = LanguageConfig(
        jsonAssetPaths: ['assets/lang/en.json', 'assets/lang/ar.json'],
        defaultLanguage: LanguageModel.en,
      );

      await Language.instance.init(
        config: languageOnlyConfig,
        storage: storage,
      );

      expect(Language.instance.current, equals(LanguageModel.en));
    });

    test(
      'init ignores stored codes that do not match file-name grammar',
      () async {
        const enDefaultConfig = LanguageConfig(
          jsonAssetPaths: ['assets/lang/en.json', 'assets/lang/ar.json'],
          defaultLanguage: LanguageModel.en,
        );

        for (final invalidCode in ['AR', 'ar-EG', 'ar_eg']) {
          resetLanguage();
          final storage = FakeLanguageStorage()..languageCode = invalidCode;
          await Language.instance.init(
            config: enDefaultConfig,
            storage: storage,
          );
          expect(
            Language.instance.current,
            equals(LanguageModel.en),
            reason: 'rejected stored code "$invalidCode"',
          );
        }
      },
    );
  });

  group('Language changeLanguage Tests', () {
    test('changeLanguage updates state, storage, and listener', () async {
      final storage = FakeLanguageStorage();
      final listener = RecordingLanguageChangeListener();

      await Language.instance.init(
        config: testConfig,
        storage: storage,
        listener: listener,
      );
      listener.calls.clear();

      await Language.instance.changeLanguage(LanguageModel.ar);

      expect(Language.instance.current, equals(LanguageModel.ar));
      expect(Language.instance.isArabic, isTrue);
      expect(storage.languageCode, equals('ar'));
      expect(listener.calls, [LanguageModel.ar]);
    });

    test('changeLanguage is a no-op when language is unchanged', () async {
      final storage = FakeLanguageStorage();
      final listener = RecordingLanguageChangeListener();

      await Language.instance.init(
        config: testConfig,
        storage: storage,
        listener: listener,
      );
      listener.calls.clear();

      await Language.instance.changeLanguage(Language.instance.current);

      expect(listener.calls, isEmpty);
      expect(storage.languageCode, isNull);
    });

    test('changeLanguage rejects languages not listed in YAML files', () async {
      await Language.instance.init(config: testConfig);

      const french = LanguageModel(code: 'fr', nativeName: 'Français');
      expect(
        () => Language.instance.changeLanguage(french),
        throwsA(isA<UnsupportedLanguageException>()),
      );
      expect(Language.instance.current, equals(LanguageModel.en));
    });

    test('changeLanguage throws before init', () {
      expect(
        () => Language.instance.changeLanguage(LanguageModel.ar),
        throwsA(isA<LanguageNotInitializedException>()),
      );
    });
  });

  group('LanguageModel Tests', () {
    test('fullCode includes country when present', () {
      const withCountry = LanguageModel(
        code: 'ar',
        nativeName: 'العربية',
        countryCode: 'EG',
      );
      expect(withCountry.fullCode, equals('ar_EG'));
      expect(withCountry.locale, equals(const Locale('ar', 'EG')));
    });

    test('fullCode omits empty countryCode', () {
      const emptyCountry = LanguageModel(
        code: 'en',
        nativeName: 'English',
        countryCode: '',
      );
      expect(emptyCountry.fullCode, equals('en'));
    });

    test('equality ignores nativeName', () {
      const named = LanguageModel(code: 'ar', nativeName: 'Arabic');
      expect(named, equals(LanguageModel.ar));
      expect(named.hashCode, equals(LanguageModel.ar.hashCode));
    });

    test('isArabic and isEnglish are case-insensitive on code', () {
      const arUpper = LanguageModel(code: 'AR', nativeName: 'Arabic');
      const enUpper = LanguageModel(code: 'EN', nativeName: 'English');
      expect(arUpper.isArabic, isTrue);
      expect(enUpper.isEnglish, isTrue);
    });
  });

  group('LanguageConfig Tests', () {
    test('assetPathFor prefers fullCode then language code', () {
      const config = LanguageConfig(
        jsonAssetPaths: ['assets/lang/ar.json', 'assets/lang/ar_EG.json'],
      );
      const arEg = LanguageModel(
        code: 'ar',
        nativeName: 'العربية',
        countryCode: 'EG',
      );

      expect(config.assetPathFor(arEg), equals('assets/lang/ar_EG.json'));
      expect(
        config.assetPathFor(LanguageModel.ar),
        equals('assets/lang/ar.json'),
      );
      expect(config.assetPathFor(LanguageModel.en), isNull);
    });

    test('declaredLanguages keeps country variants of the same language', () {
      const config = LanguageConfig(
        jsonAssetPaths: ['assets/lang/ar_EG.json', 'assets/lang/ar_SA.json'],
      );
      expect(config.declaredLanguages, [
        const LanguageModel(
          code: 'ar',
          nativeName: 'العربية (EG)',
          countryCode: 'EG',
        ),
        const LanguageModel(
          code: 'ar',
          nativeName: 'العربية (SA)',
          countryCode: 'SA',
        ),
      ]);
    });

    test('declaredLanguages skips duplicates and empty file names', () {
      const config = LanguageConfig(
        jsonAssetPaths: [
          'assets/lang/en.json',
          'assets/lang/en.json',
          'assets/lang/',
        ],
      );
      expect(config.declaredLanguages, [LanguageModel.en]);
    });

    test('applyConfig without defaultLanguage uses first files entry', () {
      Language.instance.applyConfig(testConfig);

      expect(Language.instance.supportedLanguages, [
        LanguageModel.en,
        LanguageModel.ar,
      ]);
      expect(Language.instance.defaultLanguage, equals(LanguageModel.en));
      expect(Language.instance.current, equals(LanguageModel.en));
      expect(Language.instance.config, equals(testConfig));
    });
  });

  group('LanguageYamlLoader extra Tests', () {
    test('omitted default_language uses first files entry', () {
      const yaml = '''
files:
  - assets/lang/en.json
  - assets/lang/ar.json
''';
      final config = LanguageYamlLoader.parse(yaml);
      expect(config.defaultLanguage, equals(LanguageModel.en));
    });

    test('load reads YAML from a custom asset bundle', () async {
      final bundle = FakeAssetBundle({
        'language.yaml': '''
default_language: ar
files:
  - assets/lang/en.json
  - assets/lang/ar.json
''',
      });

      final config = await LanguageYamlLoader.load(bundle: bundle);
      expect(config.defaultLanguage, equals(LanguageModel.ar));
      expect(config.jsonAssetPaths, [
        'assets/lang/en.json',
        'assets/lang/ar.json',
      ]);
    });

    test('load throws MissingLanguageYamlException when asset is absent', () {
      expect(
        () => LanguageYamlLoader.load(bundle: FakeAssetBundle({})),
        throwsA(isA<MissingLanguageYamlException>()),
      );
    });

    test('throws when document is not a YAML map', () {
      expect(
        () => LanguageYamlLoader.parse('- just a list'),
        throwsA(isA<InvalidLanguageYamlException>()),
      );
    });

    test('throws when files list is empty', () {
      expect(
        () => LanguageYamlLoader.parse('files: []'),
        throwsA(isA<InvalidLanguageYamlException>()),
      );
    });

    test('throws when a files entry is not a json path', () {
      const yaml = '''
files:
  - assets/lang/en.txt
''';
      expect(
        () => LanguageYamlLoader.parse(yaml),
        throwsA(isA<InvalidLanguageYamlException>()),
      );
    });
  });

  group('LanguageFileParser extra Tests', () {
    test('parses 3-letter language codes and unknown native names', () {
      final fil = LanguageFileParser.parse('fil.json');
      expect(fil.code, equals('fil'));
      expect(fil.nativeName, equals('fil'));
    });

    test('fileNameFromPath normalizes backslashes and trims', () {
      expect(
        LanguageFileParser.fileNameFromPath(r' assets\lang\ar.json '),
        equals('ar.json'),
      );
    });

    test('nativeName includes country suffix', () {
      expect(
        LanguageFileParser.parse('ar_EG.json').nativeName,
        equals('العربية (EG)'),
      );
      expect(
        LanguageFileParser.parse('en_US.json').nativeName,
        equals('English (US)'),
      );
    });
  });

  group('InMemoryLanguageStorage Tests', () {
    test('get returns null until save', () async {
      final storage = InMemoryLanguageStorage();
      expect(await storage.getLanguageCode(), isNull);

      await storage.saveLanguageCode('ar');
      expect(await storage.getLanguageCode(), equals('ar'));
    });
  });

  group('Exception toString Tests', () {
    test('exceptions include identifying details', () {
      expect(
        const InvalidLanguageFileNameException('bad.json').toString(),
        contains('bad.json'),
      );
      expect(
        const MissingLanguageYamlException('language.yaml').toString(),
        contains('language.yaml'),
      );
      expect(
        const InvalidLanguageYamlException('broken').toString(),
        contains('broken'),
      );
      expect(
        const LanguageNotInitializedException().toString(),
        contains('Language.instance.init()'),
      );
    });
  });

  group('LanguageLocalizationsSetup Tests', () {
    test('supportedLocales maps from Language.instance.supportedLanguages', () {
      Language.instance.applyConfig(
        const LanguageConfig(
          jsonAssetPaths: ['assets/lang/ar.json', 'assets/lang/en.json'],
        ),
      );
      expect(LanguageLocalizationsSetup.supportedLocales, [
        const Locale('ar'),
        const Locale('en'),
      ]);
    });

    test('localeResolutionCallback returns current when locale is missing', () {
      Language.instance.applyConfig(
        const LanguageConfig(
          jsonAssetPaths: ['assets/lang/ar.json'],
          defaultLanguage: LanguageModel.ar,
        ),
      );
      expect(
        LanguageLocalizationsSetup.localeResolutionCallback(null, const [
          Locale('en'),
          Locale('ar'),
        ]),
        equals(const Locale('ar')),
      );
    });

    test(
      'localeResolutionCallback prefers exact country then language-only',
      () {
        const supported = [
          Locale('ar'),
          Locale('ar', 'EG'),
          Locale('ar', 'SA'),
          Locale('en'),
        ];
        expect(
          LanguageLocalizationsSetup.localeResolutionCallback(
            const Locale('ar', 'SA'),
            supported,
          ),
          equals(const Locale('ar', 'SA')),
        );
        expect(
          LanguageLocalizationsSetup.localeResolutionCallback(
            const Locale('ar', 'EG'),
            supported,
          ),
          equals(const Locale('ar', 'EG')),
        );
        expect(
          LanguageLocalizationsSetup.localeResolutionCallback(
            const Locale('en', 'US'),
            supported,
          ),
          equals(const Locale('en')),
        );
      },
    );

    test('localeResolutionCallback falls back to defaultLanguage', () {
      Language.instance.applyConfig(
        const LanguageConfig(
          jsonAssetPaths: ['assets/lang/en.json', 'assets/lang/ar.json'],
          defaultLanguage: LanguageModel.ar,
        ),
      );
      expect(
        LanguageLocalizationsSetup.localeResolutionCallback(
          const Locale('fr'),
          const [Locale('en')],
        ),
        equals(const Locale('ar')),
      );
    });
  });

  group('LanguageLocalizationsDelegate Tests', () {
    const delegate = LanguageLocalizations.delegate;

    test('isSupported matches language and full codes', () {
      Language.instance.applyConfig(testConfig);

      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('ar')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });

    test('shouldReload is always false', () {
      expect(delegate.shouldReload(delegate), isFalse);
    });
  });

  group('LanguageLocalizations Tests', () {
    test('text and .tr return the key when translations are missing', () async {
      Language.instance.applyConfig(testConfig);
      await LanguageLocalizations(
        const Locale('en'),
      ).load(bundle: FakeAssetBundle({}));

      expect(LanguageLocalizations.instance.text('welcome'), equals('welcome'));
      expect('welcome'.tr, equals('welcome'));
    });

    test('load reads JSON from the bundle path declared in config', () async {
      Language.instance.applyConfig(testConfig);
      final bundle = FakeAssetBundle({
        'assets/lang/en.json': '{"welcome":"Hello","count":1}',
      });

      await LanguageLocalizations(const Locale('en')).load(bundle: bundle);

      expect('welcome'.tr, equals('Hello'));
      expect('count'.tr, equals('1'));
    });

    test('load with no activeConfig leaves an empty dictionary', () async {
      await LanguageLocalizations(const Locale('en')).load();
      expect('any_key'.tr, equals('any_key'));
    });

    test('trParams replaces named placeholders in the template', () async {
      Language.instance.applyConfig(testConfig);
      await LanguageLocalizations(const Locale('en')).load(
        bundle: FakeAssetBundle({
          'assets/lang/en.json':
              '{"welcome":"welcome {username}","counts_from":"{current} counts from {total}"}',
        }),
      );

      expect(
        'welcome'.trParams({'username': 'Ahmed'}),
        equals('welcome Ahmed'),
      );
      expect(
        'counts_from'.trParams({'current': '10', 'total': '20'}),
        equals('10 counts from 20'),
      );
    });

    test(
      'trParams leaves unmatched placeholders and ignores extra params',
      () async {
        Language.instance.applyConfig(testConfig);
        await LanguageLocalizations(const Locale('en')).load(
          bundle: FakeAssetBundle({
            'assets/lang/en.json': '{"welcome":"welcome {username}"}',
          }),
        );

        expect(
          'welcome'.trParams({'other': 'x'}),
          equals('welcome {username}'),
        );
        expect(
          'welcome'.trParams({'username': 'Ahmed', 'extra': 'ignored'}),
          equals('welcome Ahmed'),
        );
      },
    );

    test('trParams on a missing key still returns the key', () async {
      Language.instance.applyConfig(testConfig);
      await LanguageLocalizations(
        const Locale('en'),
      ).load(bundle: FakeAssetBundle({}));

      expect(
        'missing_key'.trParams({'username': 'Ahmed'}),
        equals('missing_key'),
      );
    });

    test('.tr returns the raw template without substituting params', () async {
      Language.instance.applyConfig(testConfig);
      await LanguageLocalizations(const Locale('en')).load(
        bundle: FakeAssetBundle({
          'assets/lang/en.json': '{"welcome":"welcome {username}"}',
        }),
      );

      expect('welcome'.tr, equals('welcome {username}'));
    });
  });

  group('AssetLanguageLoader extra Tests', () {
    test('loadJsonTranslation returns null for missing assets', () async {
      final result = await AssetLanguageLoader.loadJsonTranslation(
        'assets/lang/missing.json',
        bundle: FakeAssetBundle({}),
      );
      expect(result, isNull);
    });

    test('languagesFromConfig is empty when paths are empty', () {
      final result = AssetLanguageLoader.languagesFromConfig(
        const LanguageConfig(jsonAssetPaths: []),
      );
      expect(result, isEmpty);
    });
  });

  group('Language.init extra Tests', () {
    test('init without storage uses InMemoryLanguageStorage', () async {
      await Language.instance.init(config: testConfig);

      expect(Language.instance.isInitialized, isTrue);
      await Language.instance.changeLanguage(LanguageModel.ar);
      expect(Language.instance.current, equals(LanguageModel.ar));
    });

    test('init throws when YAML asset is missing', () {
      expect(
        () => Language.instance.init(bundle: FakeAssetBundle({})),
        throwsA(isA<MissingLanguageYamlException>()),
      );
    });

    test('reset clears initialization', () async {
      await Language.instance.init(config: testConfig);
      expect(Language.instance.isInitialized, isTrue);

      resetLanguage();

      expect(Language.instance.isInitialized, isFalse);
      expect(Language.instance.current.code, equals('und'));
      expect(Language.instance.supportedLanguages, isEmpty);
      expect(Language.instance.config, isNull);
    });

    test('fromCode matches primary language when country is stored', () async {
      await Language.instance.init(config: testConfig);
      expect(Language.instance.fromCode('ar_EG'), equals(LanguageModel.ar));
      expect(Language.instance.fromCode('en_US'), equals(LanguageModel.en));
    });

    test('country variants of the same language stay distinct', () async {
      const arEg = LanguageModel(
        code: 'ar',
        nativeName: 'العربية (EG)',
        countryCode: 'EG',
      );
      const arSa = LanguageModel(
        code: 'ar',
        nativeName: 'العربية (SA)',
        countryCode: 'SA',
      );
      const countryConfig = LanguageConfig(
        jsonAssetPaths: [
          'assets/lang/en.json',
          'assets/lang/ar_EG.json',
          'assets/lang/ar_SA.json',
        ],
        defaultLanguage: arEg,
      );
      final bundle = FakeAssetBundle({
        'assets/lang/en.json': '{}',
        'assets/lang/ar_EG.json': '{}',
        'assets/lang/ar_SA.json': '{}',
      });

      await Language.instance.init(config: countryConfig, bundle: bundle);

      expect(Language.instance.supportedLanguages, [
        LanguageModel.en,
        arEg,
        arSa,
      ]);
      expect(Language.instance.fromCode('ar_SA'), equals(arSa));
      expect(Language.instance.fromCode('ar_EG'), equals(arEg));
      expect(Language.instance.fromCode('ar'), equals(arEg));

      await Language.instance.changeLanguage(arSa);
      expect(Language.instance.current, equals(arSa));
      expect(Language.instance.currentCode, equals('ar_SA'));
    });
  });

  group('LanguageBuilder Tests', () {
    final translationBundle = FakeAssetBundle({
      'assets/lang/en.json': '{}',
      'assets/lang/ar.json': '{}',
    });

    testWidgets('rebuilds when the controller notifies', (tester) async {
      await Language.instance.init(
        config: testConfig,
        storage: FakeLanguageStorage(),
        bundle: translationBundle,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: .ltr,
          child: LanguageBuilder(
            builder: (context, language, locale) {
              return Text(
                '${language.code}:${locale.languageCode}:${context.currentLanguageCode}',
              );
            },
          ),
        ),
      );

      expect(find.text('en:en:en'), findsOneWidget);

      await Language.instance.changeLanguage(LanguageModel.ar);
      await tester.pump();

      expect(find.text('ar:ar:ar'), findsOneWidget);
    });
  });
}
