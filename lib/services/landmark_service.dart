import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/landmark_model.dart';

class LandmarkService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'landmarks';

  /// Създаване на нова забележителност
  Future<void> createLandmark(LandmarkModel landmark) async {
    try {
      await _client.from(_table).insert(landmark.toJson());
    } catch (error) {
      throw Exception('Failed to create landmark: $error');
    }
  }

  /// Взимане на всички забележителности
  Future<List<LandmarkModel>> getAllLandmarks() async {
    try {
      final List<dynamic> data = await _client.from(_table).select();
      return data.map((e) => LandmarkModel.fromJson(e)).toList();
    } catch (error) {
      throw Exception('Failed to get landmarks: $error');
    }
  }

  /// Взимане на една забележителност по ID
  Future<LandmarkModel?> getLandmarkById(String id) async {
    try {
      final data = await _client.from(_table).select().eq('id', id).single();
      return LandmarkModel.fromJson(data);
    } catch (error) {
      throw Exception('Failed to get landmark by id: $error');
    }
  }

  /// Ъпдейт на забележителност
  Future<void> updateLandmark(LandmarkModel landmark) async {
    if (landmark.id == null) {
      throw Exception('Cannot update landmark without ID');
    }

    try {
      await _client.from(_table).update(landmark.toJson()).eq('id', landmark.id!);
    } catch (error) {
      throw Exception('Failed to update landmark: $error');
    }
  }

  /// Изтриване на забележителност
  Future<void> deleteLandmark(String id) async {
    if (id == null) {
      throw Exception('Cannot delete landmark without ID');
    }

    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete landmark: $error');
    }
  }
}

