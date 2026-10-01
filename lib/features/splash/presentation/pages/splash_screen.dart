import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/enums.dart';
import '../../../auth/presentation/controller/resolve_visitor_state/resolve_visitor_state_cubit.dart';
import '../../../../config/routes/auth_navigation.dart';

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
            openResolvedDestination(
              context,
              data,
              sessionExpired: widget.sessionExpired,
            );
          }
        },
        builder: (BuildContext context, ResolveVisitorStateState state) {
          if (state case ApiCallError(:final message)) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(message),
                  TextButton(
                    onPressed: () => context
                        .read<ResolveVisitorStateCubit>()
                        .fResolveVisitorState(),
                    child: Text(Strings.pleaseTryAgainLater),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
