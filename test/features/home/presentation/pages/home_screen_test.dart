import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/logout_response.dart';
import 'package:codebase/features/auth/presentation/controller/logout/logout_cubit.dart';
import 'package:codebase/features/home/presentation/pages/home_screen.dart';

import '../../../auth/mocks.mocks.dart';
import '../../../auth/presentation/pages/auth_widget_harness.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, LogoutResponse>>(
      const Left<Failure, LogoutResponse>(ServerFailure()),
    );
  });
  tearDown(resetAuthWidget);

  testWidgets('FR-039 FR-043 home has account-required and sign-out', (
    WidgetTester tester,
  ) async {
    final MockLogoutUseCase useCase = MockLogoutUseCase();
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LogoutCubit>(create: (_) => LogoutCubit(useCase)),
      ],
      child: const HomeScreen(),
    );
    expect(find.text(Strings.accountRequired), findsOneWidget);
    expect(find.text(Strings.logout), findsOneWidget);
  });

  testWidgets('FR-044 session_expired snackbar', (WidgetTester tester) async {
    final MockLogoutUseCase useCase = MockLogoutUseCase();
    await pumpAuthWidget(
      tester,
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LogoutCubit>(create: (_) => LogoutCubit(useCase)),
      ],
      child: const HomeScreen(sessionExpired: true),
    );
    await tester.pump();
    expect(find.text(Strings.sessionExpired), findsOneWidget);
  });
}
