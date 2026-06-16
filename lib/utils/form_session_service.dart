import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FormSessionService {
  // 🎯 Key ၂ ခု ခွဲထုတ်လိုက်ပါပြီ
  static const String _newSessionKey = "mmac_new_app_session";
  static const String _updateSessionKey = "mmac_update_app_session";

  // Helper method to get correct key
  static String _getKey(bool isUpdateMode) =>
      isUpdateMode ? _updateSessionKey : _newSessionKey;

  // ၁။ UI Values (Map) နဲ့ Step နံပါတ်ကို သိမ်းခြင်း
  static Future<void> saveDraft(
    Map<String, dynamic> data,
    int step, {
    bool isUpdateMode = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> sessionPayload = {
      'currentStep': step,
      'values': data,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_getKey(isUpdateMode), jsonEncode(sessionPayload));
  }

  // ၂။ သိမ်းထားတာတွေကို ပြန်ထုတ်ခြင်း
  static Future<Map<String, dynamic>?> loadDraft({
    bool isUpdateMode = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_getKey(isUpdateMode));

    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // ၃။ ဖောင်တင်ပြီးသွားရင် (သို့) Reset ချရင် ရှင်းထုတ်ခြင်း
  static Future<void> clearDraft({bool isUpdateMode = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getKey(isUpdateMode));
  }
}
