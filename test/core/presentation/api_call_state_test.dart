import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/presentation/api_call_state.dart';

void main() {
  group('ApiCallState', () {
    test('isLoading is true only for ApiCallLoading', () {
      expect(const ApiCallLoading<int>().isLoading, isTrue);
      expect(const ApiCallHolding<int>().isLoading, isFalse);
      expect(const ApiCallSuccess<int>(data: 1).isLoading, isFalse);
      expect(const ApiCallError<int>(message: 'x').isLoading, isFalse);
      expect(const ApiCallEmpty<int>().isLoading, isFalse);
      expect(const ApiCallRefresh<int>().isLoading, isFalse);
      expect(const ApiCallPagination<int>(data: 1).isLoading, isFalse);
    });

    test('status getters match the variant', () {
      expect(const ApiCallHolding<int>().isHolding, isTrue);
      expect(const ApiCallSuccess<int>(data: 1).isSuccess, isTrue);
      expect(const ApiCallError<int>(message: 'x').isError, isTrue);
      expect(const ApiCallEmpty<int>().isEmpty, isTrue);
      expect(const ApiCallRefresh<int>(data: 1).isRefresh, isTrue);
      expect(const ApiCallPagination<int>(data: 1).isPagination, isTrue);
    });
  });
}
