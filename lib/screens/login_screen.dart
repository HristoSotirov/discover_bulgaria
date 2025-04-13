import 'package:flutter/material.dart';
import 'package:discover_bulgaria/config/preferences_manager.dart';
import 'package:discover_bulgaria/screens/register_screen.dart';
import 'package:discover_bulgaria/services/user_service.dart';
import 'package:discover_bulgaria/screens/user_screen.dart';
import 'package:discover_bulgaria/screens/admin_screen.dart';
import 'package:discover_bulgaria/models/enums/user_type.dart';
import 'package:discover_bulgaria/screens/main_navigation_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final PreferencesManager _prefsManager = PreferencesManager();
  bool _isLoading = false;

  Future<void> _loginUser(String text) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await UserService().loginUser(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        await _prefsManager.saveUserSession(user.id!);
        
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => user.userType == UserType.admin
                ? AdminScreen(userId: user.id!, initialUserData: user)
                : MainNavigationScreen(user: user),

          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder(
            future: Future.wait([
              _prefsManager.translate('Вход'),
              _prefsManager.translate('Имейл'),
              _prefsManager.translate('Парола'),
              _prefsManager.translate('Влез'),
              _prefsManager.translate('Нямаш акаунт? Регистрирай се'),
              _prefsManager.translate('Моля, попълнете всички полета'),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(
                child: CircularProgressIndicator(
                  color: _prefsManager.currentColors['button']
                ),
              );

              final texts = snapshot.data as List<String>;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(texts[0],
                    style: _prefsManager.currentStyles['headingLarge'],
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    style: _prefsManager.currentStyles['bodyRegular'],
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    autocorrect: false,
                    enableSuggestions: true,
                    enableInteractiveSelection: true,
                    textInputAction: TextInputAction.next,
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      cut: true,
                      paste: true,
                      selectAll: true,
                    ),
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      labelText: texts[1],
                      labelStyle: _prefsManager.currentStyles['bodyRegular'],
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _prefsManager.currentColors['button']!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _prefsManager.currentColors['accent']!),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    style: _prefsManager.currentStyles['bodyRegular'],
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    enableInteractiveSelection: true,
                    showCursor: true,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _loginUser(texts[5]),
                    decoration: InputDecoration(
                      labelText: texts[2],
                      labelStyle: _prefsManager.currentStyles['bodyRegular'],
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _prefsManager.currentColors['button']!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: _prefsManager.currentColors['accent']!),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _prefsManager.currentColors['button'],
                      foregroundColor: _prefsManager.currentColors['background'],
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : () => _loginUser(texts[5]),
                    child: _isLoading
                        ? CircularProgressIndicator(color: _prefsManager.currentColors['background'])
                        : Text(texts[3]),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      texts[4],
                      style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                        color: _prefsManager.currentColors['accent'],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
