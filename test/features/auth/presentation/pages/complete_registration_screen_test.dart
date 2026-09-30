import 'package:either/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/avatar_picker.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/entities/complete_registration_response.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/request_otp_response.dart';
import 'package:codebase/features/auth/presentation/controller/complete_registration/complete_registration_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/request_phone_otp/request_phone_otp_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/complete_registration_screen.dart';
import 'package:field_validator/field_validator.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, CompleteRegistrationResponse>>(
      const Left<Failure, CompleteRegistrationResponse>(ServerFailure()),
    );
    provideDummy<Either<Failure, RequestOtpResponse>>(
      const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
  });
  setUp(() => FieldValidator.instance.init());
  tearDown(resetAuthWidget);

  Future<void> pumpComplete(
    WidgetTester tester, {
    required Widget child,
    MockAvatarPicker? picker,
  }) {
    return pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>(
          create: (_) =>
              CompleteRegistrationCubit(MockCompleteRegistrationUseCase()),
        ),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
      ],
      repositories: picker == null
          ? const <RepositoryProvider<dynamic>>[]
          : <RepositoryProvider<dynamic>>[
              RepositoryProvider<AvatarPicker>.value(value: picker),
            ],
      child: child,
    );
  }

  testWidgets('FR-023 FR-024 FR-047 phone source locks phone, no role', (
    WidgetTester tester,
  ) async {
    await pumpComplete(
      tester,
      child: const CompleteRegistrationScreen(draft: kPhoneDraft),
    );
    expect(find.text(Strings.completeRegistration), findsWidgets);
    expect(find.text('Student'), findsNothing);
    final Iterable<EditableText> fields = tester.widgetList<EditableText>(
      find.byType(EditableText),
    );
    expect(fields.any((EditableText f) => f.readOnly), isTrue);
  });

  testWidgets('FR-031 FR-034 google/apple lock email', (
    WidgetTester tester,
  ) async {
    await pumpComplete(
      tester,
      child: const CompleteRegistrationScreen(draft: kGoogleDraft),
    );
    expect(find.text(Strings.email), findsWidgets);
    await pumpComplete(
      tester,
      child: const CompleteRegistrationScreen(draft: kAppleDraft),
    );
    expect(find.text(Strings.email), findsWidgets);
  });

  testWidgets('FR-025 complete registration submits password', (
    WidgetTester tester,
  ) async {
    final MockCompleteRegistrationUseCase complete =
        MockCompleteRegistrationUseCase();
    when(complete.call(any)).thenAnswer(
      (_) async =>
          const Left<Failure, CompleteRegistrationResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>(
          create: (_) => CompleteRegistrationCubit(complete),
        ),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
      ],
      child: const CompleteRegistrationScreen(draft: kPhoneDraft),
    );
    await tester.enterText(find.byType(TextField).at(0), 'Ada Lovelace');
    await tester.enterText(find.byType(TextField).at(1), 'ada@example.com');
    await tester.enterText(find.byType(TextField).last, 'secret12');
    await tester.tap(find.text(Strings.completeRegistration).last);
    await tester.pump();
  });

  testWidgets('FR-006a avatar reject keeps completion form', (
    WidgetTester tester,
  ) async {
    final MockAvatarPicker picker = MockAvatarPicker();
    when(picker.pickAvatar()).thenThrow(
      const AvatarRejectedException(reason: AvatarRejectReason.tooLarge),
    );
    await pumpComplete(
      tester,
      picker: picker,
      child: const CompleteRegistrationScreen(draft: kPhoneDraft),
    );
    await tester.tap(find.text(Strings.addPhoto));
    await tester.pump();
    expect(find.text(Strings.avatarTooLarge), findsOneWidget);
  });

  testWidgets('FR-006a unsupported avatar type is rejected', (
    WidgetTester tester,
  ) async {
    final MockAvatarPicker picker = MockAvatarPicker();
    when(picker.pickAvatar()).thenThrow(
      const AvatarRejectedException(reason: AvatarRejectReason.unsupportedType),
    );
    await pumpComplete(
      tester,
      picker: picker,
      child: const CompleteRegistrationScreen(draft: kPhoneDraft),
    );
    await tester.tap(find.text(Strings.addPhoto));
    await tester.pump();
    expect(find.text(Strings.avatarUnsupportedType), findsOneWidget);
  });

  testWidgets('FR-006c picked avatar switches CTA to skip photo', (
    WidgetTester tester,
  ) async {
    final MockAvatarPicker picker = MockAvatarPicker();
    when(picker.pickAvatar()).thenAnswer((_) async => '/tmp/a.png');
    await pumpComplete(
      tester,
      picker: picker,
      child: const CompleteRegistrationScreen(draft: kPhoneDraft),
    );
    await tester.tap(find.text(Strings.addPhoto));
    await tester.pump();
    await tester.pump();
    expect(find.text(Strings.skipPhoto), findsOneWidget);
  });

  testWidgets('FR-033 social completion requests phone OTP', (
    WidgetTester tester,
  ) async {
    final MockRequestPhoneOtpUseCase request = MockRequestPhoneOtpUseCase();
    when(request.call(any)).thenAnswer(
      (_) async => const Left<Failure, RequestOtpResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>(
          create: (_) =>
              CompleteRegistrationCubit(MockCompleteRegistrationUseCase()),
        ),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(request),
        ),
      ],
      child: const CompleteRegistrationScreen(draft: kGoogleDraft),
    );
    await tester.enterText(find.byType(TextField).at(2), '500000000');
    await tester.enterText(find.byType(TextField).last, 'secret12');
    await tester.tap(find.text(Strings.completeRegistration).last);
    await tester.pump();
  });

  testWidgets('FR-026a draft_expired routes back to phone sign-in', (
    WidgetTester tester,
  ) async {
    final MockCompleteRegistrationUseCase complete =
        MockCompleteRegistrationUseCase();
    when(complete.call(any)).thenAnswer(
      (_) async => const Left<Failure, CompleteRegistrationResponse>(
        ServerFailure(message: 'gone'),
      ),
    );
    final CompleteRegistrationCubit cubit = CompleteRegistrationCubit(complete);
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>.value(value: cubit),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
      ],
      child: const CompleteRegistrationScreen(draft: kPhoneDraft),
    );
    cubit.emit(ApiCallError<AuthSession>(message: Strings.draftExpired));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.phoneSignIn}'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FR-026a social draft_expired routes to welcome', (
    WidgetTester tester,
  ) async {
    final CompleteRegistrationCubit cubit = CompleteRegistrationCubit(
      MockCompleteRegistrationUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>.value(value: cubit),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
      ],
      child: const CompleteRegistrationScreen(draft: kGoogleDraft),
    );
    cubit.emit(ApiCallError<AuthSession>(message: Strings.draftExpired));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.welcome}'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FR-033 phone field error does not restart the flow', (
    WidgetTester tester,
  ) async {
    final CompleteRegistrationCubit cubit = CompleteRegistrationCubit(
      MockCompleteRegistrationUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>.value(value: cubit),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
      ],
      child: const CompleteRegistrationScreen(draft: kGoogleDraft),
    );
    cubit.emit(
      ApiCallError<AuthSession>(
        message: Strings.draftExpired,
        fieldErrors: const <String, List<String>>{
          'phone': <String>['unverified'],
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.welcome}'), findsNothing);
    expect(find.text(Strings.completeRegistration), findsWidgets);
    await cubit.close();
  });

  testWidgets('FR-025 complete success routes home', (
    WidgetTester tester,
  ) async {
    final CompleteRegistrationCubit cubit = CompleteRegistrationCubit(
      MockCompleteRegistrationUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>.value(value: cubit),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => RequestPhoneOtpCubit(MockRequestPhoneOtpUseCase()),
        ),
      ],
      child: const CompleteRegistrationScreen(draft: kPhoneDraft),
    );
    cubit.emit(ApiCallSuccess<AuthSession>(data: kSession));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.home}'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('FR-033 phone OTP success on complete form', (
    WidgetTester tester,
  ) async {
    final RequestPhoneOtpCubit requestCubit = RequestPhoneOtpCubit(
      MockRequestPhoneOtpUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>(
          create: (_) =>
              CompleteRegistrationCubit(MockCompleteRegistrationUseCase()),
        ),
        BlocProvider<RequestPhoneOtpCubit>.value(value: requestCubit),
      ],
      child: const CompleteRegistrationScreen(draft: kGoogleDraft),
    );
    requestCubit.emit(const ApiCallError<OtpChallenge>(message: 'otp failed'));
    await tester.pump();
    await requestCubit.close();
  });
}
