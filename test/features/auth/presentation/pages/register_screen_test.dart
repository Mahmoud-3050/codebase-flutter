import 'package:either/either.dart';
import 'package:field_validator/field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/data/datasources/avatar_picker.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/register_response.dart';
import 'package:codebase/features/auth/presentation/controller/register/register_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/register_screen.dart';
import 'package:codebase/injection_container.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, RegisterResponse>>(
      const Left<Failure, RegisterResponse>(ServerFailure()),
    );
  });
  tearDown(resetAuthWidget);

  late MockRegisterUseCase useCase;
  late RegisterCubit cubit;

  setUp(() {
    FieldValidator.instance.init();
    useCase = MockRegisterUseCase();
    cubit = RegisterCubit(useCase);
  });

  tearDown(() => cubit.close());

  testWidgets('FR-005 FR-047 FR-052 register labels and no role control', (
    WidgetTester tester,
  ) async {
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>.value(value: cubit),
      ],
      child: const RegisterScreen(),
    );
    expect(find.text(Strings.name), findsWidgets);
    expect(find.text(Strings.email), findsWidgets);
    expect(find.text(Strings.password), findsWidgets);
    expect(find.text(Strings.createAccount), findsWidgets);
    expect(find.text('Student'), findsNothing);
    expect(find.text('Company'), findsNothing);
  });

  testWidgets('FR-049 register shows no_internet', (WidgetTester tester) async {
    when(useCase.call(any)).thenAnswer(
      (_) async => const Left<Failure, RegisterResponse>(NetworkFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>.value(value: cubit),
      ],
      child: const RegisterScreen(),
    );
    await cubit.fRegister(
      fullName: 'Ada',
      email: 'ada@example.com',
      dialingCode: '+966',
      phone: '500000000',
      password: 'secret12',
    );
    await tester.pump();
    expect(find.text(Strings.noInternet), findsOneWidget);
  });

  testWidgets('FR-050 register RTL', (WidgetTester tester) async {
    await pumpAuthWidget(
      tester,
      textDirection: TextDirection.rtl,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>.value(value: cubit),
      ],
      child: const RegisterScreen(),
    );
    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('FR-006c skip photo keeps placeholder CTA', (
    WidgetTester tester,
  ) async {
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>.value(value: cubit),
      ],
      child: const RegisterScreen(),
    );
    expect(find.text(Strings.addPhoto), findsOneWidget);
  });

  testWidgets('FR-006a FR-006c avatar pick and reject on register', (
    WidgetTester tester,
  ) async {
    final GetIt sl = ServiceLocator.instance;
    sl.allowReassignment = true;
    final MockAvatarPicker picker = MockAvatarPicker();
    sl.registerSingleton<AvatarPicker>(picker);
    addTearDown(() {
      if (sl.isRegistered<AvatarPicker>()) {
        sl.unregister<AvatarPicker>();
      }
    });
    when(picker.pickAvatar()).thenThrow(
      const AvatarRejectedException(reason: AvatarRejectReason.tooLarge),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>.value(value: cubit),
      ],
      child: const RegisterScreen(),
    );
    await tester.tap(find.text(Strings.addPhoto));
    await tester.pump();
    expect(find.text(Strings.avatarTooLarge), findsOneWidget);
  });

  testWidgets('FR-006c register skip photo after pick', (
    WidgetTester tester,
  ) async {
    final GetIt sl = ServiceLocator.instance;
    sl.allowReassignment = true;
    final MockAvatarPicker picker = MockAvatarPicker();
    sl.registerSingleton<AvatarPicker>(picker);
    addTearDown(() {
      if (sl.isRegistered<AvatarPicker>()) {
        sl.unregister<AvatarPicker>();
      }
    });
    when(picker.pickAvatar()).thenAnswer((_) async => '/tmp/a.png');
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>.value(value: cubit),
      ],
      child: const RegisterScreen(),
    );
    await tester.tap(find.text(Strings.addPhoto));
    await tester.pump();
    await tester.pump();
    expect(find.text(Strings.skipPhoto), findsOneWidget);
  });

  testWidgets('FR-008 register submit and email_taken routes to login', (
    WidgetTester tester,
  ) async {
    when(useCase.call(any)).thenAnswer(
      (_) async => const Right<Failure, RegisterResponse>(
        RegisterResponse(
          status: 'success',
          message: 'ok',
          data: kEmailChallenge,
        ),
      ),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>.value(value: cubit),
      ],
      child: const RegisterScreen(),
    );
    await tester.enterText(find.byType(TextField).at(0), 'Ada Lovelace');
    await tester.enterText(find.byType(TextField).at(1), 'ada@example.com');
    await tester.enterText(find.byType(TextField).at(2), '500000000');
    await tester.enterText(find.byType(TextField).at(3), 'secret12');
    await tester.tap(find.text(Strings.createAccount).last);
    await tester.pump();
    cubit.emit(ApiCallError<OtpChallenge>(message: Strings.emailTaken));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.login}'), findsOneWidget);
  });
}
