import 'package:flutter/material.dart';
import 'supabase_config.dart';
import 'package:discover_bulgaria/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase Demo',
      home: OnboardingScreen(),
    );
  }
}