
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../screens/daily_quiz_screen.dart';
import '../screens/nearby_landmarks_screen.dart';

import '../models/landmark_model.dart';
import '../services/landmark_service.dart';



class UserScreen extends StatefulWidget {
  final String userId;
  final UserModel initialUserData;

  const UserScreen({
    Key? key,
    required this.userId,
    required this.initialUserData,
  }) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late UserModel user;
  int landmarksCount = 0;
  bool isLoading = true;
  List<LandmarkModel> allLandmarks = [];


  @override
  void initState() {
    super.initState();
    user = widget.initialUserData;
    _loadUserAndLandmarks();
  }

  Future<void> _loadUserAndLandmarks() async {
    try {
      final fetchedUser = await UserService().getUserById(widget.userId);
      //final count = await UserService().getLandmarksCount(widget.userId);
      final count = 7;
      final fetchedLandmarks = await LandmarkService().getAllLandmarks();


      if (!mounted) return;

      setState(() {
        user = fetchedUser ?? widget.initialUserData;
        landmarksCount = count;
        allLandmarks = fetchedLandmarks;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading user screen: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDarkMode);
    final textStyles = AppTextStyles.getStyles(isDarkMode);

    if (isLoading) {
      return Scaffold(
        backgroundColor: colors['background'],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    print("Opened UserProfileScreen for: ${user.name} / ${user.rankType}");

    return Scaffold(
      backgroundColor: colors['background'],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: textStyles['headingLarge']),
                          Text(
                            user.rankType?.toShortString() ?? 'No Rank',
                            style: textStyles['bodyRegular'],
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl!)
                          : null,
                      child: user.imageUrl == null
                          ? const Icon(Icons.person, size: 35)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors['box'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem(Icons.rocket_launch, 'Points', user.points, textStyles),
                      _statItem(Icons.account_balance, 'Landmarks', landmarksCount, textStyles),
                      _statItem(Icons.local_fire_department, 'Streak', user.streaks, textStyles),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // What's nearby
                _actionCard(
                  icon: Icons.signpost,
                  text: "See what's nearby",
                  buttonText: "Let's see",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NearbyLandmarksScreen(allLandmarks: allLandmarks),
                      ),
                    );
                  },

                  colors: colors,
                  textStyles: textStyles,
                ),
                const SizedBox(height: 20),

                // Quiz card
                SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors['box'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            user.isDailyQuizDone
                                ? "You've already completed your quiz for today!"
                                : "It looks like it is time\nfor your daily quiz!",
                            style: textStyles['headingLarge'],
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            user.isDailyQuizDone
                                ? 'assets/quiz_done.png'
                                : 'assets/quiz.webp',
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Spacer(),
                        if (!user.isDailyQuizDone)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors['button'],
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const DailyQuizScreen(),
                                    ),
                                  );
                                },
                                child: const Text("Let's start"),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, int value, Map<String, TextStyle> textStyles) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(label, style: textStyles['bodyRegular']),
        Text(value.toString(), style: textStyles['headingLarge']),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String text,
    required String buttonText,
    required VoidCallback onPressed,
    required Map<String, Color> colors,
    required Map<String, TextStyle> textStyles,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors['box'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: textStyles['bodyRegular'])),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors['button'],
              foregroundColor: Colors.white,
            ),
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
