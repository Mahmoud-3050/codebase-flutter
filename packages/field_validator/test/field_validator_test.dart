import 'package:field_validator/field_validator.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAssetLoader implements AssetLoader {
  final Map<String, String> assets;
  const FakeAssetLoader(this.assets);

  @override
  Future<String> loadString(String path) async {
    final content = assets[path];
    if (content == null) throw Exception('Asset not found: $path');
    return content;
  }
}

void main() {
  group('FieldValidator Localization Tests', () {
    test('Default locale is en and returns English messages', () {
      FieldValidator.instance.init();
      expect(FieldValidator.instance.locale, equals(ValidatorLocale.en));

      final validator = const EmptyValidator();
      expect(validator.validate(''), equals('Field is required'));
    });

    test('Initializing with ar returns Arabic messages', () {
      FieldValidator.instance.init(locale: .ar);
      expect(FieldValidator.instance.locale, equals(ValidatorLocale.ar));

      final validator = const EmptyValidator();
      expect(validator.validate(''), equals('حقل مطلوب'));
    });

    test('Initializing from JSON map parses error keys correctly', () {
      final jsonMap = {
        'error_field_required': 'Custom Required from JSON',
        'error_valid_email': 'Custom Email from JSON',
      };

      FieldValidator.instance.initFromJson(jsonMap);

      final emptyVal = const EmptyValidator();
      final emailVal = const EmailValidator();

      expect(emptyVal.validate(''), equals('Custom Required from JSON'));
      expect(emailVal.validate('invalid'), equals('Custom Email from JSON'));
    });

    test('Loading from custom AssetLoader loads strings correctly', () async {
      const fakePath = 'packages/field_validator/assets/lang/en.json';
      final fakeLoader = const FakeAssetLoader({
        fakePath: '{"error_field_required": "Loaded via AssetLoader"}',
      });

      await FieldValidator.instance.loadFromAsset(.en, assetLoader: fakeLoader);

      final validator = const EmptyValidator();
      expect(validator.validate(''), equals('Loaded via AssetLoader'));
    });

    test('Switching locale dynamically via setLocale updates messages', () {
      FieldValidator.instance.init();
      final validator = const EmailValidator();

      expect(
        validator.validate('invalid'),
        equals('Please enter a valid email address'),
      );

      FieldValidator.instance.setLocale(.ar);
      expect(
        validator.validate('invalid'),
        equals('يرجى إدخال عنوان بريد إلكتروني صحيح'),
      );
    });

    test(
      'Custom message override takes precedence over localized defaults',
      () {
        FieldValidator.instance.init(locale: .ar);

        final validator = const EmptyValidator(customErrorMessage: 'خطأ مخصص');
        expect(validator.validate(''), equals('خطأ مخصص'));
      },
    );
  });
}
