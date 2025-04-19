import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final hashedPassword = hashPassword(password);

      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .eq('password', hashedPassword)
          .maybeSingle();

      if (response == null) {
        throw Exception('Invalid credentials');
      }

      final userData = Map<String, dynamic>.from(response as Map<String, dynamic>);
      userData['points'] = userData['points'] ?? 0;
      userData['streaks'] = userData['streaks'] ?? 0;
      userData['user_type'] = userData['user_type'] ?? 'user';
      userData['is_daily_quiz_done'] = userData['is_daily_quiz_done'] ?? false;

      return UserModel.fromJson(userData);
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('Invalid credentials')) {
        throw Exception('Invalid credentials');
      }
      throw Exception('Server error occurred. Please try again later.');
    }
  }


  Future<void> createUser(UserModel user) async {
    try {
      final hashedUser = user.copyWith(
        password: hashPassword(user.password),
      );
      await _supabase.from('users').insert(hashedUser.toJson());
    } catch (e) {
      throw Exception('User creation failed: $e');
    }
  }


  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (response != null) {
        return UserModel.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    if (user.id == null) {
      throw Exception('User ID cannot be null');
    }
    try {
      await _supabase
          .from('users')
          .update(user.toJson())
          .eq('id', user.id!);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('points', ascending: false);

      if (response == null) return [];

      return (response as List<dynamic>)
          .map((data) => UserModel.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<void> updateUserPoints(String userId, int points) async {
    try {
      await _supabase
          .from('users')
          .update({'points': points})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update points: $e');
    }
  }

  Future<void> updateUserStreak(String userId, int streaks) async {
    try {
      await _supabase
          .from('users')
          .update({'streaks': streaks})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }
}

