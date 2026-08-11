import 'package:meta/meta.dart';

/// Represents a value of one of two possible types (a disjoint union).
/// An instance of [Either] is an instance of either [Left] or [Right].
@immutable
sealed class Either<L, R> {
  const Either();

  /// Returns `true` if this is a [Left] instance.
  bool get isLeft => this is Left<L, R>;

  /// Returns `true` if this is a [Right] instance.
  bool get isRight => this is Right<L, R>;

  /// Extracts the value from [Left], or `null` if this is a [Right].
  L? get leftOrNull => switch (this) {
        Left(:final value) => value,
        Right() => null,
      };

  /// Extracts the value from [Right], or `null` if this is a [Left].
  R? get rightOrNull => switch (this) {
        Right(:final value) => value,
        Left() => null,
      };

  /// Applies [onLeft] if this is a [Left] or [onRight] if this is a [Right].
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return switch (this) {
      Left(:final value) => onLeft(value),
      Right(:final value) => onRight(value),
    };
  }

  /// Transforms the [Right] value if present using [fn].
  Either<L, T> map<T>(T Function(R right) fn) {
    return switch (this) {
      Left(:final value) => Left(value),
      Right(:final value) => Right(fn(value)),
    };
  }

  /// Returns the [Right] value or [defaultValue] if this is a [Left].
  R getOrElse(R Function() defaultValue) {
    return switch (this) {
      Left() => defaultValue(),
      Right(:final value) => value,
    };
  }
}

/// The left side of an [Either], traditionally used to represent failure.
final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// The right side of an [Either], traditionally used to represent success.
final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
