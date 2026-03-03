import 'package:dio/dio.dart';

/// Handles saving and loading user category preferences via the backend API.
class PreferencesService {
  PreferencesService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Save (overwrite) the user's selected categories.
  Future<void> savePreferences(List<String> categories) async {
    await _dio.put('/users/me/preferences', data: {'categories': categories});
  }

  /// Fetch the user's stored category preferences.
  Future<List<String>> fetchPreferences() async {
    final response = await _dio.get('/users/me/preferences');
    final data = response.data as Map<String, dynamic>;
    return List<String>.from(data['categories'] as List);
  }
}
