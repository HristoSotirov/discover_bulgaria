
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/user_model.dart';

class UserProfileScreen extends StatelessWidget {
  final UserModel user;
  final int landmarksCount;

  const UserProfileScreen({
    Key? key,
    required this.user,
    required this.landmarksCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Opened UserProfileScreen for: \${user.name} / \${user.rankType}");

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDarkMode);
    final textStyles = AppTextStyles.getStyles(isDarkMode);

    return Scaffold(
      backgroundColor: colors['background'],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: name + rank + avatar
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

                // Stats box
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

                // What's nearby card
                _actionCard(
                  icon: Icons.signpost,
                  text: "See what's nearby",
                  buttonText: "Let's see",
                  onPressed: () {
                    // TODO: handle nearby map navigation
                  },
                  colors: colors,
                  textStyles: textStyles,
                ),
                const SizedBox(height: 20),

                // Daily quiz card
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
                            "It looks like it is time\nfor your daily quiz!",
                            style: textStyles['headingLarge'],
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Снимка по-голяма и наляво
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/quiz.webp',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const Spacer(),

                        // Бутон подравнен надясно (като "Let's see")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors['button'],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: start quiz
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