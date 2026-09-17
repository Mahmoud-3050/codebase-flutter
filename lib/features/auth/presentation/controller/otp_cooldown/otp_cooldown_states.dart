part of 'otp_cooldown_cubit.dart';

sealed class OtpCooldownState extends Equatable {
  const OtpCooldownState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class OtpCooldownIdle extends OtpCooldownState {
  const OtpCooldownIdle();
}

final class OtpCooldownCounting extends OtpCooldownState {
  const OtpCooldownCounting({required this.secondsRemaining});

  final int secondsRemaining;

  @override
  List<Object?> get props => <Object?>[secondsRemaining];
}
