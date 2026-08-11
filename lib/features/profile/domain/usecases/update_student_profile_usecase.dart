import 'package:equatable/equatable.dart';
import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/update_student_profile_response.dart';
import '../repositories/profile_repo.dart';


class UpdateStudentProfileUseCase extends UseCase<UpdateStudentProfileResponse, UpdateStudentProfileParams> {
  final ProfileRepository repository;

  UpdateStudentProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, UpdateStudentProfileResponse>> call(UpdateStudentProfileParams params) async {
    return await repository.updateStudentProfile(params: params);
  }
}


class UpdateStudentProfileParams extends Equatable {
  final String? firstName;
  final String? secondName;
  final String? lastName;
  final String? dialingCode;
  final String? phone;
  final int? cityId;
  final String? birthdate;
  final String? image;
  final String? institute;
  final int? degreeId;
  final int? majorId;
  final String? graduationDate;
  final String? gpaFile;
  final String? cvFile;

  const UpdateStudentProfileParams({
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.dialingCode,
    required this.phone,
    required this.cityId,
    required this.birthdate,
    required this.image,
    required this.institute,
    required this.degreeId,
    required this.majorId,
    required this.graduationDate,
    required this.gpaFile,
    required this.cvFile,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (firstName != null) {
      map['first_name'] = firstName;
    }
    if (secondName != null) {
      map['second_name'] = secondName;
    }
    if (lastName != null) {
      map['last_name'] = lastName;
    }
    if (dialingCode != null) {
      map['dialing_code'] = dialingCode;
    }
    if (phone != null) {
      map['phone'] = phone;
    }
    if (cityId != null) {
      map['city_id'] = cityId;
    }
    if (birthdate != null) {
      map['birthdate'] = birthdate;
    }
    if (image != null) {
      map['image'] = image;
    }
    if (institute != null) {
      map['institute'] = institute;
    }
    if (degreeId != null) {
      map['degree_id'] = degreeId;
    }
    if (majorId != null) {
      map['major_id'] = majorId;
    }
    if (graduationDate != null) {
      map['graduation_date'] = graduationDate;
    }
    if (gpaFile != null) {
      map['gpa_file'] = gpaFile;
    }
    if (cvFile != null) {
      map['cv_file'] = cvFile;
    }
    return map;
  }

  @override
  List<Object?> get props => <Object?>[
    firstName,
    secondName,
    lastName,
    dialingCode,
    phone,
    cityId,
    birthdate,
    image,
    institute,
    degreeId,
    majorId,
    graduationDate,
    gpaFile,
    cvFile,
  ];

}



