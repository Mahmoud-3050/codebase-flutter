import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/values/assets.dart';
import '../../../../core/utils/values/text_styles.dart';
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
import '../widgets/auth_scaffold.dart';

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
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: _WelcomeScrollBody(
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
            child: const _WelcomeBody(),
          ),
        ),
      ),
    );
  }
}

/// Keeps the entry content centered, readable on wide windows, and
/// scrollable when large text or a short window leaves too little height.
class _WelcomeScrollBody extends StatelessWidget {
  const _WelcomeScrollBody({required this.child});

  static const double _maxContentWidth = AuthLayout.maxContentWidth;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Padding(padding: EdgeInsets.all(24.w), child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WelcomeBody extends StatelessWidget {
  const _WelcomeBody();

  static const Key loadingKey = Key('welcome-draft-loading');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadRegistrationDraftCubit, ReadRegistrationDraftState>(
      builder: (BuildContext context, ReadRegistrationDraftState state) {
        final bool waiting = switch (state) {
          ApiCallHolding<RegistrationDraft?>() ||
          ApiCallLoading<RegistrationDraft?>() => true,
          _ => false,
        };
        if (waiting) {
          return Semantics(
            label: Strings.loading,
            liveRegion: true,
            child: const Center(
              child: CircularProgressIndicator(key: loadingKey),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _WelcomeHeader(),
            SizedBox(height: 32.h),
            const _WelcomeEntryActions(),
            SizedBox(height: 8.h),
            const _OrDivider(),
            SizedBox(height: 20.h),
            const _SocialAndGuestActions(),
          ],
        );
      },
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  static const double _markAlpha = 0.12;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ExcludeSemantics(
          child: Container(
            width: 72.r,
            height: 72.r,
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: _markAlpha),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              Assets.iconsJobs,
              colorFilter: ColorFilterExtension.setColor(colors.primary),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Semantics(
          header: true,
          child: Text(
            Strings.appName,
            textAlign: TextAlign.center,
            style: TextStyles.of(
              size: 32,
              weight: FontWeight.w700,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          Strings.welcomeSubtitle,
          textAlign: TextAlign.center,
          style: TextStyles.of(
            size: 16,
            color: colors.textSecondary,
            height: AuthLayout.bodyLineHeight,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  static const double _lineAlpha = 0.3;

  @override
  Widget build(BuildContext context) {
    final Color lineColor = context.colors.textSecondary.withValues(
      alpha: _lineAlpha,
    );
    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: lineColor)),
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              Strings.orContinueWith,
              textAlign: TextAlign.center,
              style: TextStyles.of(
                size: 14,
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor)),
      ],
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
          maxLines: 2,
          onPressed: () => const RegisterRoute().go(context),
        ),
        SizedBox(height: 12.h),
        AppElevatedButton(
          text: Strings.signIn,
          maxLines: 2,
          onPressed: () => const LoginRoute().go(context),
        ),
        SizedBox(height: 12.h),
        AppElevatedButton(
          text: Strings.signInWithPhone,
          maxLines: 2,
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
      child: BlocSelector<SocialSignInCubit, SocialSignInState, bool>(
        selector: (SocialSignInState state) => state.isLoading,
        builder: (BuildContext context, bool socialLoading) {
          return BlocSelector<GuestModeCubit, GuestModeState, bool>(
            selector: (GuestModeState state) => state.isLoading,
            builder: (BuildContext context, bool guestLoading) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _BusyAuthButton(
                    text: Strings.signInWithGoogle,
                    socialLoading: socialLoading,
                    guestLoading: guestLoading,
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
                      socialLoading: socialLoading,
                      guestLoading: guestLoading,
                      onPressed: (BuildContext context) => context
                          .read<SocialSignInCubit>()
                          .fSocialSignIn(SocialProvider.apple),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  _BusyAuthButton(
                    text: Strings.continueAsGuest,
                    socialLoading: socialLoading,
                    guestLoading: guestLoading,
                    showGuestSpinner: true,
                    onPressed: (BuildContext context) =>
                        context.read<GuestModeCubit>().fContinueAsGuest(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _BusyAuthButton extends StatelessWidget {
  const _BusyAuthButton({
    required this.text,
    required this.onPressed,
    required this.socialLoading,
    required this.guestLoading,
    this.showSocialSpinner = false,
    this.showGuestSpinner = false,
  });

  final String text;
  final void Function(BuildContext context) onPressed;
  final bool socialLoading;
  final bool guestLoading;
  final bool showSocialSpinner;
  final bool showGuestSpinner;

  @override
  Widget build(BuildContext context) {
    final bool busy = socialLoading || guestLoading;
    final bool isLoading =
        (showSocialSpinner && socialLoading) ||
        (showGuestSpinner && guestLoading);
    return AppElevatedButton(
      text: text,
      maxLines: 2,
      enabled: !busy,
      isLoading: isLoading,
      onPressed: () => onPressed(context),
    );
  }
}
