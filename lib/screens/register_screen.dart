import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/enums/user_type.dart';
import '../services/user_service.dart';
import '../config/preferences_manager.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final _prefsManager = PreferencesManager();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _birthDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefsManager.addListener(_handlePrefsChange);
  }

  @override
  void dispose() {
    _prefsManager.removeListener(_handlePrefsChange);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handlePrefsChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          child: Form(
            key: _formKey,
            child: FutureBuilder(
              future: Future.wait([
                _prefsManager.translate('Регистрация'),
                _prefsManager.translate('Моля въведете име'),
                _prefsManager.translate('Моля въведете имейл адрес'),
                _prefsManager.translate('Моля въведете парола'),
                _prefsManager.translate('Моля изберете рождена дата'),
                _prefsManager.translate('Рождена дата'),
                _prefsManager.translate('Регистрирай'),
                _prefsManager.translate('Вече имаш акаунт? Влез'),
                _prefsManager.translate('Моля, попълнете всички полета'),
                _prefsManager.translate('Паролата трябва да е поне 6 символа'),
                _prefsManager.translate('Грешка при регистрация'),
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
                    SizedBox(height: 60),
                    Text(texts[0], 
                      style: _prefsManager.currentStyles['headingLarge'],
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                    _buildTextField(_nameController, texts[1], false),
                    SizedBox(height: 20),
                    _buildTextField(_emailController, texts[2], false),
                    SizedBox(height: 20),
                    _buildTextField(_passwordController, texts[3], true),
                    SizedBox(height: 20),
                    // Replace ListTile with TextFormField
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _birthDate?.toLocal().toString().split(' ')[0] ?? ''
                      ),
                      style: _prefsManager.currentStyles['bodyRegular'],
                      decoration: InputDecoration(
                        labelText: _birthDate == null ? texts[4] : texts[5],
                        labelStyle: _prefsManager.currentStyles['bodyRegular'],
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _prefsManager.currentColors['button']!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _prefsManager.currentColors['accent']!),
                        ),
                        filled: true,
                        fillColor: _prefsManager.currentColors['background'],
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: Icon(Icons.calendar_today, color: _prefsManager.currentColors['button']),
                      ),
                      onTap: _pickBirthDate,
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _prefsManager.currentColors['button'],
                        foregroundColor: _prefsManager.currentColors['background'],
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : () => _registerUser(texts[8], texts[9], texts[10]),
                      child: _isLoading
                          ? CircularProgressIndicator(color: _prefsManager.currentColors['background'])
                          : Text(texts[6]),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        texts[7],
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isPassword) {
    return TextFormField(
      controller: controller,
      style: _prefsManager.currentStyles['bodyRegular'],
      obscureText: isPassword,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      enableInteractiveSelection: true,
      readOnly: false,
      showCursor: true,
      textCapitalization: label.toLowerCase().contains('email') || isPassword 
          ? TextCapitalization.none 
          : TextCapitalization.sentences,
      keyboardType: isPassword 
          ? TextInputType.visiblePassword 
          : (label.toLowerCase().contains('email') 
              ? TextInputType.emailAddress 
              : TextInputType.text),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: _prefsManager.currentStyles['bodyRegular'],
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _prefsManager.currentColors['button']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _prefsManager.currentColors['accent']!),
        ),
        filled: true,
        fillColor: _prefsManager.currentColors['background'],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final translations = await Future.wait([
      _prefsManager.translate('Избери'), // Select
      _prefsManager.translate('Откажи'), // Cancel
    ]);

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _prefsManager.currentColors['button']!,
              onPrimary: _prefsManager.currentColors['background']!,
              onSurface: _prefsManager.currentColors['text']!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _prefsManager.currentColors['button'],
              ),
            ),
            dialogBackgroundColor: _prefsManager.currentColors['background'],
          ),
          child: child!,
        );
      },
      confirmText: translations[0],
      cancelText: translations[1],
    );

    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  Future<void> _registerUser(String emptyFieldsMsg, String passwordLengthMsg, String errorMsg) async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emptyFieldsMsg)),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordLengthMsg)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = UserModel(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        points: 0,
        streaks: 0,
        userType: UserType.user,
        birthDate: _birthDate!,
        isDailyQuizDone: false,
      );

      await UserService().createUser(user);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errorMsg: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
