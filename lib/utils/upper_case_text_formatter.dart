// lib/utils/formatters.dart

import 'package:flutter/services.dart';

/// A custom [TextInputFormatter] that automatically converts all typed
/// characters to uppercase while preserving the user's cursor position.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      // 🎯 Automatically transforms the newly typed text to uppercase
      text: newValue.text.toUpperCase(),

      // 🎯 Preserves the cursor position so the user can easily edit the middle of a word
      selection: newValue.selection,
    );
  }
}
