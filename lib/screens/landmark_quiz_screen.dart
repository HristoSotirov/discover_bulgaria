import 'package:flutter/material.dart';
import '../models/landmark_model.dart';

class LandmarkQuizScreen extends StatelessWidget {
  final LandmarkModel landmark;

  const LandmarkQuizScreen({super.key, required this.landmark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz for ${landmark.name}'),
      ),
      body: Center(
        child: Text('Quiz content for ${landmark.name} will go here.\n(Coming soon...)"'),
      ),
    );
  }
}
