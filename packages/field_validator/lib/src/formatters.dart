import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    if (text.contains('.') &&
        text.substring(text.indexOf('.') + 1).length > decimalRange) {
      return oldValue;
    }

    return newValue;
  }
}

class ArabicToEnglishNumberFormatter extends TextInputFormatter {
  static const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  static const _englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String converted = newValue.text;
    for (int i = 0; i < _arabicDigits.length; i++) {
      converted = converted.replaceAll(_arabicDigits[i], _englishDigits[i]);
    }

    return newValue.copyWith(
      text: converted,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}
