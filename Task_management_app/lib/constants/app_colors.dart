import 'package:flutter/material.dart';

class AppColors {
  // Primary theme colors (used throughout the app, login included)
  static const Color primary = Color(0xFF3F51B5);       // Indigo, used in login icon, buttons
  static const Color primaryDark = Color(0xFF1A237E);   // Dark Indigo, used in heading text
  static const Color secondary = Color(0xFF5C6BC0);     // Medium Indigo, focused borders, links

  // Backgrounds / surfaces
  static const Color background = Color(0xFFE8EAF6);    // Light gradient top / general background
  static const Color backgroundBottom = Color(0xFFFFFFFF); // Gradient bottom / surface
  static const Color surface = Color(0xFFFFFFFF);       // Cards / input fields
  static const Color surfaceDark = Color(0xFF1E1E1E);   // Dark surface

  // Text colors
  static const Color textPrimary = Color(0xFF000000);   // Black for main text
  static const Color textSecondary = Color(0xFF424242); // Dark grey for subtitles / helpers
  static const Color textLight = Color(0xFFFFFFFF);     // White text (dark mode / buttons)

  // Icons / input field icons
  static const Color iconPrimary = Color(0xFF3F51B5);   // Login icon
  static const Color iconGrey = Color(0xFF90A4AE);      // Input field icons

  // Buttons
  static const Color loginButtonBg = Color(0xFF3F51B5); // Login button background
  static const Color loginButtonText = Color(0xFFFFFFFF);

  // Social buttons
  static const Color googleRed = Color(0xFFDB4437);
  static const Color facebookBlue = Color(0xFF3B5998);

// Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF29B6F6);

}
