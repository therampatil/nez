import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../features/feed/data/feed_provider.dart';
import '../../shared/services/api_client.dart';
import '../../shared/services/api_routes.dart';
import '../../shared/services/interaction_service.dart';

// ──────────────────────────────────────────────
// BOOKMARKS STATE — synced with the backend
// ──────────────────────────────────────────────

/// The list of bookmarked articles loaded from the backend.
/// Separate from feedProvider so we don't rely on the feed being loaded.
final bookmarkedArticlesProvider =
    StateNotifierProvider<
      BookmarkedArticlesNotifier,
      AsyncValue<List<ApiArticle>>
    >((ref) => BookmarkedArticlesNotifier(ref));

class BookmarkedArticlesNotifier
    extends StateNotifier<AsyncValue<List<ApiArticle>>> {
  BookmarkedArticlesNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref _ref;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final client = _ref.read(apiClientProvider).client;
      final response = await client.get(ApiRoutes.userBookmarks);
      final list = response.data as List<dynamic>;
      final articles = list
          .map((e) => ApiArticle.fromJson(e as Map<String, dynamic>))
          .toList();
      state = AsyncValue.data(articles);
    } catch (e, st) {
      if (e is DioException && e.response?.statusCode == 404) {
        // Old backend deployment may miss bookmarks routes; treat as empty.
        state = const AsyncValue.data([]);
        return;
      }
      debugPrint('[BookmarkedArticlesNotifier] load error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggle bookmark: adds if not present, removes if present.
  Future<void> toggle(ApiArticle article) async {
    final current = state.valueOrNull ?? [];
    final isBookmarked = current.any((a) => a.id == article.id);
    final client = _ref.read(apiClientProvider).client;
    final interactionSvc = _ref.read(interactionServiceProvider);

    if (isBookmarked) {
      // Optimistic remove
      state = AsyncValue.data(
        current.where((a) => a.id != article.id).toList(),
      );
      try {
        await client.delete(ApiRoutes.userBookmarkById(article.id));
      } catch (e) {
        debugPrint('[BookmarkedArticlesNotifier] remove error: $e');
        // Revert on failure
        state = AsyncValue.data([...current]);
      }
    } else {
      // Optimistic add
      state = AsyncValue.data([article, ...current]);
      try {
        await client.post(ApiRoutes.userBookmarkById(article.id));
        await interactionSvc.recordBookmark(article.id);
      } catch (e) {
        debugPrint('[BookmarkedArticlesNotifier] add error: $e');
        // Revert on failure
        state = AsyncValue.data(
          current.where((a) => a.id != article.id).toList(),
        );
      }
    }
  }

  bool isBookmarked(int articleId) =>
      state.valueOrNull?.any((a) => a.id == articleId) ?? false;
}

// ── Legacy-compatible provider (set of IDs) ────────────────────────────────
// Kept so existing screens that watch bookmarksProvider<Set<int>> still compile.
// They will be migrated to bookmarkedArticlesProvider progressively.

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, Set<int>>((
  ref,
) {
  // Mirror the bookmarkedArticlesProvider into a Set<int> automatically.
  final notifier = BookmarksNotifier();
  ref.listen(bookmarkedArticlesProvider, (_, next) {
    final ids = next.valueOrNull?.map((a) => a.id).toSet() ?? {};
    notifier.replaceAll(ids);
  });
  return notifier;
});

class BookmarksNotifier extends StateNotifier<Set<int>> {
  BookmarksNotifier() : super({});

  void replaceAll(Set<int> ids) {
    state = ids;
  }

  /// Direct toggle — kept for backward compat, but prefer using
  /// [BookmarkedArticlesNotifier.toggle] which hits the backend.
  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  bool isBookmarked(int id) => state.contains(id);
}
