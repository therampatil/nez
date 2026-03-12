import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Riverpod provider — single instance of [InteractionService].
final interactionServiceProvider = Provider<InteractionService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return InteractionService(dio: apiClient.client);
});

/// Tracks user interactions with articles (view, read, bookmark, share, like).
/// Posts to `POST /interactions/` on the backend which also updates preference weights.
class InteractionService {
  InteractionService({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Record a "view" interaction — called when an article detail page opens.
  Future<void> recordView(int articleId) async {
    await _post(articleId: articleId, type: 'view', readTime: 0.0);
  }

  /// Record a "read" interaction with the time spent (seconds).
  /// Called when the user leaves the article detail page.
  Future<void> recordRead(int articleId, {double readTimeSeconds = 0.0}) async {
    await _post(
      articleId: articleId,
      type: 'read',
      readTime: readTimeSeconds,
    );
  }

  /// Record a "bookmark" interaction.
  Future<void> recordBookmark(int articleId) async {
    await _post(articleId: articleId, type: 'bookmark', readTime: 0.0);
  }

  /// Record a "share" interaction.
  Future<void> recordShare(int articleId) async {
    await _post(articleId: articleId, type: 'share', readTime: 0.0);
  }

  Future<void> _post({
    required int articleId,
    required String type,
    required double readTime,
  }) async {
    try {
      await _dio.post(
        '/interactions/',
        data: {
          'article_id': articleId,
          'interaction_type': type,
          'read_time': readTime,
        },
      );
    } catch (e) {
      // Non-critical — never crash the UI over tracking failures.
      debugPrint('[InteractionService] Failed to record $type for $articleId: $e');
    }
  }
}
