import 'package:flutter/material.dart';
import 'package:discover_bulgaria/config/preferences_manager.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserModel user;

  const ProfileEditScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  static const List<Map<String, String>> _avatarOptions = [
    {'url': 'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcS-gl-KLwEAHzUzuUTbRRrPRgbK5N-TfLmR0YmBRDP5hA_EUwlB', 'label': 'Бай Ганьо'},
    {'url': 'https://img.freepik.com/premium-vector/cartoon-happy-women-travel-bag-vector-illustration_851674-45532.jpg', 'label': 'Туристка'},
    {'url': 'https://thumbs.dreamstime.com/b/man-traveler-backpack-circle-avatar-bearded-male-tourist-hiker-beanie-head-portrait-happy-smiling-backpacker-nomad-user-363582206.jpg', 'label': 'Откривател'},
    {'url': 'https://img.freepik.com/premium-photo/cartoon-woman-with-hoodie-her-head_950428-45089.jpg?semt=ais_hybrid&w=740', 'label': 'Изследователка'},
    {'url': 'https://img.freepik.com/premium-vector/man-avatar-profile-picture-isolated-background-avatar-profile-picture-man_1293239-4866.jpg', 'label': 'Приключенец'},
    {'url': 'https://img.freepik.com/free-photo/3d-icon-travel-with-woman_23-2151037416.jpg?semt=ais_hybrid&w=740', 'label': 'Планинарка'},
    {'url': 'https://thumbs.dreamstime.com/b/vector-illustration-young-bearded-man-minimalist-style-professional-avatar-image-features-vector-illustration-young-346071589.jpg', 'label': 'Скитник'},
    {'url': 'https://img.freepik.com/premium-vector/beautiful-woman-character-vector-illustration_1253044-39504.jpg?w=360', 'label': 'Фотографка'},
    {'url': 'https://img.freepik.com/free-vector/flat-travel-background_23-2148061181.jpg', 'label': 'Пътешественик'},
    {'url': 'https://static.vecteezy.com/system/resources/thumbnails/046/929/344/small/woman-profile-with-closed-eyes-on-night-sky-background-portrait-or-avatar-of-a-young-female-side-view-calm-and-peaceful-girl-illustration-free-vector.jpg', 'label': 'Мечтателка'}
  ];

  final _prefsManager = PreferencesManager();
  final _userService = UserService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late DateTime _birthDate;
  String? _selectedAvatar;
  bool _isLoading = false;

  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isAgeValid = false;

  bool _hasEmailText = false;
  bool _hasAtSymbol = false;
  bool _hasDotAfterAt = false;
  bool _hasTextAfterDot = false;

  @override
  void initState() {
    super.initState();
    _prefsManager.addListener(_handlePrefsChange);
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _birthDate = widget.user.birthDate;
    _selectedAvatar = widget.user.imageUrl;

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

    // Initial validation
    _isNameValid = _validateName(_nameController.text);
    _isEmailValid = _validateEmail(_emailController.text);
    _isAgeValid = _validateAge(_birthDate);
  }

  @override
  void dispose() {
    _prefsManager.removeListener(_handlePrefsChange);
    _nameController.dispose();
    _emailController.dispose();
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
    }

    return _hasEmailText && _hasAtSymbol && _hasDotAfterAt && _hasTextAfterDot;
  }

  bool _validateAge(DateTime birthDate) {
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return age >= 13;
  }

  Future<void> _saveChanges() async {
    if (!_isNameValid || !_isEmailValid || !_isAgeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fix the validation errors')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        imageUrl: _selectedAvatar,
        birthDate: _birthDate,
      );

      await _userService.updateUser(updatedUser);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final translations = await Future.wait([
      _prefsManager.translate('Избери'),
      _prefsManager.translate('Откажи'),
    ]);

    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _prefsManager.currentColors['button']!,
              onPrimary: _prefsManager.currentColors['text']!,
              onSurface: _prefsManager.currentColors['text']!,
              surface: _prefsManager.currentColors['background']!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _prefsManager.currentColors['text'],
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

  Widget _buildAvatarSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _selectedAvatar != null
              ? NetworkImage(_selectedAvatar!)
              : null,
          child: _selectedAvatar == null
              ? Icon(Icons.person, size: 50, color: _prefsManager.currentColors['text'])
              : null,
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: _selectAvatar,
          child: Text(
            'Промени аватара',
            style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
              color: _prefsManager.currentColors['accent'],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectAvatar() async {
    final translations = await Future.wait([
      _prefsManager.translate('Избери аватар'),
      _prefsManager.translate('Откажи'),
    ]);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _prefsManager.currentColors['background'],
        child: Container(
          height: screenHeight * 0.8,
          width: screenWidth * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                translations[0],
                style: _prefsManager.currentStyles['headingMedium'],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: _avatarOptions.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatarOptions[index];
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedAvatar = avatar['url']);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: _selectedAvatar == avatar['url']
                                  ? Border.all(color: _prefsManager.currentColors['accent']!, width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(80),
                            ),
                            child: CircleAvatar(
                              radius: 65,
                              backgroundImage: NetworkImage(avatar['url']!),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            avatar['label']!,
                            style: _prefsManager.currentStyles['bodyMedium'],
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  translations[1],
                  style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                    color: _prefsManager.currentColors['accent'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: FutureBuilder(
          future: Future.wait([
            _prefsManager.translate('Профил'),
            _prefsManager.translate('Име'),
            _prefsManager.translate('Имейл'),
            _prefsManager.translate('Рождена дата'),
            _prefsManager.translate('Тъмен режим'),
            _prefsManager.translate('Език'),
            _prefsManager.translate('Запази промените'),
            _prefsManager.translate('Назад'),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(
                color: _prefsManager.currentColors['button'],
              ));
            }

            final texts = snapshot.data as List<String>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texts[0],
                  style: _prefsManager.currentStyles['headingLarge'],
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Avatar section
                Center(child: _buildAvatarSection()),
                SizedBox(height: 24),

                _buildTextField(
                  controller: _nameController,
                  label: texts[1],
                  isValid: _isNameValid,
                ),

                SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: texts[2],
                  isValid: _isEmailValid,
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 16),

                _buildDateField(texts[3]),

                SizedBox(height: 24),

                _buildSection(
                  title: texts[4],
                  child: Switch(
                    value: _prefsManager.isDarkMode,
                    onChanged: (value) => _prefsManager.toggleTheme(),
                    activeColor: _prefsManager.currentColors['button'],
                    activeTrackColor: _prefsManager.currentColors['accent']?.withOpacity(0.3),
                    inactiveThumbColor: _prefsManager.currentColors['button'],
                    inactiveTrackColor: _prefsManager.currentColors['background']?.withOpacity(0.5),
                  ),
                ),

                _buildSection(
                  title: texts[5],
                  child: DropdownButton<String>(
                    value: _prefsManager.selectedLanguage,
                    dropdownColor: _prefsManager.currentColors['background'],
                    iconEnabledColor: _prefsManager.currentColors['text'],
                    style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                      color: _prefsManager.currentColors['text'],
                    ),
                    items: ['bg', 'en'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.toUpperCase(),
                          style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                            color: _prefsManager.currentColors['text'],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _prefsManager.setLanguage(newValue);
                      }
                    },
                  ),
                ),

                SizedBox(height: 40),

                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _prefsManager.currentColors['button'],
                        foregroundColor: _prefsManager.currentColors['background'],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size(double.infinity, 48),
                      ),
                      onPressed: _saveChanges,
                      child: Text(
                        texts[6],
                        style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                          color: _prefsManager.currentColors['background'],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _prefsManager.currentColors['button'],
                        side: BorderSide(color: _prefsManager.currentColors['button']!),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size(double.infinity, 48),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        texts[7],
                        style: _prefsManager.currentStyles['bodyRegular']?.copyWith(
                          color: _prefsManager.currentColors['button'],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isValid,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _prefsManager.currentStyles['labelMedium']?.copyWith(
            color: _prefsManager.currentColors['text']?.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          style: _prefsManager.currentStyles['bodyRegular'],
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _prefsManager.currentColors['button']!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _prefsManager.currentColors['accent']!),
            ),
            suffixIcon: controller.text.isNotEmpty ? Icon(
              isValid ? Icons.check_circle : Icons.error,
              color: isValid ? Colors.green : Colors.red,
            ) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _prefsManager.currentStyles['labelMedium']?.copyWith(
            color: _prefsManager.currentColors['text']?.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: _pickBirthDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: _prefsManager.currentColors['button']!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_birthDate.day.toString().padLeft(2, '0')}.'
                  '${_birthDate.month.toString().padLeft(2, '0')}.'
                  '${_birthDate.year}',
                  style: _prefsManager.currentStyles['bodyRegular'],
                ),
                Row(
                  children: [
                    Icon(Icons.calendar_today, 
                        size: 20, 
                        color: _prefsManager.currentColors['text']),
                    SizedBox(width: 8),
                    Icon(
                      _isAgeValid ? Icons.check_circle : Icons.error,
                      color: _isAgeValid ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: _prefsManager.currentStyles['labelMedium']?.copyWith(
            color: _prefsManager.currentColors['text']?.withOpacity(0.7),
          ),
        ),
        child,
      ],
    );
  }
}

