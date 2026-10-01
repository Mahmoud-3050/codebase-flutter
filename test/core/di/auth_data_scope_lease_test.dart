import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:codebase/core/di/auth_data_scope_lease.dart';

final class _Marker {
  const _Marker(this.id);

  final int id;
}

void main() {
  late GetIt sl;
  late AuthDataScopeLease lease;
  var nextId = 0;

  void registerMarker(GetIt scope) {
    scope.registerSingleton<_Marker>(_Marker(nextId));
  }

  setUp(() {
    sl = GetIt.asNewInstance();
    lease = AuthDataScopeLease(sl);
    nextId = 0;
  });

  test('a second holder does not drop the scope', () async {
    nextId = 1;
    lease.acquire(register: registerMarker);
    lease.acquire(register: registerMarker);
    lease.release();
    await Future<void>.delayed(Duration.zero);
    expect(sl<_Marker>().id, 1);
    lease.release();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(sl.isRegistered<_Marker>(), isFalse);
  });

  test('a new holder during a drop gets its own scope', () async {
    nextId = 1;
    lease.acquire(register: registerMarker);
    lease.release();
    nextId = 2;
    lease.acquire(register: registerMarker);
    expect(sl<_Marker>().id, 2);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(sl.isRegistered<_Marker>(), isTrue);
    expect(sl<_Marker>().id, 2);
    lease.release();
  });
}
