import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text
          .toUpperCase(), // စာသားကို အလိုအလျောက် အကုန် စာလုံးကြီးပြောင်းပစ်သည်
      selection: newValue
          .selection, // စာရိုက်ရလွယ်ကူအောင် Cursor အနေအထားကို မပြောင်းလဲဘဲ ထိန်းသိမ်းထားသည်
    );
  }
}
