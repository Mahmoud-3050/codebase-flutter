import '../../core/utils/extensions.dart';
import 'pagination_entity.dart';

final class PaginationMetaModel extends PaginationMeta {
  const PaginationMetaModel({
    required super.total,
    required super.count,
    required super.perPage,
    required super.currentPage,
    required super.totalPages,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      PaginationMetaModel(
        total: (json['total'] as Object?).toIntOrZero(),
        count: (json['count'] as Object?).toIntOrZero(),
        perPage: (json['per_page'] as Object?).toIntOrValue(1),
        currentPage: (json['current_page'] as Object?).toIntOrValue(1),
        totalPages: (json['total_pages'] as Object?).toIntOrValue(1),
      );
}
