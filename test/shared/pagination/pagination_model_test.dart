import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/shared/pagination/pagination_model.dart';

void main() {
  group('PaginationMetaModel.fromJson', () {
    test('parses numeric and string values', () {
      final PaginationMetaModel meta = PaginationMetaModel.fromJson(
        const <String, dynamic>{
          'total': '20',
          'count': 10,
          'per_page': '10',
          'current_page': 2,
          'total_pages': '4',
        },
      );

      expect(meta.total, 20);
      expect(meta.count, 10);
      expect(meta.perPage, 10);
      expect(meta.currentPage, 2);
      expect(meta.totalPages, 4);
      expect(meta.hasMore, isTrue);
    });

    test('uses fallbacks when keys are missing', () {
      final PaginationMetaModel meta = PaginationMetaModel.fromJson(
        const <String, dynamic>{},
      );

      expect(meta.total, 0);
      expect(meta.count, 0);
      expect(meta.perPage, 1);
      expect(meta.currentPage, 1);
      expect(meta.totalPages, 1);
      expect(meta.hasMore, isFalse);
    });
  });
}
