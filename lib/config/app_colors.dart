import 'package:flutter/material.dart';

class AppColors {
  static Map<String, Color> lightTheme = {
    'background': Color(0xFFE3F2FD),
    'box': Color(0xFFBBDEFB),
    'appBar': Color(0xFF90CAF9),
    'button': Color(0xFF64B5F6),
    'accent': Color(0xFF1E88E5),
    'text': Color(0xFF1565C0),
  };

  static Map<String, Color> darkTheme = {
    'background': Color(0xFF0D1B2A),
    'box': Color(0xFF102A43),
    'appBar': Color(0xFF1C3D5A),
    'button': Color(0xFF1C3D5A),
    'accent': Color(0xFF2B5D82),
    'text': Color(0xFF3F7CB5),
  };

  static Map<String, Color> getColors(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }
}
