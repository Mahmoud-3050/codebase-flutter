import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Provides server form errors (`field` → messages) to [AppTextFormField]s.
class FieldErrorsScope extends InheritedWidget {
  final Map<String, List<String>> fieldErrors;

  const FieldErrorsScope({
    required this.fieldErrors,
    required super.child,
    super.key,
  });

  static Map<String, List<String>> of(BuildContext context) {
    return maybeOf(context) ?? const <String, List<String>>{};
  }

  static Map<String, List<String>>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FieldErrorsScope>()
        ?.fieldErrors;
  }

  @override
  bool updateShouldNotify(FieldErrorsScope oldWidget) {
    return !mapEquals(fieldErrors, oldWidget.fieldErrors);
  }
}

extension FieldErrorsLookup on Map<String, List<String>> {
  String? messageFor(String? fieldName) {
    if (fieldName == null || fieldName.isEmpty || isEmpty) {
      return null;
    }
    for (final String key in <String>[
      fieldName,
      fieldName.toSnakeCase(),
      fieldName.toCamelCase(),
    ]) {
      final List<String>? messages = this[key];
      if (messages != null && messages.isNotEmpty) {
        return messages.first;
      }
    }
    return null;
  }
}

extension on String {
  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match match) => '_${match[0]!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  String toCamelCase() {
    return replaceAllMapped(
      RegExp(r'_([a-z])'),
      (Match match) => match[1]!.toUpperCase(),
    );
  }
}
