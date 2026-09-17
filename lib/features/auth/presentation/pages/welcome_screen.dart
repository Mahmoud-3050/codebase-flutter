import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../home/presentation/navigation/router.dart';
import '../../domain/entities/auth_outcome.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/enums/social_provider.dart';
import '../controller/guest_mode/guest_mode_cubit.dart';
import '../controller/read_registration_draft/read_registration_draft_cubit.dart';
import '../controller/social_sign_in/social_sign_in_cubit.dart';
import '../navigation/router.dart';
import '../social_provider_availability.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ReadRegistrationDraftCubit>().fReadRegistrationDraft();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: MultiBlocListener(
            listeners: <BlocListener<dynamic, dynamic>>[
              BlocListener<
                ReadRegistrationDraftCubit,
                ReadRegistrationDraftState
              >(
                listener:
                    (BuildContext context, ReadRegistrationDraftState state) {
                      if (state case ApiCallSuccess<RegistrationDraft?>(
                        :final data,
                      )) {
                        if (data == null) {
                          return;
                        }
                        CompleteRegistrationRoute($extra: data).go(context);
                      }
                    },
              ),
              BlocListener<SocialSignInCubit, SocialSignInState>(
                listener: (BuildContext context, SocialSignInState state) {
                  if (state case ApiCallError(:final message)) {
                    showAppSnackBar(
                      context: context,
                      message: message,
                      type: ToastType.error,
                    );
                  }
                  if (state case ApiCallSuccess<AuthOutcome>(:final data)) {
                    switch (data) {
                      case AuthSessionEstablished():
                        const HomeRoute().go(context);
                      case AuthRegistrationRequired(:final draft):
                        CompleteRegistrationRoute($extra: draft).go(context);
                    }
                  }
                },
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(),
                AppElevatedButton(
                  text: Strings.createAccount,
                  onPressed: () => const RegisterRoute().go(context),
                ),
                SizedBox(height: 12.h),
                AppElevatedButton(
                  text: Strings.signIn,
                  onPressed: () => const LoginRoute().go(context),
                ),
                SizedBox(height: 12.h),
                AppElevatedButton(
                  text: Strings.signInWithPhone,
                  onPressed: () => const PhoneSignInRoute().go(context),
                ),
                SizedBox(height: 12.h),
                AppElevatedButton(
                  text: Strings.signInWithGoogle,
                  onPressed: () => context
                      .read<SocialSignInCubit>()
                      .fSocialSignIn(SocialProvider.google),
                ),
                if (SocialProviderAvailability.isOffered(
                  SocialProvider.apple,
                  platform: Theme.of(context).platform,
                )) ...<Widget>[
                  SizedBox(height: 12.h),
                  AppElevatedButton(
                    text: Strings.signInWithApple,
                    onPressed: () => context
                        .read<SocialSignInCubit>()
                        .fSocialSignIn(SocialProvider.apple),
                  ),
                ],
                SizedBox(height: 12.h),
                BlocConsumer<GuestModeCubit, GuestModeState>(
                  listener: (BuildContext context, GuestModeState state) {
                    if (state.isSuccess) {
                      const HomeRoute().go(context);
                    }
                  },
                  builder: (BuildContext context, GuestModeState state) {
                    return AppElevatedButton(
                      text: Strings.continueAsGuest,
                      isLoading: state.isLoading,
                      onPressed: () =>
                          context.read<GuestModeCubit>().fContinueAsGuest(),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
