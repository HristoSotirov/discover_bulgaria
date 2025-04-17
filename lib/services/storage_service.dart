import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/preferences_manager.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucketName = 'landmarks';

  /// Качва файл в storage bucket
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    String folder = 'uploads',
  }) async {
    try {
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storagePath = '$folder/$uniqueFileName';

      await _client.storage
          .from(_bucketName)
          .upload(storagePath, File(filePath));

      return getPublicUrl(storagePath);
    } catch (e) {
      throw Exception('Грешка при качване: ${e.toString()}');
    }
  }

  /// Връща публичен URL към файл
  String getPublicUrl(String filePath) {
    return _client.storage
        .from(_bucketName)
        .getPublicUrl(filePath);
  }


  /// Качва изображение и връща URL
  Future<String> uploadImage(File imageFile) async {
    final userId = PreferencesManager().userId ?? 'anonymous';
    return await uploadFile(
      filePath: imageFile.path,
      fileName: 'user_$userId.jpg',
      folder: 'profile_images',
    );
  }
}