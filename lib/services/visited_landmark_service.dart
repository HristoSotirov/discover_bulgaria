import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/visited_landmark_model.dart';

class VisitedLandmarkService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'visited_landmarks';

  /// Създаване на запис за посетена забележителност
  Future<void> createVisitedLandmark(VisitedLandmarkModel visited) async {
    try {
      await _client.from(_table).insert(visited.toJson());
    } catch (error) {
      throw Exception('Failed to create visited landmark: $error');
    }
  }

  /// Взимане на всички посещения за потребител
  Future<List<VisitedLandmarkModel>> getVisitedLandmarksByUser(String userId) async {
    try {
      final List<dynamic> data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return data.map((e) => VisitedLandmarkModel.fromJson(e)).toList();
    } catch (error) {
      throw Exception('Failed to get visited landmarks: $error');
    }
  }

  /// Проверка дали забележителност е посетена от потребител
  Future<bool> checkIfVisited(String userId, String landmarkId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('landmark_id', landmarkId);

      return data.isNotEmpty;
    } catch (error) {
      throw Exception('Failed to check visited status: $error');
    }
  }

  /// Изтриване на запис за посещение
  Future<void> deleteVisitedLandmark(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete visited landmark: $error');
    }
  }

  /// Ъпдейт на запис за посещение
  Future<void> updateVisitedLandmark(VisitedLandmarkModel visited) async {
    if (visited.id == null) {
      throw Exception('Cannot update without ID');
    }

    try {
      await _client
          .from(_table)
          .update(visited.toJson())
          .eq('id', visited.id!);
    } catch (error) {
      throw Exception('Failed to update visited landmark: $error');
    }
  }
}