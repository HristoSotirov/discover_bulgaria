import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';

class DailyQuizScreen extends StatelessWidget {
  const DailyQuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDarkMode);
    final textStyles = AppTextStyles.getStyles(isDarkMode);

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: AppBar(
        title: const Text("Daily Quiz"),
        backgroundColor: colors['button'],
      ),
      body: Center(
        child: Text(
          "Welcome to your daily quiz!\n(Coming soon...)",
          style: textStyles['headingLarge'],
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
