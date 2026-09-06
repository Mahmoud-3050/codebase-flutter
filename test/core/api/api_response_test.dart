import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_response.dart';

void main() {
  test('isSuccess reads status: success', () {
    expect(
      ApiResponse.isSuccess(<String, dynamic>{'status': 'success'}),
      isTrue,
    );
  });

  test('isSuccess reads success: true', () {
    expect(ApiResponse.isSuccess(<String, dynamic>{'success': true}), isTrue);
  });

  test('isSuccess rejects other payloads', () {
    expect(
      ApiResponse.isSuccess(<String, dynamic>{'status': 'error'}),
      isFalse,
    );
    expect(ApiResponse.isSuccess('ok'), isFalse);
    expect(ApiResponse.isSuccess(null), isFalse);
  });

  test('messageOf reads a string message', () {
    expect(
      ApiResponse.messageOf(<String, dynamic>{'message': 'failed'}),
      'failed',
    );
    expect(ApiResponse.messageOf(<String, dynamic>{}), '');
  });
}
