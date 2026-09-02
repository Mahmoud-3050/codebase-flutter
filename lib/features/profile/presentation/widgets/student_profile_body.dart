import 'package:field_validator/field_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/themes/extra_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../core/widgets/app_elevated_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/profile_picture.dart';
import '../../domain/entities/get_student_profile_response.dart';
import '../controller/update_student_profile/update_student_profile_cubit.dart';

class StudentProfileBody extends StatefulWidget {
  const StudentProfileBody({required this.student, super.key});

  final Student student;

  @override
  State<StudentProfileBody> createState() => _StudentProfileBodyState();
}

class _StudentProfileBodyState extends State<StudentProfileBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _instituteController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.student.firstName,
    );
    _middleNameController = TextEditingController(
      text: widget.student.secondName,
    );
    _lastNameController = TextEditingController(text: widget.student.lastName);
    _emailController = TextEditingController(text: widget.student.email);
    _phoneController = TextEditingController(text: widget.student.phone);
    _instituteController = TextEditingController(
      text: widget.student.institute,
    );
  }

  @override
  void didUpdateWidget(covariant StudentProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student == widget.student) return;
    _firstNameController.text = widget.student.firstName;
    _middleNameController.text = widget.student.secondName;
    _lastNameController.text = widget.student.lastName;
    _emailController.text = widget.student.email;
    _phoneController.text = widget.student.phone;
    _instituteController.text = widget.student.institute;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _instituteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: .all(16.w),
        children: [
          _StudentProfileHeader(student: widget.student),
          24.hGap,
          Text(
            Strings.personalData,
            style: TextStyles.of(size: 16, weight: .w600),
          ),
          12.hGap,
          AppTextFormField.nameTextField(
            controller: _firstNameController,
            hintText: Strings.firstName,
            labelText: Strings.firstName,
            validatorType: FieldValidator.combine(const [
              EmptyValidator(),
              TextOnlyValidator(),
            ]),
          ),
          SizedBox(height: 16.h),
          AppTextFormField.nameTextField(
            controller: _middleNameController,
            hintText: Strings.middleName,
            labelText: Strings.middleName,
            validatorType: const TextOnlyValidator(required: false),
          ),
          SizedBox(height: 16.h),
          AppTextFormField.nameTextField(
            controller: _lastNameController,
            hintText: Strings.lastName,
            labelText: Strings.lastName,
            validatorType: FieldValidator.combine(const [
              EmptyValidator(),
              TextOnlyValidator(),
            ]),
          ),
          SizedBox(height: 16.h),
          AppTextFormField.emailTextField(
            controller: _emailController,
            hintText: Strings.email,
            labelText: Strings.email,
            readOnly: true,
            validatorType: FieldValidator.email(),
          ),
          SizedBox(height: 16.h),
          AppTextFormField.phoneTextField(
            controller: _phoneController,
            hintText: Strings.phoneNumber,
            labelText: Strings.phoneNumber,
            validatorType: FieldValidator.phone(),
          ),
          SizedBox(height: 16.h),
          AppTextFormField(
            controller: _instituteController,
            hintText: Strings.educationalInstitute,
            labelText: Strings.educationalInstitute,
            prefixIcon: Icons.school_rounded,
            validatorType: FieldValidator.required(
              customError: Strings.errorFieldRequired,
            ),
          ),
          SizedBox(height: 32.h),
          BlocBuilder<UpdateStudentProfileCubit, UpdateStudentProfileState>(
            builder: (context, state) {
              final isSaving = state is UpdateStudentProfileLoadingState;
              if (isSaving) {
                return SizedBox(
                  height: 48.h,
                  child: Center(
                    child: const CircularProgressIndicator().appLoading,
                  ),
                );
              }
              return AppElevatedButton(text: Strings.save, onPressed: _onSave);
            },
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final student = widget.student;
    context.read<UpdateStudentProfileCubit>().fUpdateStudentProfile(
      firstName: _firstNameController.text.trim(),
      secondName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dialingCode: student.dialingCode,
      phone: _phoneController.text.trim(),
      cityId: student.cityId,
      birthdate: student.birthdate,
      image: _imageValue(student),
      institute: _instituteController.text.trim(),
      degreeId: student.degreeId,
      majorId: int.tryParse(student.major) ?? 0,
      graduationDate: student.graduationDate,
      gpaFile: student.gpaFile,
      cvFile: student.cvFile,
    );
  }

  String _imageValue(Student student) {
    final image = student.image;
    if (image is String && image.isNotEmpty) return image;
    return student.imagePath;
  }
}

class _StudentProfileHeader extends StatelessWidget {
  const _StudentProfileHeader({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: .infinity,
      padding: Paddings.symmetric(h: 16, v: 20),
      decoration: BoxDecoration(
        color: colors.foreground,
        borderRadius: .circular(16.r),
        border: .all(color: colors.divider),
      ),
      child: Column(
        children: [
          ProfilePicture(
            imageUrl: _avatarUrl,
            width: 88.w,
            height: 88.h,
            backgroundColor: colors.grey100,
            placeholderColor: colors.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            student.fullName,
            style: TextStyles.of(size: 18, weight: .w600),
            textAlign: .center,
          ),
          SizedBox(height: 4.h),
          Text(
            student.email,
            style: TextStyles.of(size: 14, color: colors.textSecondary),
            textAlign: .center,
          ),
        ],
      ),
    );
  }

  String? get _avatarUrl {
    if (student.imagePath.isNotEmpty) return student.imagePath;
    final image = student.image;
    if (image is String && image.isNotEmpty) return image;
    return null;
  }
}
