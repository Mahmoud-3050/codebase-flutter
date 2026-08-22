import '../../utils/exceptions.dart';

/// Hex color parsing for generate scripts.
abstract final class ColorHelper {
  static final RegExp _hexChars = RegExp(r'^[0-9A-F]+$');

  /// Strips `#` / `0x` and returns 8-digit uppercase AARRGGBB.
  ///
  /// Accepts 3, 6, or 8 hex digits (`#RGB`, `#RRGGBB`, `#AARRGGBB`).
  static String normalizeHex(String raw) {
    var hex = raw.trim();
    if (hex.isEmpty) {
      throw const ColorException('Color value cannot be empty');
    }
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }
    if (hex.toLowerCase().startsWith('0x')) {
      hex = hex.substring(2);
    }
    hex = hex.toUpperCase();
    if (!_hexChars.hasMatch(hex)) {
      throw ColorException('"$raw" is not a hex color');
    }
    if (hex.length == 3) {
      hex = hex.split('').map((String c) => '$c$c').join();
    }
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) {
      throw ColorException(
        '"$raw" must be 3, 6, or 8 hex digits (got ${hex.length})',
      );
    }
    return hex;
  }

  static bool isValidHex(String raw) {
    try {
      normalizeHex(raw);
      return true;
    } on ColorException {
      return false;
    }
  }
}
