part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final Themes theme;
  final String? errorMessage;

  const ThemeState({
    required this.theme,
    this.errorMessage,
  });

  @override
  List<Object?> get props => <Object?>[theme, errorMessage];
}
