import 'package:equatable/equatable.dart';

class PaginationMeta extends Equatable {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  const PaginationMeta({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  PaginationMeta copyWith({
    int? total,
    int? count,
    int? perPage,
    int? currentPage,
    int? totalPages,
  }) {
    return PaginationMeta(
      total: total ?? this.total,
      count: count ?? this.count,
      perPage: perPage ?? this.perPage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    total,
    count,
    perPage,
    currentPage,
    totalPages,
  ];
}

class PaginationMetaModel extends PaginationMeta {
  const PaginationMetaModel({
    required super.total,
    required super.count,
    required super.perPage,
    required super.currentPage,
    required super.totalPages,
  });

  factory PaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      PaginationMetaModel(
        total: json['total'] != null
            ? num.tryParse(json['total'].toString())?.toInt() ?? 0
            : 0,
        count: json['count'] != null
            ? num.tryParse(json['count'].toString())?.toInt() ?? 0
            : 0,
        perPage: json['per_page'] != null
            ? num.tryParse(json['per_page'].toString())?.toInt() ?? 1
            : 1,
        currentPage: json['current_page'] != null
            ? num.tryParse(json['current_page'].toString())?.toInt() ?? 1
            : 1,
        totalPages: json['total_pages'] != null
            ? num.tryParse(json['total_pages'].toString())?.toInt() ?? 1
            : 1,
      );
}
