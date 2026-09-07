import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/shared/pagination/pagination_entity.dart';

void main() {
  group('PaginationMeta', () {
    test('hasMore is true while currentPage is below totalPages', () {
      const PaginationMeta meta = PaginationMeta(
        total: 20,
        count: 10,
        perPage: 10,
        currentPage: 1,
        totalPages: 2,
      );
      expect(meta.hasMore, isTrue);
    });

    test('hasMore is false on the last page', () {
      const PaginationMeta meta = PaginationMeta(
        total: 20,
        count: 10,
        perPage: 10,
        currentPage: 2,
        totalPages: 2,
      );
      expect(meta.hasMore, isFalse);
    });

    test('initial has no further pages', () {
      expect(PaginationMeta.initial.hasMore, isFalse);
      expect(PaginationMeta.initial.perPage, PaginationMeta.defaultPerPage);
      expect(PaginationMeta.initial.currentPage, PaginationMeta.defaultPage);
    });
  });
}
