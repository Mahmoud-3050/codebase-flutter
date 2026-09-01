import 'package:either/either.dart';
import 'package:test/test.dart';

void main() {
  group('Either Package Tests', () {
    test('Left properties and fold', () {
      const Either<String, int> left = Left('error');

      expect(left.isLeft, isTrue);
      expect(left.isRight, isFalse);
      expect(left.leftOrNull, equals('error'));
      expect(left.rightOrNull, isNull);
      expect(left.fold((l) => 'Left: $l', (r) => 'Right: $r'),
          equals('Left: error'));
      expect(left.getOrElse(() => 0), equals(0));
    });

    test('Right properties and fold', () {
      const Either<String, int> right = Right(42);

      expect(right.isLeft, isFalse);
      expect(right.isRight, isTrue);
      expect(right.leftOrNull, isNull);
      expect(right.rightOrNull, equals(42));
      expect(right.fold((l) => 'Left: $l', (r) => 'Right: $r'),
          equals('Right: 42'));
      expect(right.map((r) => r * 2), equals(const Right<String, int>(84)));
      expect(right.getOrElse(() => 0), equals(42));
    });
  });
}
