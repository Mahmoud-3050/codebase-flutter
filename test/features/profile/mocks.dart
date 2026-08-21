import 'package:mockito/annotations.dart';

import 'package:codebase/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:codebase/features/profile/domain/usecases/get_student_profile_usecase.dart';

@GenerateMocks(<Type>[
  ProfileRemoteDataSource,
  GetStudentProfileUseCase,
])
void main() {}
