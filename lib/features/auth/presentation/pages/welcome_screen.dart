import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../config/routes/auth_navigation.dart';
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
                        openAuthenticatedDestination(context);
                      case AuthRegistrationRequired(:final draft):
                        CompleteRegistrationRoute($extra: draft).go(context);
                    }
                  }
                },
              ),
            ],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Spacer(),
                _WelcomeEntryActions(),
                _SocialAndGuestActions(),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeEntryActions extends StatelessWidget {
  const _WelcomeEntryActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
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
      ],
    );
  }
}

class _SocialAndGuestActions extends StatelessWidget {
  const _SocialAndGuestActions();

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestModeCubit, GuestModeState>(
      listener: (BuildContext context, GuestModeState state) {
        if (state case ApiCallError(:final message)) {
          showAppSnackBar(
            context: context,
            message: message,
            type: ToastType.error,
          );
        }
        if (state.isSuccess) {
          openGuestDestination(context);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _BusyAuthButton(
            text: Strings.signInWithGoogle,
            showSocialSpinner: true,
            onPressed: (BuildContext context) => context
                .read<SocialSignInCubit>()
                .fSocialSignIn(SocialProvider.google),
          ),
          if (SocialProviderAvailability.isOffered(
            SocialProvider.apple,
            platform: Theme.of(context).platform,
          )) ...<Widget>[
            SizedBox(height: 12.h),
            _BusyAuthButton(
              text: Strings.signInWithApple,
              onPressed: (BuildContext context) => context
                  .read<SocialSignInCubit>()
                  .fSocialSignIn(SocialProvider.apple),
            ),
          ],
          SizedBox(height: 12.h),
          _BusyAuthButton(
            text: Strings.continueAsGuest,
            showGuestSpinner: true,
            onPressed: (BuildContext context) =>
                context.read<GuestModeCubit>().fContinueAsGuest(),
          ),
        ],
      ),
    );
  }
}

class _BusyAuthButton extends StatelessWidget {
  const _BusyAuthButton({
    required this.text,
    required this.onPressed,
    this.showSocialSpinner = false,
    this.showGuestSpinner = false,
  });

  final String text;
  final void Function(BuildContext context) onPressed;
  final bool showSocialSpinner;
  final bool showGuestSpinner;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SocialSignInCubit, SocialSignInState, bool>(
      selector: (SocialSignInState state) => state.isLoading,
      builder: (BuildContext context, bool socialLoading) {
        return BlocSelector<GuestModeCubit, GuestModeState, bool>(
          selector: (GuestModeState state) => state.isLoading,
          builder: (BuildContext context, bool guestLoading) {
            final bool isLoading =
                (showSocialSpinner && socialLoading) ||
                (showGuestSpinner && guestLoading);
            return Semantics(
              liveRegion: true,
              child: AppElevatedButton(
                text: text,
                enabled: !busy,
                isLoading: isLoading,
                onPressed: () => onPressed(context),
              ),
            );
          },
        );
      },
    );
  }
}
