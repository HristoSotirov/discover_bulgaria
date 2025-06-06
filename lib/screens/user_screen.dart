import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../screens/daily_quiz_screen.dart';
import '../screens/nearby_landmarks_screen.dart';
import '../models/landmark_model.dart';
import '../services/landmark_service.dart';
import '../screens/profile_edit_screen.dart';
import '../services/visited_landmark_service.dart';
import '../screens/visited_landmarks_list_screen.dart';


class UserScreen extends StatefulWidget {
  final String userId;
  final UserModel initialUserData;

  const UserScreen({
    Key? key,
    required this.userId,
    required this.initialUserData,
  }) : super(key: key);

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
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

      final count = await VisitedLandmarkService()
          .getVisitedLandmarksCount(widget.userId);

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

  void refresh() {
    _loadUserAndLandmarks();
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
                            user.rankType,
                            style: textStyles['bodyRegular'],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileEditScreen(user: user),
                          ),
                        );
                        if (result == true) {
                          refresh(); // This will reload user data
                        }
                      },
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: user.imageUrl != null
                            ? NetworkImage(user.imageUrl!)
                            : null,
                        child: user.imageUrl == null
                            ? const Icon(Icons.person, size: 35)
                            : null,
                      ),
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
                      _statItem(Icons.rocket_launch, 'Точки', user.points, textStyles),
                      _statItem(Icons.account_balance, 'Обекти', landmarksCount, textStyles),
                      _statItem(Icons.local_fire_department, 'Стрийкс', user.streak, textStyles),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                
                // What's nearby
                _actionCard(
                  icon: Icons.signpost,
                  text: "Какво е наблизо?",
                  buttonText: "Виж тук",
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NearbyLandmarksScreen(
                          allLandmarks: allLandmarks,
                          userId: widget.userId,
                        ),
                      ),
                    );

                    // Refresh the screen if landmarks were updated
                    if (result == true) {
                      refresh(); // Reload the landmarks and user data
                    }
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
                                ? "Поздравления, завърши своята викторина за днес!"
                                : "Време е за викторина. \nНе я пропускай! ",
                            style: textStyles['headingLarge'],
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            user.isDailyQuizDone
                                ? 'assets/quiz_done.png'
                                : 'assets/quiz.webp',
                            height: 200,
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
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DailyQuizScreen(currentUser: user),
                                    ),
                                  );

                                  // Refresh the screen if quiz was completed
                                  if (result == true) {
                                    await _loadUserAndLandmarks();
                                  }
                                },
                                child: const Text("Започни"),
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
    final content = Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 4),
        Text(label, style: textStyles['bodyRegular']),
        Text(value.toString(), style: textStyles['headingLarge']),
      ],
    );

    if (label != 'Обекти') return content;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VisitedLandmarksListScreen(userId: widget.userId),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: content,
      ),
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
