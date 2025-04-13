import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../config/preferences_manager.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  final String userId;
  final UserModel? initialUserData;

  const AdminScreen({
    Key? key,
    required this.userId,
    this.initialUserData,
  }) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _prefsManager = PreferencesManager();
  final _userService = UserService();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prefsManager.addListener(_handlePrefsChange);
    _loadUsers();
  }

  @override
  void dispose() {
    _prefsManager.removeListener(_handlePrefsChange);
    super.dispose();
  }

  void _handlePrefsChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      appBar: AppBar(
        backgroundColor: _prefsManager.currentColors['appBar'],
        title: FutureBuilder<String>(
          future: _prefsManager.translate('Админ Панел'),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Admin Panel',
              style: _prefsManager.currentStyles['headingLarge'],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadUsers,
            color: _prefsManager.currentColors['text'],
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _prefsManager.clearUserSession();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            color: _prefsManager.currentColors['text'],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(
              color: _prefsManager.currentColors['button']))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: _prefsManager.currentColors['box'],
                  child: ListTile(
                    title: Text(
                      user.name,
                      style: _prefsManager.currentStyles['bodyRegular'],
                    ),
                    subtitle: Text(
                      'Points: ${user.points} | Streaks: ${user.streaks}',
                      style: _prefsManager.currentStyles['bodySmall'],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () async {
                        try {
                          await _userService.deleteUser(user.id!);
                          _loadUsers();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete user: ${e.toString()}')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
