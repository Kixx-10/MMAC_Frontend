// lib/constants/app_fonts.dart

import 'package:flutter/material.dart';

class AppFonts {
  // Private constructor prevents anyone from accidentally instantiating this class
  AppFonts._();

  // The master string for your font family
  static const String primaryFont = 'SegoeUI';

  // Bonus: Define standard text styles for your app here!
  static const TextStyle pageTitle = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle normalText = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
}
