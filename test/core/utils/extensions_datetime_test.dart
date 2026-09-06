import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/utils/extensions.dart';

void main() {
  test('toDateTimeOrNull parses ISO date and datetime with space', () {
    expect(('1995-08-24' as Object?).toDateTimeOrNull(), DateTime(1995, 8, 24));
    expect(
      ('2024-10-18 10:48:37' as Object?).toDateTimeOrNull(),
      DateTime(2024, 10, 18, 10, 48, 37),
    );
  });

  test('toDateTimeOrNull returns null for empty or invalid values', () {
    expect((null as Object?).toDateTimeOrNull(), isNull);
    expect(('' as Object?).toDateTimeOrNull(), isNull);
    expect(('not-a-date' as Object?).toDateTimeOrNull(), isNull);
  });

  test('toDateTimeOrMin falls back to epoch', () {
    expect(
      (null as Object?).toDateTimeOrMin(),
      DateTime.fromMillisecondsSinceEpoch(0),
    );
  });
}
