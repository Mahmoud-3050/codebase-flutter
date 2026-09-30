import 'package:either/either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/presentation/api_call_state.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
import 'package:codebase/features/auth/domain/entities/registration_draft.dart';
import 'package:codebase/features/auth/domain/entities/social_sign_in_response.dart';
import 'package:codebase/features/auth/presentation/controller/guest_mode/guest_mode_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/read_registration_draft/read_registration_draft_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/social_sign_in/social_sign_in_cubit.dart';
import 'package:codebase/features/auth/presentation/pages/welcome_screen.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';
import 'auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, void>>(
      const Left<Failure, void>(ServerFailure()),
    );
    provideDummy<Either<Failure, SocialSignInResponse>>(
      const Left<Failure, SocialSignInResponse>(ServerFailure()),
    );
    provideDummy<Either<Failure, RegistrationDraft?>>(
      const Right<Failure, RegistrationDraft?>(null),
    );
  });
  tearDown(resetAuthWidget);

  BlocProvider<ReadRegistrationDraftCubit> draftProvider({
    RegistrationDraft? draft,
  }) {
    final MockReadRegistrationDraftUseCase useCase =
        MockReadRegistrationDraftUseCase();
    when(
      useCase.call(any),
    ).thenAnswer((_) async => Right<Failure, RegistrationDraft?>(draft));
    return BlocProvider<ReadRegistrationDraftCubit>(
      create: (_) => ReadRegistrationDraftCubit(useCase),
    );
  }

  Future<void> pumpWelcome(
    WidgetTester tester, {
    TargetPlatform? platform,
  }) async {
    final MockContinueAsGuestUseCase guest = MockContinueAsGuestUseCase();
    final MockSocialSignInUseCase social = MockSocialSignInUseCase();
    await pumpAuthWidget(
      tester,
      platform: platform,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>(create: (_) => GuestModeCubit(guest)),
        BlocProvider<SocialSignInCubit>(
          create: (_) => SocialSignInCubit(social),
        ),
        draftProvider(),
        draftProvider(),
      ],
      child: const WelcomeScreen(),
    );
  }

  testWidgets('FR-001 FR-037 welcome offers register, sign-in, phone, guest', (
    WidgetTester tester,
  ) async {
    await pumpWelcome(tester);
    expect(find.text(Strings.createAccount), findsOneWidget);
    expect(find.text(Strings.signIn), findsOneWidget);
    expect(find.text(Strings.signInWithPhone), findsOneWidget);
    expect(find.text(Strings.continueAsGuest), findsOneWidget);
    expect(find.text(Strings.signInWithGoogle), findsOneWidget);
  });

  testWidgets('FR-001 welcome buttons navigate and google/guest dispatch', (
    WidgetTester tester,
  ) async {
    final MockContinueAsGuestUseCase guest = MockContinueAsGuestUseCase();
    final MockSocialSignInUseCase social = MockSocialSignInUseCase();
    when(
      guest.call(any),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
    when(social.call(any)).thenAnswer(
      (_) async => const Left<Failure, SocialSignInResponse>(
        SocialSignInCancelledFailure(),
      ),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>(create: (_) => GuestModeCubit(guest)),
        BlocProvider<SocialSignInCubit>(
          create: (_) => SocialSignInCubit(social),
        ),
        draftProvider(),
      ],
      child: const WelcomeScreen(),
    );
    await tester.tap(find.text(Strings.createAccount));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.register}'), findsOneWidget);
  });

  testWidgets('FR-028 FR-037 google and guest actions fire', (
    WidgetTester tester,
  ) async {
    final MockContinueAsGuestUseCase guest = MockContinueAsGuestUseCase();
    final MockSocialSignInUseCase social = MockSocialSignInUseCase();
    when(
      guest.call(any),
    ).thenAnswer((_) async => const Left<Failure, void>(ServerFailure()));
    when(social.call(any)).thenAnswer(
      (_) async => const Left<Failure, SocialSignInResponse>(
        SocialSignInCancelledFailure(),
      ),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>(create: (_) => GuestModeCubit(guest)),
        BlocProvider<SocialSignInCubit>(
          create: (_) => SocialSignInCubit(social),
        ),
        draftProvider(),
      ],
      child: const WelcomeScreen(),
    );
    await tester.tap(find.text(Strings.signInWithGoogle));
    await tester.pump();
    await tester.tap(find.text(Strings.continueAsGuest));
    await tester.pump();
  });

  testWidgets('FR-029 Apple hidden on Android', (WidgetTester tester) async {
    await pumpWelcome(tester, platform: TargetPlatform.android);
    expect(find.text(Strings.signInWithApple), findsNothing);
  });

  testWidgets('FR-029 Apple shown on iOS', (WidgetTester tester) async {
    await pumpWelcome(tester, platform: TargetPlatform.iOS);
    expect(find.text(Strings.signInWithApple), findsOneWidget);
  });

  testWidgets('FR-001 welcome sign-in and phone navigate', (
    WidgetTester tester,
  ) async {
    await pumpWelcome(tester);
    await tester.tap(find.text(Strings.signIn));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.login}'), findsOneWidget);
  });

  testWidgets('FR-019 welcome phone button navigates', (
    WidgetTester tester,
  ) async {
    await pumpWelcome(tester);
    await tester.tap(find.text(Strings.signInWithPhone));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.phoneSignIn}'), findsOneWidget);
  });

  testWidgets('FR-028 social error snackbar and session home', (
    WidgetTester tester,
  ) async {
    final MockContinueAsGuestUseCase guest = MockContinueAsGuestUseCase();
    final MockSocialSignInUseCase social = MockSocialSignInUseCase();
    final SocialSignInCubit socialCubit = SocialSignInCubit(social);
    final GuestModeCubit guestCubit = GuestModeCubit(guest);
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>.value(value: guestCubit),
        BlocProvider<SocialSignInCubit>.value(value: socialCubit),
        draftProvider(),
      ],
      child: const WelcomeScreen(),
    );
    socialCubit.emit(const ApiCallError<AuthOutcome>(message: 'social boom'));
    await tester.pump();
    socialCubit.emit(
      ApiCallSuccess<AuthOutcome>(data: AuthSessionEstablished(kSession)),
    );
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.home}'), findsOneWidget);
    await socialCubit.close();
    await guestCubit.close();
  });

  testWidgets('FR-031 social registration_required routes to complete', (
    WidgetTester tester,
  ) async {
    final SocialSignInCubit socialCubit = SocialSignInCubit(
      MockSocialSignInUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>(
          create: (_) => GuestModeCubit(MockContinueAsGuestUseCase()),
        ),
        BlocProvider<SocialSignInCubit>.value(value: socialCubit),
        draftProvider(),
      ],
      child: const WelcomeScreen(),
    );
    socialCubit.emit(
      const ApiCallSuccess<AuthOutcome>(
        data: AuthRegistrationRequired(kGoogleDraft),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('routed:${AppRoutes.completeRegistration}'),
      findsOneWidget,
    );
    await socialCubit.close();
  });

  testWidgets('FR-037 guest success routes home', (WidgetTester tester) async {
    final GuestModeCubit guestCubit = GuestModeCubit(
      MockContinueAsGuestUseCase(),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>.value(value: guestCubit),
        BlocProvider<SocialSignInCubit>(
          create: (_) => SocialSignInCubit(MockSocialSignInUseCase()),
        ),
        draftProvider(),
      ],
      child: const WelcomeScreen(),
    );
    guestCubit.emit(const ApiCallSuccess<bool>(data: true));
    await tester.pumpAndSettle();
    expect(find.text('routed:${AppRoutes.home}'), findsOneWidget);
    await guestCubit.close();
  });

  testWidgets('FR-029 Apple on iOS dispatches', (WidgetTester tester) async {
    final MockSocialSignInUseCase social = MockSocialSignInUseCase();
    when(social.call(any)).thenAnswer(
      (_) async => const Left<Failure, SocialSignInResponse>(
        SocialSignInCancelledFailure(),
      ),
    );
    await pumpAuthWidget(
      tester,
      platform: TargetPlatform.iOS,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>(
          create: (_) => GuestModeCubit(MockContinueAsGuestUseCase()),
        ),
        BlocProvider<SocialSignInCubit>(
          create: (_) => SocialSignInCubit(social),
        ),
        draftProvider(),
      ],
      child: const WelcomeScreen(),
    );
    await tester.tap(find.text(Strings.signInWithApple));
    await tester.pump();
  });

  testWidgets('FR-026 welcome resumes stored registration draft', (
    WidgetTester tester,
  ) async {
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>(
          create: (_) => GuestModeCubit(MockContinueAsGuestUseCase()),
        ),
        BlocProvider<SocialSignInCubit>(
          create: (_) => SocialSignInCubit(MockSocialSignInUseCase()),
        ),
        draftProvider(draft: kPhoneDraft),
      ],
      child: const WelcomeScreen(),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('routed:${AppRoutes.completeRegistration}'),
      findsOneWidget,
    );
  });
}
