import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/UserModel.dart'; // поправен import (малка буква)

class UserService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'users';

  /// Създаване на потребител, без ръчно подаване на id
  Future<void> createUser(UserModel user) async {
    try {
      await _client.from(_table).insert(user.toJson());
    } catch (error) {
      throw Exception('Failed to create user: $error');
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final data = await _client.from(_table).select().eq('id', id).single();
      return UserModel.fromJson(data);
    } catch (error) {
      throw Exception('Failed to get user by id: $error');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final List<dynamic> data = await _client.from(_table).select();
      return data.map((e) => UserModel.fromJson(e)).toList();
    } catch (error) {
      throw Exception('Failed to get all users: $error');
    }
  }

  /// Ъпдейт изисква `id`, така че трябва да е set-нато
  Future<void> updateUser(UserModel user) async {
    if (user.id == null) {
      throw Exception('Cannot update user without ID');
    }

    try {
      await _client.from(_table).update(user.toJson()).eq('id', user.id!);
    } catch (error) {
      throw Exception('Failed to update user: $error');
    }
  }


  Future<void> deleteUser(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete user: $error');
    }
  }
}
