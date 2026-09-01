import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/themes/extra_colors.dart';
import '../../../../core/utils/values/assets.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../core/widgets/app_elevated_button.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../controller/get_student_profile/get_student_profile_cubit.dart';
import '../controller/update_student_profile/update_student_profile_cubit.dart';
import '../widgets/student_profile_body.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GetStudentProfileCubit>().fGetStudentProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.foreground,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          Strings.studentProfile,
          style: TextStyles.of(size: 18, weight: .w500),
        ),
      ),
      body: BlocListener<UpdateStudentProfileCubit, UpdateStudentProfileState>(
        listener: (context, state) {
          if (state is UpdateStudentProfileSuccessState) {
            showAppSnackBar(
              context: context,
              message: Strings.yourAccountHasBeenSuccessfullyUpdated,
              type: .success,
            );
            context.read<GetStudentProfileCubit>().fGetStudentProfile();
          }
          if (state is UpdateStudentProfileErrorState) {
            showAppSnackBar(
              context: context,
              message: state.message,
              type: .error,
            );
          }
        },
        child: BlocBuilder<GetStudentProfileCubit, GetStudentProfileState>(
          builder: (context, state) => switch (state) {
            GetStudentProfileInitialState() ||
            GetStudentProfileLoadingState() => const _StudentProfileLoading(),
            GetStudentProfileErrorState(:final message) => _StudentProfileError(
              message: message,
              onRetry: () =>
                  context.read<GetStudentProfileCubit>().fGetStudentProfile(),
            ),
            GetStudentProfileSuccessState(:final data) =>
              data == null
                  ? _StudentProfileError(
                      message: Strings.pleaseTryAgainLater,
                      onRetry: () => context
                          .read<GetStudentProfileCubit>()
                          .fGetStudentProfile(),
                    )
                  : StudentProfileBody(student: data),
          },
        ),
      ),
    );
  }
}

class _StudentProfileLoading extends StatelessWidget {
  const _StudentProfileLoading();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      child: Padding(
        padding: .all(16.w),
        child: Column(
          children: [
            CircleAvatar(radius: 44.r, backgroundColor: colors.grey200),
            SizedBox(height: 16.h),
            Container(
              height: 18.h,
              width: 160.w,
              decoration: BoxDecoration(
                color: colors.grey200,
                borderRadius: .circular(8.r),
              ),
            ),
            SizedBox(height: 24.h),
            ...List<Widget>.generate(
              4,
              (_) => Padding(
                padding: .only(bottom: 16.h),
                child: Container(
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: colors.grey200,
                    borderRadius: .circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentProfileError extends StatelessWidget {
  const _StudentProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(16.w),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          EmptyWidget(
            iconSvg: Assets.iconsUserEdit,
            title: Strings.studentProfile,
            message: message,
          ),
          SizedBox(height: 24.h),
          AppElevatedButton(text: Strings.confirm, onPressed: onRetry),
        ],
      ),
    );
  }
}
