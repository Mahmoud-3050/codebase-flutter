import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../utils/exceptions.dart';
import '../../utils/names_helper.dart';
import '../src/strings_generator.dart';

const String _emptyLangJson = '''
{
}
''';

const String _existingLangJson = '''
{
  "app_name": "TestAppName",
  "login": "Login"
}
''';

const List<String> _countryFiles = <String>[
  'en_EG',
  'en_SA',
  'en_OM',
  'ar_EG',
  'ar_SA',
  'ar_OM',
];

Map<String, String> _enAr({required String en, required String ar}) =>
    <String, String>{'en': en, 'ar': ar};

Map<String, String> _translationsFor({
  required Map<String, dynamic> incoming,
  required String jsonKey,
  List<String> locales = _countryFiles,
}) {
  return <String, String>{
    for (final String lang in locales)
      lang: (json.decode(
        applyLangJsonEntries(
          existingJson: _emptyLangJson,
          incoming: incoming,
          lang: lang,
        ),
      ) as Map<String, dynamic>)[jsonKey] as String,
  };
}

void main() {
  group('applyLangJsonEntries — English', () {
    test('uses the en value, not the outer key, when en is provided', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'welcome_message': _enAr(en: 'Welcome', ar: 'مرحبا'),
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map['welcome_message'], 'Welcome');
      expect(map.containsKey('مرحبا'), isFalse);
    });

    test('falls back to the outer key when no English locale is provided', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'welcome_message': <String, String>{'ar': 'مرحبا'},
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map['welcome_message'], 'welcome_message');
    });

    test('converts an English sentence key to snake_case', () {
      final String result = applyLangJsonEntries(
        existingJson: _emptyLangJson,
        incoming: <String, dynamic>{
          'Please choose a future date and time': _enAr(
            en: 'Please choose a future date and time',
            ar: 'الرجاء اختيار تاريخ ووقت في المستقبل',
          ),
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(
        map['please_choose_a_future_date_and_time'],
        'Please choose a future date and time',
      );
    });

    test('converts camelCase and class-case keys to snake_case JSON keys', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'signUpNow': _enAr(en: 'x', ar: 'x'),
          'SignUpLater': _enAr(en: 'y', ar: 'y'),
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('sign_up_now'), isTrue);
      expect(map.containsKey('sign_up_later'), isTrue);
    });

    test('keeps a trailing underscore on the stored JSON key', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'status_': _enAr(en: 'status', ar: 'حالة'),
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('status_'), isTrue);
      expect(map.containsKey('status'), isFalse);
      expect(map['status_'], 'status');
    });

    test(
        'treats status_ as already present when status exists (lookup without trailing _)',
        () {
      const String existing = '''
{
  "status": "ok"
}
''';
      final String result = applyLangJsonEntries(
        existingJson: existing,
        incoming: <String, dynamic>{
          'status_': _enAr(en: 'status', ar: 'حالة'),
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('status_'), isFalse);
      expect(map['status'], 'ok');
    });

    test('does not overwrite a key that already exists', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'login': _enAr(en: 'should-not-write', ar: 'تجاهل'),
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map['login'], 'Login');
      expect(map.length, 2);
    });

    test('skips Dart reserved keywords', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'class': _enAr(en: 'ignored', ar: 'ignored'),
          'if': _enAr(en: 'ignored', ar: 'ignored'),
          'safe_key': _enAr(en: 'ok', ar: 'ok'),
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('class'), isFalse);
      expect(map.containsKey('if'), isFalse);
      expect(map.containsKey('safe_key'), isTrue);
    });

    test('skips keys that cannot be turned into a name', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          '!!!': _enAr(en: 'bad', ar: 'bad'),
          'valid_name': _enAr(en: 'ok', ar: 'ok'),
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('valid_name'), isTrue);
      expect(map.length, 3);
    });

    test('appends several new keys as valid JSON without a trailing comma', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'first_key': _enAr(en: 'a', ar: 'ا'),
          'second_key': _enAr(en: 'b', ar: 'ب'),
          'third_key': _enAr(en: 'c', ar: 'ج'),
        },
        lang: 'en',
      );

      expect(() => json.decode(result), returnsNormally);
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;
      expect(map['first_key'], 'a');
      expect(map['second_key'], 'b');
      expect(map['third_key'], 'c');
      expect(result.trim().endsWith(','), isFalse);
    });

    test('empty incoming map still yields valid JSON of the existing keys', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{},
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map, <String, dynamic>{
        'app_name': 'TestAppName',
        'login': 'Login',
      });
    });

    test('throws when a value is not a locale object', () {
      expect(
        () => applyLangJsonEntries(
          existingJson: _emptyLangJson,
          incoming: <String, dynamic>{'hello': 'not-an-object'},
          lang: 'en',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when existing JSON is not an object', () {
      expect(
        () => applyLangJsonEntries(
          existingJson: '[]',
          incoming: <String, dynamic>{
            'hello': _enAr(en: 'x', ar: 'س'),
          },
          lang: 'en',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('applyLangJsonEntries — Arabic', () {
    test('uses the ar value', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'welcome_message': _enAr(en: 'Welcome', ar: 'مرحبا'),
        },
        lang: 'ar',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map['welcome_message'], 'مرحبا');
    });

    test('does not overwrite an existing Arabic key', () {
      const String existingAr = '''
{
  "login": "تسجيل الدخول"
}
''';
      final String result = applyLangJsonEntries(
        existingJson: existingAr,
        incoming: <String, dynamic>{
          'login': _enAr(en: 'Login', ar: 'تجاهل'),
        },
        lang: 'ar',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map['login'], 'تسجيل الدخول');
    });
  });

  group('locale object fallbacks (6 country files)', () {
    test('en + ar fill all three English and all three Arabic files', () {
      const Map<String, dynamic> incoming = <String, dynamic>{
        'welcome': <String, String>{
          'en': 'Welcome',
          'ar': 'مرحبا',
        },
      };

      expect(
        _translationsFor(incoming: incoming, jsonKey: 'welcome'),
        <String, String>{
          'en_EG': 'Welcome',
          'en_SA': 'Welcome',
          'en_OM': 'Welcome',
          'ar_EG': 'مرحبا',
          'ar_SA': 'مرحبا',
          'ar_OM': 'مرحبا',
        },
      );
    });

    test(
      'country keys only: omitted files use the first same-language value',
      () {
        const Map<String, dynamic> incoming = <String, dynamic>{
          'welcome': <String, String>{
            'en_EG': 'Welcome EG',
            'en_SA': 'Welcome SA',
            'ar_EG': 'أهلًا',
            'ar_SA': 'هلا',
          },
        };

        expect(
          _translationsFor(incoming: incoming, jsonKey: 'welcome'),
          <String, String>{
            'en_EG': 'Welcome EG',
            'en_SA': 'Welcome SA',
            'en_OM': 'Welcome EG',
            'ar_EG': 'أهلًا',
            'ar_SA': 'هلا',
            'ar_OM': 'أهلًا',
          },
        );
      },
    );

    test('listing ar_OM still leaves en_OM on the first English country', () {
      const Map<String, dynamic> incoming = <String, dynamic>{
        'welcome': <String, String>{
          'en_EG': 'Welcome EG',
          'en_SA': 'Welcome SA',
          'ar_EG': 'أهلًا',
          'ar_SA': 'هلا',
          'ar_OM': 'مرحبا عمان',
        },
      };

      expect(
        _translationsFor(incoming: incoming, jsonKey: 'welcome'),
        <String, String>{
          'en_EG': 'Welcome EG',
          'en_SA': 'Welcome SA',
          'en_OM': 'Welcome EG',
          'ar_EG': 'أهلًا',
          'ar_SA': 'هلا',
          'ar_OM': 'مرحبا عمان',
        },
      );
    });

    test('en / ar defaults win over first-country for omitted files', () {
      const Map<String, dynamic> incoming = <String, dynamic>{
        'welcome': <String, String>{
          'en': 'Welcome',
          'ar': 'مرحبا',
          'en_EG': 'Welcome EG',
          'ar_EG': 'أهلًا',
        },
      };

      expect(
        _translationsFor(incoming: incoming, jsonKey: 'welcome'),
        <String, String>{
          'en_EG': 'Welcome EG',
          'en_SA': 'Welcome',
          'en_OM': 'Welcome',
          'ar_EG': 'أهلًا',
          'ar_SA': 'مرحبا',
          'ar_OM': 'مرحبا',
        },
      );
    });
  });

  group('extractPlaceholders', () {
    test('returns unique names in first-seen order', () {
      expect(
        extractPlaceholders('{current} counts from {total} and {current}'),
        <String>['current', 'total'],
      );
    });

    test('ignores {0} and non-identifier braces', () {
      expect(extractPlaceholders('{0} items {username}'), <String>['username']);
      expect(extractPlaceholders('no holes'), isEmpty);
    });

    test('placeholdersForEntry prefers en then first en_*', () {
      expect(
        placeholdersForEntry(<String, String>{
          'ar': 'مرحبا {username}',
          'en': 'welcome {username}',
        }),
        <String>['username'],
      );
      expect(
        placeholdersForEntry(<String, String>{
          'ar_EG': 'أهلًا {name}',
          'en_SA': '{current} of {total}',
        }),
        <String>['current', 'total'],
      );
    });
  });

  group('locale values keep {placeholders}', () {
    test('writes templates into every country file', () {
      const Map<String, dynamic> incoming = <String, dynamic>{
        'welcome': <String, String>{
          'en': 'welcome {username}',
          'ar': 'مرحبا {username}',
          'ar_EG': 'اهلا وسهلا {username}',
          'ar_SA': 'هلا {username}',
        },
      };

      expect(
        _translationsFor(incoming: incoming, jsonKey: 'welcome'),
        <String, String>{
          'en_EG': 'welcome {username}',
          'en_SA': 'welcome {username}',
          'en_OM': 'welcome {username}',
          'ar_EG': 'اهلا وسهلا {username}',
          'ar_SA': 'هلا {username}',
          'ar_OM': 'مرحبا {username}',
        },
      );
    });

    test('outer key stays welcome, not welcome_username', () {
      final String result = applyLangJsonEntries(
        existingJson: _emptyLangJson,
        incoming: <String, dynamic>{
          'welcome': <String, String>{
            'en': 'welcome {username}',
            'ar': 'مرحبا {username}',
          },
        },
        lang: 'en',
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('welcome'), isTrue);
      expect(map.containsKey('welcome_username'), isFalse);
    });
  });

  group('buildStringsClassSource', () {
    test('writes the language package import and an abstract Strings class',
        () {
      final String source = buildStringsClassSource(<String, dynamic>{
        'login': 'Login',
      });

      expect(source, startsWith(stringsClassImport));
      expect(source, contains('abstract class Strings {'));
      expect(source.trim(), endsWith('}'));
    });

    test('emits a getter that looks up the JSON key via .tr', () {
      final String source = buildStringsClassSource(<String, dynamic>{
        'login': 'Login',
      });

      expect(
        source,
        contains("static String get login => 'login'.tr;"),
      );
    });

    test('emits a named String method when the English value has placeholders',
        () {
      final String source = buildStringsClassSource(<String, dynamic>{
        'welcome': 'welcome {username}',
        'counts_from': '{current} counts from {total}',
      });

      expect(
        source,
        contains(
          "static String welcome({required String username}) => 'welcome'.trParams({'username': username});",
        ),
      );
      expect(
        source,
        contains(
          "static String countsFrom({required String current, required String total}) => 'counts_from'.trParams({'current': current, 'total': total});",
        ),
      );
      expect(source, isNot(contains('static String get welcome')));
      expect(source, isNot(contains('Object username')));
    });

    test('converts snake_case JSON keys to camelCase getters', () {
      final String source = buildStringsClassSource(<String, dynamic>{
        'please_try_again_later': 'Please try again later',
        'no_internet_connection': 'No Internet Connection',
      });

      expect(
        source,
        contains(
          "static String get pleaseTryAgainLater => 'please_try_again_later'.tr;",
        ),
      );
      expect(
        source,
        contains(
          "static String get noInternetConnection => 'no_internet_connection'.tr;",
        ),
      );
    });

    test('keeps a trailing underscore on both getter name and .tr key', () {
      final String source = buildStringsClassSource(<String, dynamic>{
        'status_': 'Status',
      });

      expect(
        source,
        contains("static String get status_ => 'status_'.tr;"),
      );
    });

    test('strips every underscore before Names when the JSON key ends with _',
        () {
      final String source = buildStringsClassSource(<String, dynamic>{
        'foo_bar_': 'x',
      });

      expect(
        source,
        contains("static String get foobar_ => 'foobar_'.tr;"),
      );
    });

    test('skips keys that cannot be turned into a Dart name', () {
      final String source = buildStringsClassSource(<String, dynamic>{
        '!!!': 'bad',
        'login': 'Login',
      });

      expect(source, isNot(contains('!!!')));
      expect(source, contains("static String get login => 'login'.tr;"));
    });

    test('emits an empty class body when the map is empty', () {
      final String source = buildStringsClassSource(<String, dynamic>{});

      expect(
        source,
        '''
$stringsClassImport

abstract class Strings {
}
''',
      );
    });

    test('generates one getter per remaining key, in insertion order', () {
      final String source = buildStringsClassSource(<String, dynamic>{
        'app_name': 'App',
        'sign_up': 'Sign Up',
      });
      final int appNameIndex = source.indexOf('get appName');
      final int signUpIndex = source.indexOf('get signUp');

      expect(appNameIndex, greaterThan(0));
      expect(signUpIndex, greaterThan(appNameIndex));
    });
  });

  group('end-to-end: lang.json → locale JSON → Strings class', () {
    test('matches the documented choose_future_date_and_time example', () {
      const Map<String, dynamic> langJson = <String, dynamic>{
        'choose_future_date_and_time': <String, String>{
          'en': 'Please choose a future date and time',
          'ar': 'الرجاء اختيار تاريخ ووقت في المستقبل',
        },
      };

      final String enJson = applyLangJsonEntries(
        existingJson: _emptyLangJson,
        incoming: langJson,
        lang: 'en',
      );
      final String arJson = applyLangJsonEntries(
        existingJson: _emptyLangJson,
        incoming: langJson,
        lang: 'ar',
      );
      final Map<String, dynamic> enMap =
          json.decode(enJson) as Map<String, dynamic>;
      final String stringsSource = buildStringsClassSource(enMap);

      expect(
        enMap['choose_future_date_and_time'],
        'Please choose a future date and time',
      );
      expect(
        json.decode(arJson)['choose_future_date_and_time'],
        'الرجاء اختيار تاريخ ووقت في المستقبل',
      );
      expect(
        stringsSource,
        contains(
          "static String get chooseFutureDateAndTime => 'choose_future_date_and_time'.tr;",
        ),
      );
    });

    test('rebuilds Strings from the full merged English map, not only new keys',
        () {
      final String enJson = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'welcome_back': _enAr(en: 'Welcome back', ar: 'أهلا'),
        },
        lang: 'en',
      );
      final Map<String, dynamic> enMap =
          json.decode(enJson) as Map<String, dynamic>;
      final String source = buildStringsClassSource(enMap);

      expect(source, contains("static String get appName => 'app_name'.tr;"));
      expect(source, contains("static String get login => 'login'.tr;"));
      expect(
        source,
        contains("static String get welcomeBack => 'welcome_back'.tr;"),
      );
    });
  });

  group('applyLangJsonEntries — delete mode', () {
    test('removes a simple existing key and leaves the others', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'login': _enAr(en: 'x', ar: 'س'),
        },
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('login'), isFalse);
      expect(map['app_name'], 'TestAppName');
      expect(map.length, 1);
    });

    test('resolves camelCase keys to snake_case before deleting', () {
      const String existing = '''
{
  "sign_up_now": "Sign up",
  "login": "Login"
}
''';
      final String result = applyLangJsonEntries(
        existingJson: existing,
        incoming: <String, dynamic>{
          'signUpNow': _enAr(en: 'x', ar: 'س'),
        },
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('sign_up_now'), isFalse);
      expect(map['login'], 'Login');
    });

    test('removes a trailing-underscore JSON key', () {
      const String existing = '''
{
  "status_": "status",
  "login": "Login"
}
''';
      final String result = applyLangJsonEntries(
        existingJson: existing,
        incoming: <String, dynamic>{
          'status_': _enAr(en: 'x', ar: 'س'),
        },
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('status_'), isFalse);
      expect(map['login'], 'Login');
    });

    test('deleting status_ also removes status (same lookup as add-mode)', () {
      const String existing = '''
{
  "status": "ok",
  "login": "Login"
}
''';
      final String result = applyLangJsonEntries(
        existingJson: existing,
        incoming: <String, dynamic>{
          'status_': _enAr(en: 'x', ar: 'س'),
        },
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('status'), isFalse);
      expect(map.containsKey('status_'), isFalse);
      expect(map['login'], 'Login');
    });

    test('is a no-op when the key is not in the file', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'does_not_exist': _enAr(en: 'x', ar: 'س'),
        },
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map, <String, dynamic>{
        'app_name': 'TestAppName',
        'login': 'Login',
      });
    });

    test('skips Dart reserved keywords and still deletes other keys', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'class': _enAr(en: 'ignored', ar: 'ignored'),
          'login': _enAr(en: 'x', ar: 'س'),
        },
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('login'), isFalse);
      expect(map['app_name'], 'TestAppName');
    });

    test('skips keys that cannot be turned into a name', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          '!!!': _enAr(en: 'bad', ar: 'bad'),
          'login': _enAr(en: 'x', ar: 'س'),
        },
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('login'), isFalse);
      expect(map['app_name'], 'TestAppName');
    });

    test('empty incoming map does not remove any keys', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{},
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map, <String, dynamic>{
        'app_name': 'TestAppName',
        'login': 'Login',
      });
    });

    test('deleting every key yields an empty JSON object', () {
      final String result = applyLangJsonEntries(
        existingJson: _existingLangJson,
        incoming: <String, dynamic>{
          'app_name': _enAr(en: 'x', ar: 'س'),
          'login': _enAr(en: 'y', ar: 'ص'),
        },
        lang: 'en',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map, isEmpty);
    });

    test('delete mode removes the key from a country file', () {
      const String existing = '''
{
  "welcome": "أهلًا",
  "login": "تسجيل"
}
''';
      final String result = applyLangJsonEntries(
        existingJson: existing,
        incoming: <String, dynamic>{
          'welcome': _enAr(en: 'x', ar: 'س'),
        },
        lang: 'ar_EG',
        mode: StringsGenerateMode.delete,
      );
      final Map<String, dynamic> map =
          json.decode(result) as Map<String, dynamic>;

      expect(map.containsKey('welcome'), isFalse);
      expect(map['login'], 'تسجيل');
    });
  });

  group('lang file stems', () {
    test('langStemFromFileName accepts language-only and country files', () {
      expect(langStemFromFileName('en.json'), 'en');
      expect(langStemFromFileName('ar.json'), 'ar');
      expect(langStemFromFileName('ar_EG.json'), 'ar_EG');
      expect(langStemFromFileName('assets/lang/ar_SA.json'), 'ar_SA');
      expect(langStemFromFileName('ar_OM.json'), 'ar_OM');
      expect(langStemFromFileName('readme.txt'), isNull);
      expect(langStemFromFileName('AR.json'), isNull);
      expect(langStemFromFileName('ar-EG.json'), isNull);
    });

    test('langStemsFromFileNames skips invalid names', () {
      expect(
        langStemsFromFileNames(<String>[
          'en.json',
          'notes.md',
          'ar_EG.json',
          'ar_SA.json',
        ]),
        <String>['en', 'ar_EG', 'ar_SA'],
      );
    });

    test('stringsSourceStem prefers en.json over country English files', () {
      expect(stringsSourceStem(<String>['ar', 'en_EG', 'en']), 'en');
      expect(stringsSourceStem(<String>['ar_EG', 'en_SA']), 'en_SA');
      expect(stringsSourceStem(<String>['ar', 'ar_EG']), 'ar');
      expect(stringsSourceStem(<String>[]), isNull);
    });
  });

  group('NamesHelper keywords used by the generator', () {
    test('dartKeywords includes the identifiers the generator skips', () {
      expect(NamesHelper.dartKeywords,
          containsAll(<String>['class', 'if', 'void', 'return']));
    });
  });

  group('NamesException', () {
    test('toString includes the message', () {
      expect(
        const NamesException('Input name cannot be empty (input: "")')
            .toString(),
        contains('cannot be empty'),
      );
    });
  });
}
