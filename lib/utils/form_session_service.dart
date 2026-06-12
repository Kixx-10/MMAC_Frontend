// lib/data/services/form_session_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FormSessionService {
  static const String _sessionKey =
      "mmac_app_session_data"; // အကုန်စုသိမ်းမယ့် key

  // ၁။ UI Values (Map) နဲ့ Step နံပါတ်ကို သိမ်းခြင်း
  static Future<void> saveDraft(Map<String, dynamic> data, int step) async {
    final prefs = await SharedPreferences.getInstance();

    // UI Values များနှင့် Step ကို Map တစ်ခုတည်းမှာ ပေါင်းပြီး သိမ်းမယ်
    final Map<String, dynamic> sessionPayload = {
      'currentStep': step,
      'values': data,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_sessionKey, jsonEncode(sessionPayload));
  }

  // ၂။ သိမ်းထားတာတွေကို ပြန်ထုတ်ခြင်း
  static Future<Map<String, dynamic>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionKey);

    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // ၃။ ဖောင်တင်ပြီးသွားရင် (သို့) Reset ချရင် ရှင်းထုတ်ခြင်း
  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
