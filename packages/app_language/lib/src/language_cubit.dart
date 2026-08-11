import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'app_language_model.dart';
import 'app_language_orchestrator.dart';
import 'app_localizations.dart';
import 'asset_language_loader.dart';
import 'language_config.dart';

final class LanguageState extends Equatable {
  final AppLanguageModel language;

  const LanguageState({required this.language});

  @override
  List<Object?> get props => [language];

  Map<String, dynamic> toJson() => {'languageCode': language.fullCode};

  factory LanguageState.fromJson(Map<String, dynamic> json) {
    return LanguageState(
      language: AppLanguage.fromCode(json['languageCode'] as String?),
    );
  }
}

class LanguageCubit extends HydratedCubit<LanguageState> {
  final LanguageConfig config;

  LanguageCubit({required this.config})
      : super(LanguageState(
          language: config.defaultLanguage ?? AppLanguage.defaultLanguage,
        )) {
    _applyDefaultLanguage();
    _initAndSync();
  }

  /// Applies [config.defaultLanguage] to the package-wide [AppLanguage.defaultLanguage]
  /// so all static fallbacks throughout the package use the configured value.
  void _applyDefaultLanguage() {
    if (config.defaultLanguage != null) {
      AppLanguage.defaultLanguage = config.defaultLanguage!;
    }
  }

  Future<void> _initAndSync() async {
    await AssetLanguageLoader.discoverSupportedLanguages(config);
    _syncCurrentLanguage(state.language);
  }

  /// Changes current application language.
  Future<void> changeLanguage(AppLanguageModel language) async {
    _syncCurrentLanguage(language);
    emit(LanguageState(language: language));
  }

  void _syncCurrentLanguage(AppLanguageModel language) {
    AppLanguage.current = language;
    AppLocalizations(
      language.locale,
      assetPathPrefix: config.normalizedPathPrefix,
    ).load();
  }

  @override
  LanguageState? fromJson(Map<String, dynamic> json) {
    try {
      final state = LanguageState.fromJson(json);
      _syncCurrentLanguage(state.language);
      return state;
    } catch (_) {
      return LanguageState(language: AppLanguage.defaultLanguage);
    }
  }

  @override
  Map<String, dynamic>? toJson(LanguageState state) => state.toJson();
}
