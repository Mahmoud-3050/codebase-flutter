import 'package:flutter/material.dart';

/// Material minimum for a control that must be easy to tap.
const Size authMinimumTapTarget = Size(48, 48);

ButtonStyle authTextButtonStyle() {
  return TextButton.styleFrom(
    minimumSize: authMinimumTapTarget,
    tapTargetSize: MaterialTapTargetSize.padded,
  );
}
