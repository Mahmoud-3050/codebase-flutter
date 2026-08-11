import 'package:app_language/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class FakeHydratedStorage implements Storage {
  final Map<String, dynamic> _storage = {};

  @override
  dynamic read(String key) => _storage[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<void> close() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeHydratedStorage storage;
  const testConfig = LanguageConfig(assetPathPrefix: 'assets/lang/');

  setUp(() {
    storage = FakeHydratedStorage();
    HydratedBloc.storage = storage;
    // Reset static state between tests
    AppLanguage.defaultLanguage = AppLanguage.en;
    AppLanguage.supportedLanguages = const [AppLanguage.en, AppLanguage.ar];
    AppLanguage.current = AppLanguage.en;
  });

  group('LanguageFileParser Tests', () {
    test('Valid file names parse correctly into AppLanguageModel', () {
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
  });

  group('AppLanguage Orchestrator Lookup Tests', () {
    test('fromCode parses code correctly', () {
      expect(AppLanguage.fromCode('en').code, equals('en'));
      expect(AppLanguage.fromCode('ar').code, equals('ar'));
    });

    test('fromCode returns defaultLanguage for null/empty/unknown', () {
      expect(AppLanguage.fromCode(null), equals(AppLanguage.defaultLanguage));
      expect(AppLanguage.fromCode(''), equals(AppLanguage.defaultLanguage));
      expect(AppLanguage.fromCode('zz'), equals(AppLanguage.defaultLanguage));
    });

    test('fromLocale parses Locale correctly', () {
      expect(AppLanguage.fromLocale(const Locale('en')).code, equals('en'));
      expect(AppLanguage.fromLocale(const Locale('ar', 'EG')).code, equals('ar'));
    });
  });

  group('AppLanguage Orchestrator State Tests', () {
    test('Single source of truth accessors work correctly', () {
      AppLanguage.current = AppLanguage.ar;

      expect(AppLanguage.current, equals(AppLanguage.ar));
      expect(AppLanguage.currentLocale, equals(const Locale('ar')));
      expect(AppLanguage.currentCode, equals('ar'));
      expect(AppLanguage.isArabic, isTrue);
      expect(AppLanguage.isEnglish, isFalse);

      AppLanguage.current = AppLanguage.en;

      expect(AppLanguage.current, equals(AppLanguage.en));
      expect(AppLanguage.currentLocale, equals(const Locale('en')));
      expect(AppLanguage.currentCode, equals('en'));
      expect(AppLanguage.isArabic, isFalse);
      expect(AppLanguage.isEnglish, isTrue);
    });

    test('defaultLanguage is used as fallback throughout', () {
      AppLanguage.defaultLanguage = AppLanguage.ar;

      expect(AppLanguage.fromCode(null), equals(AppLanguage.ar));
      expect(AppLanguage.fromCode(''), equals(AppLanguage.ar));
      expect(AppLanguage.fromCode('zz'), equals(AppLanguage.ar));
    });
  });

  group('LanguageCubit Hydrated & Config Tests', () {
    test('Initial state uses defaultLanguage from config', () {
      final cubit = LanguageCubit(config: testConfig);
      expect(cubit.state.language.code, equals('en'));
      expect(AppLanguage.current.code, equals('en'));
      cubit.close();
    });

    test('config.defaultLanguage propagates to AppLanguage.defaultLanguage', () {
      const arConfig = LanguageConfig(
        assetPathPrefix: 'assets/lang/',
        defaultLanguage: AppLanguage.ar,
      );
      final cubit = LanguageCubit(config: arConfig);

      expect(AppLanguage.defaultLanguage, equals(AppLanguage.ar));
      expect(cubit.state.language, equals(AppLanguage.ar));
      cubit.close();
    });

    test('changeLanguage updates state and single source of truth', () async {
      final cubit = LanguageCubit(config: testConfig);

      await cubit.changeLanguage(AppLanguage.ar);

      expect(cubit.state.language, equals(AppLanguage.ar));
      expect(AppLanguage.current, equals(AppLanguage.ar));
      expect(AppLanguage.isArabic, isTrue);

      await cubit.close();
    });
  });
}
