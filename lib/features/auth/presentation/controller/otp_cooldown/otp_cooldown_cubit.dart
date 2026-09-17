import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'otp_cooldown_states.dart';

class OtpCooldownCubit extends Cubit<OtpCooldownState> {
  OtpCooldownCubit({required this.tick}) : super(const OtpCooldownIdle());

  /// Emits remaining seconds from [ticks] down to 0.
  final Stream<int> Function(int ticks) tick;

  StreamSubscription<int>? _subscription;

  void fStart(int seconds) {
    unawaited(_subscription?.cancel());
    if (seconds <= 0) {
      emit(const OtpCooldownIdle());
      return;
    }
    emit(OtpCooldownCounting(secondsRemaining: seconds));
    _subscription = tick(seconds).listen((int remaining) {
      if (isClosed) {
        return;
      }
      if (remaining <= 0) {
        emit(const OtpCooldownIdle());
      } else {
        emit(OtpCooldownCounting(secondsRemaining: remaining));
      }
    });
  }

  static Stream<int> periodicTick(int ticks) {
    return Stream<int>.periodic(
      const Duration(seconds: 1),
      (int index) => ticks - index - 1,
    ).take(ticks);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
