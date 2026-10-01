import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Arabic catalogs have the same keys', () {
    final Map<String, dynamic> english =
        jsonDecode(File('assets/lang/en.json').readAsStringSync())
            as Map<String, dynamic>;
    final Map<String, dynamic> arabic =
        jsonDecode(File('assets/lang/ar.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(english.keys.toSet(), arabic.keys.toSet());
  });
}
