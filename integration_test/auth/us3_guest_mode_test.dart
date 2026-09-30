import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/features/auth/presentation/pages/welcome_screen.dart';
import 'package:codebase/features/auth/presentation/controller/guest_mode/guest_mode_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/social_sign_in/social_sign_in_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:either/either.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/social_sign_in_response.dart';

import '../../test/features/auth/mocks.mocks.dart';
import '../../test/features/auth/presentation/pages/auth_widget_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FR-037 FR-040 guest continue is offered on welcome', (
    WidgetTester tester,
  ) async {
    provideDummy<Either<Failure, void>>(
      const Left<Failure, void>(ServerFailure()),
    );
    provideDummy<Either<Failure, SocialSignInResponse>>(
      const Left<Failure, SocialSignInResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>(
          create: (_) => GuestModeCubit(MockContinueAsGuestUseCase()),
        ),
        BlocProvider<SocialSignInCubit>(
          create: (_) => SocialSignInCubit(MockSocialSignInUseCase()),
        ),
      ],
      child: const WelcomeScreen(),
    );
    expect(find.text(Strings.continueAsGuest), findsOneWidget);
  });
}
