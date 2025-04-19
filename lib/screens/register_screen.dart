import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../models/enums/user_type.dart';
import '../services/user_service.dart';
import '../config/preferences_manager.dart';
import 'login_screen.dart';

enum FieldType { name, email, password }

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

  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isAgeValid = false;

  bool _hasEmailText = false;
  bool _hasAtSymbol = false;
  bool _hasDotAfterAt = false;
  bool _hasTextAfterDot = false;

  @override
  void initState() {
    super.initState();
    _prefsManager.addListener(_handlePrefsChange);

    _nameController.addListener(() {
      setState(() {
        _isNameValid = _validateName(_nameController.text);
      });
    });

    _emailController.addListener(() {
      setState(() {
        _isEmailValid = _validateEmail(_emailController.text);
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _isPasswordValid = _validatePassword(_passwordController.text);
      });
    });
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
    if (mounted) setState(() {});
  }

  bool _validateName(String name) {
    return name.trim().length >= 3;
  }

  bool _validateEmail(String email) {
    _hasEmailText = email.isNotEmpty;
    _hasAtSymbol = email.contains('@');

    if (_hasAtSymbol) {
      final parts = email.split('@');
      if (parts.length == 2 && parts[1].isNotEmpty) {
        _hasDotAfterAt = parts[1].contains('.');
        if (_hasDotAfterAt) {
          final domainParts = parts[1].split('.');
          _hasTextAfterDot = domainParts.length > 1 && domainParts[1].isNotEmpty;
        }
      }
    } else {
      _hasDotAfterAt = false;
      _hasTextAfterDot = false;
    }

    return _hasEmailText && _hasAtSymbol && _hasDotAfterAt && _hasTextAfterDot;
  }

  bool _validatePassword(String password) {
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return password.length >= 8 && hasLetter && hasNumber;
  }

  bool _validateAge(DateTime? birthDate) {
    if (birthDate == null) return false;
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return age >= 13;
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
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: _prefsManager.currentColors['button'],
                    ),
                  );
                }

                final texts = snapshot.data as List<String>;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      texts[0],
                      style: _prefsManager.currentStyles['headingLarge'],
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildTextField(_nameController, texts[1], false, FieldType.name),
                    const SizedBox(height: 20),
                    _buildTextField(_emailController, texts[2], false, FieldType.email),
                    const SizedBox(height: 20),
                    _buildTextField(_passwordController, texts[3], true, FieldType.password),
                    const SizedBox(height: 20),
                    _buildDateField(texts[4], texts[5]),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _prefsManager.currentColors['button'],
                        foregroundColor: _prefsManager.currentColors['background'],
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : () => _registerUser(texts[8], texts[9], texts[10]),
                      child: _isLoading
                          ? CircularProgressIndicator(color: _prefsManager.currentColors['background'])
                          : Text(texts[6]),
                    ),
                    const SizedBox(height: 20),
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

  Widget _buildTextField(TextEditingController controller, String label, bool isPassword, FieldType fieldType) {
    Widget? suffixWidget;

    switch (fieldType) {
      case FieldType.name:
        if (controller.text.isNotEmpty) {
          suffixWidget = Icon(
            _isNameValid ? Icons.check_circle : Icons.error,
            color: _isNameValid ? Colors.green : Colors.red,
          );
        }
        break;

      case FieldType.email:
        if (controller.text.isNotEmpty) {
          suffixWidget = Container(
            width: 40,
            alignment: Alignment.center,
            child: Icon(
              _isEmailValid ? Icons.check_circle : Icons.error,
              color: _isEmailValid ? Colors.green : Colors.red,
            ),
          );

        }
        break;



      case FieldType.password:
        if (controller.text.isNotEmpty) {
          suffixWidget = Icon(
            _isPasswordValid ? Icons.check_circle : Icons.error,
            color: _isPasswordValid ? Colors.green : Colors.red,
          );
        }
        break;
    }

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      style: _prefsManager.currentStyles['bodyRegular'],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: _prefsManager.currentStyles['bodyRegular'],
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _prefsManager.currentColors['button']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _prefsManager.currentColors['accent']!),
        ),
        filled: true,
        fillColor: _prefsManager.currentColors['background'],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: suffixWidget != null
            ? Container(
          width: 40,
          alignment: Alignment.center,
          child: suffixWidget,
        ) : null,
      ),
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : (fieldType == FieldType.email
          ? TextInputType.emailAddress
          : TextInputType.text),
      textCapitalization: fieldType == FieldType.name
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDateField(String labelText, String dateLabel) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _birthDate?.toLocal().toString().split(' ')[0] ?? ''),
      style: _prefsManager.currentStyles['bodyRegular'],
      decoration: InputDecoration(
        labelText: _birthDate == null ? labelText : dateLabel,
        labelStyle: _prefsManager.currentStyles['bodyRegular'],
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _prefsManager.currentColors['button']!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _prefsManager.currentColors['accent']!),
        ),
        filled: true,
        fillColor: _prefsManager.currentColors['background'],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: _prefsManager.currentColors['button']),
            if (_birthDate != null)
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Icon(
                  _isAgeValid ? Icons.check_circle : Icons.error,
                  color: _isAgeValid ? Colors.green : Colors.red,
                ),
              ),
          ],
        ),
      ),
      onTap: _pickBirthDate,
    );
  }

  Future<void> _pickBirthDate() async {
    final translations = await Future.wait([
      _prefsManager.translate('Избери'),
      _prefsManager.translate('Откажи'),
    ]);

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
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
      setState(() {
        _birthDate = date;
        _isAgeValid = _validateAge(_birthDate);
      });
    }
  }

  Future<void> _registerUser(String emptyFieldsMsg, String passwordLengthMsg, String errorMsg) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(emptyFieldsMsg)));
      return;
    }

    if (!_isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid email address')));
      return;
    }

    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password must be at least 8 characters long and contain both letters and numbers')));
      return;
    }

    if (!_isAgeValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You must be at least 13 years old to register')));
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
        rankType: 'НОВ',
        birthDate: _birthDate!,
        isDailyQuizDone: false,
        imageUrl: 'https://icons.veryicon.com/png/o/miscellaneous/two-color-icon-library/user-286.png',
      );

      await UserService().createUser(user);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$errorMsg: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

