import 'package:flutter/material.dart';
import 'config/preferences_manager.dart';
import 'screens/onboarding_screen.dart';
import 'screens/admin_screen.dart';
import 'services/user_service.dart';
import 'models/enums/user_type.dart';
import 'supabase_config.dart';

import 'screens/main_navigation_screen.dart'; //

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await SupabaseConfig.initialize();


  final prefsManager = PreferencesManager();
  await prefsManager.initializePreferences();

  await PreferencesManager().clearUserSession(); // ❗️Изчиства сесията при всяко стартиране
  // добавих го да тестваме само, като го махнем сесията се пази и вс работи


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _prefsManager = PreferencesManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _determineInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: _prefsManager.currentColors['background'],
              body: Center(
                child: CircularProgressIndicator(
                  color: _prefsManager.currentColors['button'],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            print('Error loading initial screen: ${snapshot.error}');
            return OnboardingScreen();
          }

          return snapshot.data ?? OnboardingScreen();
        },
      ),
    );
  }

  Future<Widget> _determineInitialScreen() async {
    try {
      await _prefsManager.initializePreferences();

      if (!_prefsManager.isOnboardingDone) {
        return OnboardingScreen();
      }

      final userId = _prefsManager.userId;
      if (userId != null) {
        try {
          final user = await UserService().getUserById(userId);
          if (user != null) {
            if (user.userType == UserType.admin) {
              return AdminScreen(
                userId: userId,
                initialUserData: user,
              );
            } else {
              return MainNavigationScreen(user: user);
            }
          }
        } catch (e) {
          print('Error fetching user: $e');
          await _prefsManager.clearUserSession();
        }
      }
    } catch (e) {
      print('Error determining initial screen: $e');
    }

    return OnboardingScreen();
  }
}
