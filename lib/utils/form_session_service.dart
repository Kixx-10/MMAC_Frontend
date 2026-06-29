// lib/utils/form_session_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormSessionService {
  // Private constructor prevents instantiation of this utility class
  FormSessionService._();

  // --- Constants ---
  static const String _newSessionKey = "mmac_new_app_session";
  static const String _updateSessionKey = "mmac_update_app_session";

  // --- Private Helpers ---
  static String _getKey(bool isUpdateMode) {
    return isUpdateMode ? _updateSessionKey : _newSessionKey;
  }

  /// Saves the current form step and UI values into SharedPreferences.
  static Future<void> saveDraft(
    Map<String, dynamic> data,
    int step, {
    bool isUpdateMode = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> sessionPayload = {
        'currentStep': step,
        'values': data,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_getKey(isUpdateMode), jsonEncode(sessionPayload));
    } catch (e) {
      debugPrint("Error saving draft session: $e");
    }
  }

  /// Loads the saved session data (step and values) from SharedPreferences.
  /// Returns [null] if no session exists or if parsing fails.
  static Future<Map<String, dynamic>?> loadDraft({
    bool isUpdateMode = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_getKey(isUpdateMode));

      if (jsonString != null && jsonString.isNotEmpty) {
        final dynamic decodedData = jsonDecode(jsonString);

        // 🎯 Type safety check before returning
        if (decodedData is Map<String, dynamic>) {
          return decodedData;
        }
      }
    } catch (e) {
      debugPrint("❌ Error loading draft session: $e");
    }

    return null;
  }

  /// Clears the saved session data once the form is submitted or reset.
  static Future<void> clearDraft({bool isUpdateMode = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getKey(isUpdateMode));
    } catch (e) {
      debugPrint("❌ Error clearing draft session: $e");
    }
  }
}
