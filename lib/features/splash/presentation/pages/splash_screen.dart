import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/enums.dart';
import '../../../auth/presentation/controller/resolve_visitor_state/resolve_visitor_state_cubit.dart';
import '../../../auth/presentation/navigation/router.dart';
import '../../../home/presentation/navigation/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({this.sessionExpired = false, super.key});

  final bool sessionExpired;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ResolveVisitorStateCubit>().fResolveVisitorState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ResolveVisitorStateCubit, ResolveVisitorStateState>(
        listener: (BuildContext context, ResolveVisitorStateState state) {
          if (state case ApiCallSuccess<UserType>(:final data)) {
            switch (data) {
              case UserType.firstOpen:
                const WelcomeRoute().go(context);
              case UserType.loggedIn:
              case UserType.guest:
                HomeRoute(sessionExpired: widget.sessionExpired).go(context);
            }
          }
          if (state is ApiCallError) {
            const WelcomeRoute().go(context);
          }
        },
        builder: (BuildContext context, ResolveVisitorStateState state) {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
