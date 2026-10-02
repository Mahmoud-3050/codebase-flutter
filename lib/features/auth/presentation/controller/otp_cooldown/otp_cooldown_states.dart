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
  const OtpCooldownCounting({
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  final int secondsRemaining;
  final int totalSeconds;

  @override
  List<Object?> get props => <Object?>[secondsRemaining, totalSeconds];
}
