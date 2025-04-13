import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/enums/user_type.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _birthDate;

  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate() || _birthDate == null) return;

    final user = UserModel(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      imageUrl: null,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      points: 0,
      streaks: 0,
      rankType: null,
      // <- ще изисква промяна в модела
      userType: UserType.user,
      birthDate: _birthDate!,
      isDailyQuizDone: false,
    );

    setState(() => _isLoading = true);

    try {
      await UserService().createUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!')),
      );
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 👈 важно!
      appBar: AppBar(title: const Text('Регистрация')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        // Скрива клавиатурата при тап извън поле
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Име'),
                  validator: (value) => value!.isEmpty ? 'Въведи име' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Имейл'),
                  validator: (value) => value!.isEmpty ? 'Въведи имейл' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Парола'),
                  obscureText: true,
                  validator: (value) =>
                  value!.length < 6
                      ? 'Минимум 6 символа'
                      : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(_birthDate == null
                      ? 'Избери рождена дата'
                      : 'Рождена дата: ${_birthDate!.toLocal().toString().split(
                      ' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickBirthDate,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Регистрирай'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
