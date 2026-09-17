import 'package:either/either.dart';
import 'package:field_validator/field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/login_outcome.dart';
import 'package:codebase/features/auth/domain/entities/login_response.dart';
import 'package:codebase/features/auth/presentation/controller/login/login_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/login_screen.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, LoginResponse>>(
      const Left<Failure, LoginResponse>(ServerFailure()),
    );
  });
  tearDown(resetAuthWidget);

  testWidgets('FR-014 FR-046a login has email, password, forgot link', (
    WidgetTester tester,
  ) async {
    final MockLoginUseCase useCase = MockLoginUseCase();
    final LoginCubit cubit = LoginCubit(useCase);
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LoginCubit>.value(value: cubit),
      ],
      child: const LoginScreen(),
    );
    expect(find.text(Strings.email), findsWidgets);
    expect(find.text(Strings.password), findsWidgets);
    expect(find.text(Strings.forgotPassword), findsOneWidget);
    await tester.tap(find.text(Strings.forgotPassword));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.forgotPassword}'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FR-016 FR-049 invalid_credentials and no_internet', (
    WidgetTester tester,
  ) async {
    final MockLoginUseCase useCase = MockLoginUseCase();
    when(useCase.call(any)).thenAnswer(
      (_) async => const Left<Failure, LoginResponse>(UnauthorizedFailure()),
    );
    final LoginCubit cubit = LoginCubit(useCase);
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LoginCubit>.value(value: cubit),
      ],
      child: const LoginScreen(),
    );
    await cubit.fLogin(email: 'a@b.c', password: 'x');
    await tester.pump();
    expect(find.text(Strings.invalidCredentials), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FR-014 FR-017 login submit and unverified email route', (
    WidgetTester tester,
  ) async {
    FieldValidator.instance.init();
    final MockLoginUseCase useCase = MockLoginUseCase();
    when(useCase.call(any)).thenAnswer(
      (_) async => const Left<Failure, LoginResponse>(ServerFailure()),
    );
    final LoginCubit cubit = LoginCubit(useCase);
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LoginCubit>.value(value: cubit),
      ],
      child: const LoginScreen(),
    );
    await tester.enterText(find.byType(TextField).at(0), 'ada@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret12');
    await tester.tap(find.text(Strings.signIn).last);
    await tester.pump();
    cubit.emit(
      const ApiCallSuccess<LoginOutcome>(
        data: LoginNeedsEmailVerification(kEmailChallenge),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('routed:${AppRoutes.verifyEmail}'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FR-015 login success routes home', (WidgetTester tester) async {
    final MockLoginUseCase useCase = MockLoginUseCase();
    final LoginCubit cubit = LoginCubit(useCase);
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LoginCubit>.value(value: cubit),
      ],
      child: const LoginScreen(),
    );
    cubit.emit(ApiCallSuccess<LoginOutcome>(data: LoginSucceeded(kSession)));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.home}'), findsOneWidget);
    await cubit.close();
  });
}
