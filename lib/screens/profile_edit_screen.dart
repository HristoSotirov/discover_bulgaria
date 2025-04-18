import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../models/user_model.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserModel user;

  const ProfileEditScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {

  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors.getColors(isDarkMode);
    final textStyles = AppTextStyles.getStyles(isDarkMode);

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: AppBar(
        title: Text('Edit Profile', style: textStyles['headingMedium']),
        backgroundColor: colors['background'],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // TODO: Implement image picker
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.user.imageUrl != null
                        ? NetworkImage(widget.user.imageUrl!)
                        : null,
                    child: widget.user.imageUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors['button'],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: textStyles['bodyRegular'],
                border: OutlineInputBorder(),
              ),
              style: textStyles['bodyRegular'],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors['button'],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
