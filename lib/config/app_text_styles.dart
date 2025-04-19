import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static Map<String, TextStyle> lightTheme = {
    'headingLarge': TextStyle(
      fontFamily: 'Roboto',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.lightTheme['text'],
    ),
    'bodyRegular': TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      height: 1.5,
      color: AppColors.lightTheme['text'],
    ),
    'heading': TextStyle(
      fontFamily: 'Roboto',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.lightTheme['text'],
    ),
  };

  static Map<String, TextStyle> darkTheme = {
    'headingLarge': TextStyle(
      fontFamily: 'Roboto',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.darkTheme['text'],
    ),
    'bodyRegular': TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
      height: 1.5,
      color: AppColors.darkTheme['text'],
    ),
    'heading': TextStyle(
      fontFamily: 'Roboto',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.darkTheme['text'],
    ),
  };

  static Map<String, TextStyle> getStyles(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }
}
