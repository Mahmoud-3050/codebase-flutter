import 'package:flutter/widgets.dart';

import '../../../../core/di/auth_data_scope_lease.dart';
import '../../../../injection_container.dart';
import '../../auth_injection.dart';

/// Mounts the auth data scope for this route.
///
/// [AuthDataScopeLease] pushes the scope on the first holder and drops it
/// when the last auth, splash, or home route disposes. The route
/// [FeatureScope] then registers only that screen's cubit and use case.
class AuthDataLayer extends StatefulWidget {
  const AuthDataLayer({required this.child, super.key});

  final Widget child;

  @override
  State<AuthDataLayer> createState() => _AuthDataLayerState();
}

class _AuthDataLayerState extends State<AuthDataLayer> {
  @override
  void initState() {
    super.initState();
    ServiceLocator.instance<AuthDataScopeLease>().acquire(
      register: registerAuthDataLayer,
    );
  }

  @override
  void dispose() {
    ServiceLocator.instance<AuthDataScopeLease>().release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
