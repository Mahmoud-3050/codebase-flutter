import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/request_cancel_token.dart';

void main() {
  test('returns the CancelToken when the handle is one', () {
    final CancelToken token = CancelToken();
    expect(requestCancelToken(token), same(token));
  });

  test('returns null for other handle types', () {
    expect(requestCancelToken(null), isNull);
    expect(requestCancelToken('id'), isNull);
  });
}
