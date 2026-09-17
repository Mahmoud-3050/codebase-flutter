import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:either/either.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/login_response.dart';
import 'package:codebase/features/auth/presentation/controller/login/login_cubit.dart';

import '../../test/features/auth/mocks.mocks.dart';
import '../../test/features/auth/presentation/pages/auth_widget_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FR-014 login screen is reachable without an OTP field', (
    WidgetTester tester,
  ) async {
    provideDummy<Either<Failure, LoginResponse>>(
      const Left<Failure, LoginResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LoginCubit>(create: (_) => LoginCubit(MockLoginUseCase())),
      ],
      child: const LoginScreen(),
    );
    expect(find.text(Strings.signIn), findsWidgets);
    expect(find.text(Strings.forgotPassword), findsOneWidget);
  });
}
