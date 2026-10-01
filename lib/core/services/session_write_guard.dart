/// Tracks an in-flight session write so a guest read cannot delete a token
/// that sign-in has saved but not yet marked as logged in.
abstract interface class SessionWriteGuard {
  bool get isSessionWriteInProgress;

  Future<T> guardSessionWrite<T>(Future<T> Function() action);
}

/// Used when no shared visitor state is registered, such as unit tests.
final class IdleSessionWriteGuard implements SessionWriteGuard {
  const IdleSessionWriteGuard();

  @override
  bool get isSessionWriteInProgress => false;

  @override
  Future<T> guardSessionWrite<T>(Future<T> Function() action) => action();
}

/// Process-wide counter for in-flight session writes.
final class CountingSessionWriteGuard implements SessionWriteGuard {
  int _sessionWrites = 0;

  @override
  bool get isSessionWriteInProgress => _sessionWrites > 0;

  @override
  Future<T> guardSessionWrite<T>(Future<T> Function() action) async {
    _sessionWrites++;
    try {
      return await action();
    } finally {
      _sessionWrites--;
    }
  }
}
