import 'dart:async';

import 'package:get_it/get_it.dart';

/// Keeps the auth datasources and repository in one GetIt scope.
///
/// [acquire] pushes that scope on the first holder. [release] drops it when
/// the last holder leaves. A route that arrives while the drop is still in
/// progress gets a new scope, so the in-flight drop cannot remove the
/// repository the new route just resolved.
final class AuthDataScopeLease {
  AuthDataScopeLease(this._sl);

  final GetIt _sl;

  int _holders = 0;
  int _nextId = 0;
  String? _activeScopeName;
  String? _retiringScopeName;
  Future<void>? _retiringDrop;

  void acquire({required void Function(GetIt sl) register}) {
    if (!_activeScopeReady) {
      final String name = 'AuthDataScope-$_nextId';
      _nextId++;
      _sl.pushNewScope(scopeName: name, init: register, isFinal: true);
      _activeScopeName = name;
    }
    _holders++;
  }

  void release() {
    if (_holders == 0) {
      return;
    }
    _holders--;
    if (_holders > 0) {
      return;
    }
    final String? name = _activeScopeName;
    if (name == null || !_sl.hasScope(name)) {
      _activeScopeName = null;
      return;
    }
    _retiringScopeName = name;
    final Future<void> drop = _sl.dropScope(name);
    _retiringDrop = drop;
    unawaited(
      drop.whenComplete(() {
        if (!identical(_retiringDrop, drop)) {
          return;
        }
        _retiringDrop = null;
        _retiringScopeName = null;
        if (_activeScopeName == name) {
          _activeScopeName = null;
        }
      }),
    );
  }

  bool get _activeScopeReady {
    final String? name = _activeScopeName;
    return name != null && name != _retiringScopeName && _sl.hasScope(name);
  }
}
