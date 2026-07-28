import 'package:flutter/services.dart';

class MyanmarDigitFormatter extends TextInputFormatter {
  static const Map<String, String> _digitMap = {
    '0': '၀',
    '1': '၁',
    '2': '၂',
    '3': '၃',
    '4': '၄',
    '5': '၅',
    '6': '၆',
    '7': '၇',
    '8': '၈',
    '9': '၉',
  };

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    for (var entry in _digitMap.entries) {
      newText = newText.replaceAll(entry.key, entry.value);
    }

    return newValue.copyWith(text: newText, selection: newValue.selection);
  }
}
