import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/api_client.dart';
import '../../shared/services/api_routes.dart';
import '../../features/feed/data/feed_provider.dart';

// ──────────────────────────────────────────────
// FOLLOWED STORY MODEL
// ──────────────────────────────────────────────
class FollowedStory {
  const FollowedStory({
    required this.id,
    required this.originalArticleId,
    required this.storyKey,
    required this.storyTitle,
    required this.createdAt,
    required this.lastCheckedAt,
    required this.updates,
    required this.unreadCount,
  });

  final int id;
  final int originalArticleId;
  final String storyKey;
  final String storyTitle;
  final DateTime createdAt;
  final DateTime lastCheckedAt;
  final List<int> updates;
  final int unreadCount;

  factory FollowedStory.fromJson(Map<String, dynamic> json) {
    return FollowedStory(
      id: json['id'] as int,
      originalArticleId: json['original_article_id'] as int,
      storyKey: json['story_key'] as String,
      storyTitle: json['story_title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastCheckedAt: DateTime.parse(json['last_checked_at'] as String),
      updates: (json['updates'] as List<dynamic>).cast<int>(),
      unreadCount: json['unread_count'] as int,
    );
  }
}

// ──────────────────────────────────────────────
// FOLLOW/UNFOLLOW ACTIONS
// ──────────────────────────────────────────────

/// Provider for following a news story
final followStoryProvider = Provider<FollowStoryService>((ref) {
  return FollowStoryService(ref.read(apiClientProvider).client);
});

class FollowStoryService {
  FollowStoryService(this._dio);
  
  final Dio _dio;

  Future<void> followStory({
    required int articleId,
    required String storyKey,
    required String storyTitle,
  }) async {
    final payload = {
      'article_id': articleId,
      'story_key': storyKey,
      'story_title': storyTitle,
    };
    try {
      await _dio.post(ApiRoutes.followedStories, data: payload);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      await _dio.post(ApiRoutes.followedStoriesNoSlash, data: payload);
    }
  }

  Future<void> unfollowStory(int storyId) async {
    try {
      await _dio.delete('${ApiRoutes.followedStoriesNoSlash}/$storyId');
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      await _dio.delete('${ApiRoutes.followedStories}/$storyId');
    }
  }

  Future<bool> isFollowing(String storyKey) async {
    try {
      final response = await _dio.get('${ApiRoutes.followedStoriesNoSlash}/check/$storyKey');
      return response.data['is_following'] as bool;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  Future<void> markStoryRead(int storyId) async {
    try {
      await _dio.post('${ApiRoutes.followedStoriesNoSlash}/$storyId/mark-read');
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      await _dio.post('${ApiRoutes.followedStories}/$storyId/mark-read');
    }
  }
}

// ──────────────────────────────────────────────
// FOLLOWED STORIES LIST PROVIDER
// ──────────────────────────────────────────────

final followedStoriesProvider = FutureProvider.autoDispose<List<FollowedStory>>((ref) async {
  final client = ref.read(apiClientProvider).client;
  try {
    final response = await client.get(ApiRoutes.followedStories);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => FollowedStory.fromJson(e as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      try {
        final fallback = await client.get(ApiRoutes.followedStoriesNoSlash);
        final fallbackList = fallback.data as List<dynamic>;
        return fallbackList
            .map((e) => FollowedStory.fromJson(e as Map<String, dynamic>))
            .toList();
      } on DioException catch (fallbackError) {
        if (fallbackError.response?.statusCode == 404) return [];
        rethrow;
      }
    }
    rethrow;
  }
});

// ──────────────────────────────────────────────
// FOLLOWED NEWS FEED PROVIDER
// ──────────────────────────────────────────────

/// Gets articles that are updates to stories the user follows
final followedNewsFeedProvider = FutureProvider.autoDispose<List<ApiArticle>>((ref) async {
  final client = ref.read(apiClientProvider).client;
  try {
    final response = await client.get(
      ApiRoutes.followedStoriesFeed,
      queryParameters: {'limit': 100},
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ApiArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return [];
    rethrow;
  }
});

// ──────────────────────────────────────────────
// TOTAL UNREAD COUNT (for badge in UI)
// ──────────────────────────────────────────────

final followedNewsUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final storiesAsync = ref.watch(followedStoriesProvider);
  return storiesAsync.maybeWhen(
    data: (stories) => stories.fold(0, (sum, story) => sum + story.unreadCount),
    orElse: () => 0,
  );
});
