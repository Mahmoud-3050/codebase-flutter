import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:codebase/features/auth/presentation/controller/request_password_reset/request_password_reset_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:either/either.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/request_password_reset_response.dart';

import '../../test/features/auth/mocks.mocks.dart';
import '../../test/features/auth/presentation/pages/auth_widget_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FR-046 forgot-password path is reachable', (
    WidgetTester tester,
  ) async {
    provideDummy<Either<Failure, RequestPasswordResetResponse>>(
      const Left<Failure, RequestPasswordResetResponse>(ServerFailure()),
    );
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RequestPasswordResetCubit>(
          create: (_) =>
              RequestPasswordResetCubit(MockRequestPasswordResetUseCase()),
        ),
      ],
      child: const ForgotPasswordScreen(),
    );
    expect(find.text(Strings.forgotPassword), findsWidgets);
  });
}
