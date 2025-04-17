import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question_model.dart'; // Декларирайте този модел

class QuestionService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'questions';

  /// Създаване на нов въпрос
  Future<void> createQuestion(QuestionModel question) async {
    try {
      await _client.from(_table).insert(question.toJson());
    } catch (error) {
      throw Exception('Грешка при създаване на въпрос: $error');
    }
  }

  /// Взимане на всички въпроси
  Future<List<QuestionModel>> getAllQuestions() async {
    try {
      final List<dynamic> data = await _client.from(_table).select();
      return data.map((e) => QuestionModel.fromJson(e)).toList();
    } catch (error) {
      throw Exception('Грешка при взимане на въпроси: $error');
    }
  }

  /// Взимане на въпроси по Landmark ID
  Future<List<QuestionModel>> getQuestionsByLandmark(String landmarkId) async {
    try {
      final List<dynamic> data = await _client
          .from(_table)
          .select()
          .eq('landmark_id', landmarkId);
      return data.map((e) => QuestionModel.fromJson(e)).toList();
    } catch (error) {
      throw Exception('Грешка при търсене на въпроси: $error');
    }
  }

  /// Ъпдейт на въпрос
  Future<void> updateQuestion(QuestionModel question) async {
    if (question.id == null) {
      throw Exception('Невалиден идентификатор на въпрос');
    }

    try {
      await _client
          .from(_table)
          .update(question.toJson())
          .eq('id', question.id!);
    } catch (error) {
      throw Exception('Грешка при актуализация: $error');
    }
  }

  /// Изтриване на въпрос
  Future<void> deleteQuestion(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (error) {
      throw Exception('Грешка при изтриване: $error');
    }
  }
}