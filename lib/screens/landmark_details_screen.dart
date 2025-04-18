import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/landmark_model.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../screens/landmark_quiz_screen.dart';
import '../services/landmark_service.dart'; // не забравяй това

class LandmarkDetailsScreen extends StatefulWidget {
  final LandmarkModel landmark;
  final String userId;

  const LandmarkDetailsScreen({
    super.key,
    required this.landmark,
    required this.userId,
  });

  @override
  State<LandmarkDetailsScreen> createState() => _LandmarkDetailsScreenState();
}

class _LandmarkDetailsScreenState extends State<LandmarkDetailsScreen> {
  bool isNear = false;
  bool isVisited = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkProximityAndVisit();
  }

  Future<void> _checkProximityAndVisit() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition();

    final distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      widget.landmark.latitude,
      widget.landmark.longitude,
    );

    final visitDate = await LandmarkService().getVisitDate(widget.userId, widget.landmark.id!);

    setState(() {
      isNear = distanceInMeters <= 500;
      isVisited = visitDate != null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDark);
    final styles = AppTextStyles.getStyles(isDark);

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: AppBar(
        backgroundColor: colors['appBar'],
        title: Text(widget.landmark.name, style: styles['headingLarge']),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.landmark.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.landmark.description ?? "No description available.",
                  style: styles['bodyRegular'],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading || !isNear || isVisited
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LandmarkQuizScreen(landmark: widget.landmark),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors['button'],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isLoading
                    ? "Checking location..."
                    : isVisited
                    ? "Already visited"
                    : !isNear
                    ? "Get closer to unlock quiz"
                    : "Make the quiz",
                style: const TextStyle(color: Colors.white),
              ),
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
