import 'package:bloc_test/bloc_test.dart';
import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecases/usecase.dart';
import 'package:codebase/core/utils/values/strings.dart';
import 'package:codebase/features/profile/domain/entities/get_student_profile_response.dart';
import 'package:codebase/features/profile/presentation/controller/get_student_profile/get_student_profile_cubit.dart';

import '../../mocks.mocks.dart';

void main() {
  setUpAll(() {
    provideDummy<Either<Failure, GetStudentProfileResponse>>(
      const Left<Failure, GetStudentProfileResponse>(ServerFailure()),
    );
  });

  const Student tStudent = Student(
    id: 1,
    firstName: 'John',
    secondName: 'M',
    lastName: 'Doe',
    fullName: 'John M Doe',
    dialingCode: '+966',
    phone: '500000000',
    email: 'john@example.com',
    birthdate: '2000-01-01',
    cityId: 1,
    institute: 'University',
    major: 'CS',
    graduationDate: '2024-06-01',
    degreeId: 1,
    gpaFile: '',
    cvFile: '',
    image: '',
    gpaFilePath: '',
    cvFilePath: '',
    imagePath: '',
    guard: '',
    createdAt: '',
    verifiedAt: '',
    accessToken: null,
  );

  const GetStudentProfileResponse tResponse = GetStudentProfileResponse(
    status: 'success',
    message: 'ok',
    data: tStudent,
  );

  test('initial state is GetStudentProfileInitialState', () {
    final MockGetStudentProfileUseCase useCase = MockGetStudentProfileUseCase();
    final GetStudentProfileCubit cubit = GetStudentProfileCubit(useCase);

    expect(cubit.state, const GetStudentProfileInitialState());

    cubit.close();
  });

  blocTest<GetStudentProfileCubit, GetStudentProfileState>(
    'emits [Loading, Success] when use case returns Right',
    build: () {
      final MockGetStudentProfileUseCase useCase = MockGetStudentProfileUseCase();
      when(useCase.call(NoParams())).thenAnswer(
        (_) async => const Right<Failure, GetStudentProfileResponse>(tResponse),
      );
      return GetStudentProfileCubit(useCase);
    },
    act: (GetStudentProfileCubit cubit) => cubit.fGetStudentProfile(),
    expect: () => <GetStudentProfileState>[
      const GetStudentProfileLoadingState(),
      const GetStudentProfileSuccessState(data: tStudent),
    ],
  );

  blocTest<GetStudentProfileCubit, GetStudentProfileState>(
    'emits [Loading, Error] when use case returns Left',
    build: () {
      final MockGetStudentProfileUseCase useCase = MockGetStudentProfileUseCase();
      when(useCase.call(NoParams())).thenAnswer(
        (_) async => const Left<Failure, GetStudentProfileResponse>(
          ServerFailure(message: 'Server error'),
        ),
      );
      return GetStudentProfileCubit(useCase);
    },
    act: (GetStudentProfileCubit cubit) => cubit.fGetStudentProfile(),
    expect: () => <GetStudentProfileState>[
      const GetStudentProfileLoadingState(),
      const GetStudentProfileErrorState(message: 'Server error'),
    ],
  );

  blocTest<GetStudentProfileCubit, GetStudentProfileState>(
    'emits fallback error message when failure message is null',
    build: () {
      final MockGetStudentProfileUseCase useCase = MockGetStudentProfileUseCase();
      when(useCase.call(NoParams())).thenAnswer(
        (_) async => const Left<Failure, GetStudentProfileResponse>(
          ServerFailure(),
        ),
      );
      return GetStudentProfileCubit(useCase);
    },
    act: (GetStudentProfileCubit cubit) => cubit.fGetStudentProfile(),
    expect: () => <GetStudentProfileState>[
      const GetStudentProfileLoadingState(),
      GetStudentProfileErrorState(message: Strings.pleaseTryAgainLater),
    ],
  );
}
