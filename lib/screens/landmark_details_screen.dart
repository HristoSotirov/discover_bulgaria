import 'package:flutter/material.dart';
import '../models/landmark_model.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../screens/landmark_quiz_screen.dart';

class LandmarkDetailsScreen extends StatelessWidget {
  final LandmarkModel landmark;

  const LandmarkDetailsScreen({super.key, required this.landmark});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDark);
    final styles = AppTextStyles.getStyles(isDark);

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: AppBar(
        backgroundColor: colors['appBar'],
        title: Text(landmark.name, style: styles['headingLarge']),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                landmark.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  landmark.description ?? "No description available.",
                  style: styles['bodyRegular'],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LandmarkQuizScreen(landmark: landmark),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors['button'],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Make the quiz"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Back to map", style: TextStyle(color: colors['accent'])),
            ),
          ],
        ),
      ),
    );
  }
}
