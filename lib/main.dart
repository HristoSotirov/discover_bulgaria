// import 'package:flutter/material.dart';
// import 'screens/RegisterScreen.dart'; // 👈 добави този импорт
// import 'supabase_config.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SupabaseConfig.initialize();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Supabase Demo',
//       home: const RegisterScreen(),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'models/user_model.dart';
// import 'services/user_service.dart';
// import 'screens/user_screen.dart';
// import 'supabase_config.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SupabaseConfig.initialize();
//
//   final user = await UserService().getUserById('4d48b730-25ba-4e05-82a0-5e9f0b9b8d0d');
//
//   runApp(MyApp(user: user!));
// }
//
// class MyApp extends StatelessWidget {
//   final UserModel user;
//
//   const MyApp({super.key, required this.user});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: UserProfileScreen(
//         user: user,
//         landmarksCount: 7, // може да го вземеш отделно по-късно
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'services/user_service.dart';
import 'screens/main_navigation_screen.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  final user = await UserService().getUserById('4d48b730-25ba-4e05-82a0-5e9f0b9b8d0d');

  runApp(MyApp(user: user!));
}

class MyApp extends StatelessWidget {
  final UserModel user;

  const MyApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigationScreen(
        user: user,
        landmarksCount: 7, // зареди реално по желание
      ),
    );
  }
}

