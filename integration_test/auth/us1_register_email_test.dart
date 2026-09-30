import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/features/auth/presentation/pages/register_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:either/either.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/register_response.dart';
import 'package:codebase/features/auth/presentation/controller/register/register_cubit.dart';

import '../../test/features/auth/mocks.mocks.dart';
import '../../test/features/auth/presentation/pages/auth_widget_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FR-005 register screen is reachable for email signup', (
    WidgetTester tester,
  ) async {
    provideDummy<Either<Failure, RegisterResponse>>(
      const Left<Failure, RegisterResponse>(ServerFailure()),
    );
    final MockRegisterUseCase useCase = MockRegisterUseCase();
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>(create: (_) => RegisterCubit(useCase)),
      ],
      child: const RegisterScreen(),
    );
    expect(find.text(Strings.createAccount), findsWidgets);
  });
}
