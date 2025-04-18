import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/landmark_model.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import 'landmark_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyLandmarksScreen extends StatelessWidget {
  final List<LandmarkModel> allLandmarks;
  final String userId;

  const NearbyLandmarksScreen({
    super.key,
    required this.allLandmarks,
    required this.userId,
  });

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000; // in meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDarkMode);
    final textStyles = AppTextStyles.getStyles(isDarkMode);

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: AppBar(
        backgroundColor: colors['appBar'],
        title: Text('Nearby', style: textStyles['headingLarge']),
        centerTitle: true,
      ),
      body: FutureBuilder<Position>(
        future: Geolocator.getCurrentPosition(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userPosition = snapshot.data!;
          final nearbyLandmarks = allLandmarks.where((landmark) {
            final distance = _calculateDistance(
              userPosition.latitude,
              userPosition.longitude,
              landmark.latitude,
              landmark.longitude,
            );
            return distance <= 6000; // 6km
          }).toList();

          if (nearbyLandmarks.isEmpty) {
            return Center(
              child: Text("No landmarks nearby.", style: textStyles['bodyRegular']),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: nearbyLandmarks.length,
                    itemBuilder: (context, index) {
                      final landmark = nearbyLandmarks[index];
                      final distance = _calculateDistance(
                        userPosition.latitude,
                        userPosition.longitude,
                        landmark.latitude,
                        landmark.longitude,
                      ).round();

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
                                  Text('$distance m.', style: textStyles['bodyRegular']),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LandmarkDetailsScreen(
                                                landmark: landmark,
                                                userId: userId,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colors['button'],
                                          padding: const EdgeInsets.symmetric(horizontal: 25),
                                        ),
                                        child: const Text('See more'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          final url = Uri.encodeFull(
                                            'https://www.google.com/maps/dir/?api=1&destination=${landmark.latitude},${landmark.longitude}',
                                          );
                                          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colors['button'],
                                          padding: const EdgeInsets.symmetric(horizontal: 25),
                                        ),
                                        child: const Text('Navigate'),
                                      ),
                                    ],
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
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors['button'],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Back to home"),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
