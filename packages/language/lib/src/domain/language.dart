import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/language_yaml_loader.dart';
import '../presentation/language_localizations.dart';
import 'language_model.dart';
import 'language_change_listener.dart';
import 'language_config.dart';
import 'language_exceptions.dart';
import 'language_file_parser.dart';
import 'language_storage.dart';

/// Process-wide language orchestrator (singleton + [ChangeNotifier]).
final class Language extends ChangeNotifier {
  Language._();

  static final Language instance = Language._();

  factory Language() => instance;

  bool _initialized = false;
  LanguageModel _current = const LanguageModel(code: 'und', nativeName: '');
  LanguageModel _defaultLanguage =
      const LanguageModel(code: 'und', nativeName: '');
  List<LanguageModel> _supportedLanguages = const [];
  LanguageConfig? _config;
  LanguageStorage _storage = InMemoryLanguageStorage();
  LanguageChangeListener? _listener;
  AssetBundle? _bundle;

  bool get isInitialized => _initialized;
  LanguageModel get current => _current;
  LanguageModel get defaultLanguage => _defaultLanguage;
  List<LanguageModel> get supportedLanguages =>
      List.unmodifiable(_supportedLanguages);
  LanguageConfig? get config => _config;
  Locale get currentLocale => _current.locale;
  String get currentCode => _current.fullCode;
  bool get isArabic => _current.isArabic;
  bool get isEnglish => _current.isEnglish;

  /// Must run after [WidgetsFlutterBinding.ensureInitialized] and before `runApp`.
  Future<void> init({
    LanguageStorage? storage,
    LanguageChangeListener? listener,
    String yamlAssetName = LanguageYamlLoader.defaultAssetName,
    AssetBundle? bundle,
    LanguageConfig? config,
  }) async {
    final resolvedConfig = config ??
        await LanguageYamlLoader.load(assetName: yamlAssetName, bundle: bundle);
    applyConfig(resolvedConfig);

    _storage = storage ?? InMemoryLanguageStorage();
    _listener = listener;
    _bundle = bundle;

    final savedCode = await _storage.getLanguageCode();
    _current = _languageFromStoredCode(savedCode);
    await _loadTranslations(_current);

    _initialized = true;
    _listener?.onLanguageChanged(_current);
    notifyListeners();
  }

  void applyConfig(LanguageConfig config) {
    _config = config;
    final declaredLanguages = config.declaredLanguages;
    if (declaredLanguages.isNotEmpty) {
      _supportedLanguages = declaredLanguages;
    }
    _defaultLanguage = config.defaultLanguage ??
        (declaredLanguages.isNotEmpty
            ? declaredLanguages.first
            : _defaultLanguage);
    _current = _defaultLanguage;
  }

  Future<void> changeLanguage(LanguageModel language) async {
    _assertInitialized();
    if (!_supportedLanguages.contains(language)) {
      throw UnsupportedLanguageException(language.fullCode);
    }
    if (language == _current) return;

    _current = language;
    await _loadTranslations(language);
    await _storage.saveLanguageCode(language.fullCode);
    notifyListeners();
    _listener?.onLanguageChanged(language);
  }

  LanguageModel fromCode(String? code) {
    return LanguageModel.lookup(_supportedLanguages, code) ?? _defaultLanguage;
  }

  /// Storage must hold the JSON file stem: `ar` or `ar_EG`. Anything else
  /// (stale country code, `AR`, `ar-EG`) falls back to [defaultLanguage].
  LanguageModel _languageFromStoredCode(String? code) {
    if (code == null || code.trim().isEmpty) return _defaultLanguage;
    final normalized = code.trim();
    if (!LanguageFileParser.isValidLanguageCode(normalized)) {
      return _defaultLanguage;
    }
    return LanguageModel.byStoredCode(_supportedLanguages, normalized) ??
        _defaultLanguage;
  }

  LanguageModel fromLocale(Locale locale) {
    final codeStr =
        (locale.countryCode != null && locale.countryCode!.isNotEmpty)
            ? '${locale.languageCode}_${locale.countryCode}'
            : locale.languageCode;
    return fromCode(codeStr);
  }

  /// Restores uninitialized defaults. Does not [dispose] this singleton.
  void _reset() {
    _initialized = false;
    _current = const LanguageModel(code: 'und', nativeName: '');
    _defaultLanguage = const LanguageModel(code: 'und', nativeName: '');
    _supportedLanguages = const [];
    _config = null;
    _storage = InMemoryLanguageStorage();
    _listener = null;
    _bundle = null;
  }

  Future<void> _loadTranslations(LanguageModel language) {
    return LanguageLocalizations(language.locale).load(bundle: _bundle);
  }

  void _assertInitialized() {
    if (!_initialized) throw const LanguageNotInitializedException();
  }
}

/// Test-only. Host apps must not call this — import `package:language/testing.dart`.
@visibleForTesting
void resetLanguage() => Language.instance._reset();
