import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../navigation/router.dart';
import 'auth_scaffold.dart';
import 'auth_tap_target.dart';

Future<void> showGuestGateDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      final ThemeColors colors = dialogContext.colors;
      return AlertDialog(
        backgroundColor: colors.foreground,
        title: Text(
          Strings.accountRequired,
          style: TextStyles.of(size: 18, weight: FontWeight.w600),
        ),
        content: Text(
          Strings.accountRequiredMessage,
          style: TextStyles.of(
            size: 16,
            color: colors.textSecondary,
            height: AuthLayout.bodyLineHeight,
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: authTextButtonStyle(),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              const LoginRoute().go(context);
            },
            child: Text(
              Strings.signIn,
              style: TextStyles.of(size: 14, color: colors.primary),
            ),
          ),
          TextButton(
            style: authTextButtonStyle(),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              const RegisterRoute().go(context);
            },
            child: Text(
              Strings.createAccount,
              style: TextStyles.of(size: 14, color: colors.primary),
            ),
          ),
        ],
      );
    },
  );
}

extension GuestGateContext on BuildContext {
  Future<void> requireAccount() => showGuestGateDialog(this);
}
