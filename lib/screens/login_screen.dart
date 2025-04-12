import 'package:flutter/material.dart';
import 'package:discover_bulgaria/config/app_colors.dart';
import 'package:discover_bulgaria/config/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isDarkMode = false;

  Map<String, Color> get _currentColors => AppColors.getColors(_isDarkMode);
  Map<String, TextStyle> get _currentStyles => AppTextStyles.getStyles(_isDarkMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentColors['background'],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login', style: _currentStyles['headingLarge']),
            SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentColors['button'],
                foregroundColor: _currentColors['text'],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // TODO: Implement login logic
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
