import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/presentation/controller/otp_cooldown/otp_cooldown_cubit.dart';

void main() {
  blocTest<OtpCooldownCubit, OtpCooldownState>(
    'FR-012 injected ticker drives countdown then idle',
    build: () => OtpCooldownCubit(
      tick: (int ticks) => Stream<int>.fromIterable(<int>[2, 1, 0]),
    ),
    act: (OtpCooldownCubit cubit) => cubit.fStart(3),
    expect: () => <OtpCooldownState>[
      const OtpCooldownCounting(secondsRemaining: 3),
      const OtpCooldownCounting(secondsRemaining: 2),
      const OtpCooldownCounting(secondsRemaining: 1),
      const OtpCooldownIdle(),
    ],
  );

  test('FR-012 zero seconds stays idle', () {
    final OtpCooldownCubit cubit = OtpCooldownCubit(
      tick: (int ticks) => const Stream<int>.empty(),
    );
    cubit.fStart(0);
    expect(cubit.state, const OtpCooldownIdle());
    cubit.close();
  });

  test('FR-012 periodicTick and closed cubit ignore ticks', () async {
    expect(OtpCooldownCubit.periodicTick(1), isA<Stream<int>>());
    final StreamController<int> controller = StreamController<int>();
    final OtpCooldownCubit cubit = OtpCooldownCubit(
      tick: (int ticks) => controller.stream,
    );
    cubit.fStart(2);
    await cubit.close();
    controller.add(1);
    await controller.close();
  });
}
