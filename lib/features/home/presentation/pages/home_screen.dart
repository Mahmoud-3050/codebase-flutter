import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/strings.dart';
import '../../../auth/presentation/controller/logout/logout_cubit.dart';
import '../../../auth/presentation/navigation/router.dart';
import '../../../auth/presentation/widgets/guest_gate_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.sessionExpired = false, super.key});

  final bool sessionExpired;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.sessionExpired) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Strings.sessionExpired)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.home)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () => context.requireAccount(),
              child: Text(Strings.accountRequired),
            ),
            BlocListener<LogoutCubit, LogoutState>(
              listener: (BuildContext context, LogoutState state) {
                if (state.isSuccess) {
                  const WelcomeRoute().go(context);
                }
              },
              child: TextButton(
                onPressed: () => context.read<LogoutCubit>().fLogout(),
                child: Text(Strings.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
