import 'package:flutter/material.dart';

import '../../../../config/language/strings.dart';
import '../navigation/router.dart';

Future<void> showGuestGateDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(Strings.accountRequired),
        content: Text(Strings.accountRequiredMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              const LoginRoute().go(context);
            },
            child: Text(Strings.signIn),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              const RegisterRoute().go(context);
            },
            child: Text(Strings.createAccount),
          ),
        ],
      );
    },
  );
}

extension GuestGateContext on BuildContext {
  Future<void> requireAccount() => showGuestGateDialog(this);
}
