import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../config/preferences_manager.dart';
import '../services/user_service.dart';
import 'login_screen.dart';  // Add this import

class UserScreen extends StatefulWidget {
  final String userId;
  final UserModel? initialUserData; // Add this field

  const UserScreen({
    Key? key, 
    required this.userId, 
    this.initialUserData, // Add this parameter
  }) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _prefsManager = PreferencesManager();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prefsManager.addListener(_handlePrefsChange);
    if (widget.initialUserData != null) {
      // If we have initial data, use it immediately
      setState(() {
        _user = widget.initialUserData;
        _isLoading = false;
      });
    } else {
      // Otherwise load from the server
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _prefsManager.removeListener(_handlePrefsChange);
    super.dispose();
  }

  void _handlePrefsChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserService().getUserById(widget.userId);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _user = null;
        });
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: ${e.toString()}')),
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
          future: _prefsManager.translate('Профил'),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Profile',
              style: _prefsManager.currentStyles['headingLarge'] ?? 
                const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadUserData,
            color: _prefsManager.currentColors['text'],
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Clear user session but keep onboarding status
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
          : _user == null
              ? FutureBuilder<String>(
                  future: _prefsManager.translate('Потребителят не е намерен'),
                  builder: (context, snapshot) {
                    return Center(child: Text(
                      snapshot.data ?? 'User not found',
                      style: _prefsManager.currentStyles['bodyRegular'] ?? 
                        const TextStyle(fontSize: 16),
                    ));
                  },
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: FutureBuilder(
                    future: Future.wait([
                      _prefsManager.translate('Име'),
                      _prefsManager.translate('Имейл'),
                      _prefsManager.translate('Точки'),
                      _prefsManager.translate('Поредица'),
                      _prefsManager.translate('Тип потребител'),
                      _prefsManager.translate('Рождена дата'),
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator(
                          color: _prefsManager.currentColors['button']
                        ));
                      }
                      
                      final labels = snapshot.data as List<String>;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoTile(labels[0], _user!.name),
                          _buildInfoTile(labels[1], _user!.email),
                          _buildInfoTile(labels[2], _user!.points.toString()),
                          _buildInfoTile(labels[3], _user!.streaks.toString()),
                          _buildInfoTile(labels[4], _user!.userType.name),
                          _buildInfoTile(labels[5], 
                            _user!.birthDate.toLocal().toString().split(' ')[0]),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    // Get color based on label category
    Color? textColor;
    if (label.contains('Име') || label.contains('Имейл')) {
      textColor = Colors.blue[700]; // Personal info color
    } else if (label.contains('Точки') || label.contains('Поредица')) {
      textColor = Colors.green[700]; // Achievement info color
    } else if (label.contains('Тип')) {
      textColor = Colors.purple[700]; // Role info color
    } else {
      textColor = Colors.orange[700]; // Other info color
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _prefsManager.currentColors['box'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (_prefsManager.currentStyles['bodyRegular'] ?? 
              const TextStyle(fontSize: 16)).copyWith(color: textColor),
          ),
          Text(
            value,
            style: (_prefsManager.currentStyles['bodyRegular'] ?? 
              const TextStyle(fontSize: 16)).copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
