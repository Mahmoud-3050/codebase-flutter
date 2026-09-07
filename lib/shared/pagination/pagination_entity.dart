import 'package:equatable/equatable.dart';

/// One page returned by [PaginationCubit.fetchPage].
final class PaginationPage<T> extends Equatable {
  final List<T> items;
  final PaginationMeta meta;

  const PaginationPage({required this.items, required this.meta});

  @override
  List<Object?> get props => <Object?>[items, meta];
}

class PaginationMeta extends Equatable {
  static const int defaultPerPage = 10;
  static const int defaultPage = 1;

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

  static const PaginationMeta initial = PaginationMeta(
    total: 0,
    count: 0,
    perPage: defaultPerPage,
    currentPage: defaultPage,
    totalPages: defaultPage,
  );

  bool get hasMore => currentPage < totalPages;

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
