import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/landmark_model.dart';
import '../models/visited_landmark_model.dart';
import '../services/landmark_service.dart';
import '../services/visited_landmark_service.dart';

class VisitedLandmarksListScreen extends StatefulWidget {
  final String userId;

  const VisitedLandmarksListScreen({
    super.key,
    required this.userId,
  });

  @override
  State<VisitedLandmarksListScreen> createState() => _VisitedLandmarksListScreenState();
}

class _VisitedLandmarksListScreenState extends State<VisitedLandmarksListScreen> {
  bool isLoading = true;
  List<LandmarkModel> visitedLandmarks = [];
  Map<String, DateTime> visitDates = {};

  @override
  void initState() {
    super.initState();
    _loadVisited();
  }

  Future<void> _loadVisited() async {
    try {
      final visited = await VisitedLandmarkService().getVisitedLandmarksByUser(widget.userId);
      final allLandmarks = await LandmarkService().getAllLandmarks();

      final matched = allLandmarks.where((lm) =>
          visited.any((v) => v.landmarkId == lm.id)).toList();

      final dateMap = {
        for (var v in visited) v.landmarkId: v.date,
      };

      if (!mounted) return;
      setState(() {
        visitedLandmarks = matched;
        visitDates = dateMap;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading visited landmarks: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDarkMode);
    final textStyles = AppTextStyles.getStyles(isDarkMode);

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Премахва стрелката за назад
        backgroundColor: colors['appBar'],
        title: Text('Посетени обекти', style: textStyles['headingLarge']),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : visitedLandmarks.isEmpty
          ? Center(
        child: Text("Няма посетени обекти", style: textStyles['bodyRegular']),
      )
          : Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: visitedLandmarks.length,
                itemBuilder: (context, index) {
                  final landmark = visitedLandmarks[index];
                  final visitDate = visitDates[landmark.id];
                  final formattedDate = visitDate != null
                      ? "${visitDate.day.toString().padLeft(2, '0')}.${visitDate.month.toString().padLeft(2, '0')}.${visitDate.year}"
                      : "Unknown";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors['box'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            landmark.imageUrl,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(landmark.name, style: textStyles['headingLarge']),
                              const SizedBox(height: 8),
                              Text(
                                "Посетено на $formattedDate",
                                style: textStyles['bodyRegular'],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors['button'],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Назад"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
