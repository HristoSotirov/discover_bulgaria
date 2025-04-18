import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'map_screen.dart';
import 'ranking_screen.dart';
import 'user_screen.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel user;

  const MainNavigationScreen({
    super.key,
    required this.user,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey<UserScreenState> _userScreenKey = GlobalKey();
  final GlobalKey<MapScreenState> _mapScreenKey = GlobalKey();
  final GlobalKey<RankingScreenState> _rankingScreenKey = GlobalKey();

  void _refreshCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        _userScreenKey.currentState?.refresh();
        break;
      case 1:
        _mapScreenKey.currentState?.refresh();
        break;
      case 2:
        _rankingScreenKey.currentState?.refresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDark);
    final textStyles = AppTextStyles.getStyles(isDark);

    final screens = [
      UserScreen(
        key: _userScreenKey,
        userId: widget.user.id!,
        initialUserData: widget.user,
      ),

    MapScreen(userId: widget.user.id!),

      RankingScreen(
        key: _rankingScreenKey,
        currentUser: widget.user,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colors['button'],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black.withOpacity(0.5),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _refreshCurrentScreen();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Ranking'),
        ],
      ),
    );
  }
}
