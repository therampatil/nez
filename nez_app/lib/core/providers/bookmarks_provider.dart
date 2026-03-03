import 'package:flutter_riverpod/flutter_riverpod.dart';

// ──────────────────────────────────────────────
// BOOKMARKS STATE — set of bookmarked article IDs
// ──────────────────────────────────────────────
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, Set<int>>(
  (ref) => BookmarksNotifier(),
);

class BookmarksNotifier extends StateNotifier<Set<int>> {
  BookmarksNotifier() : super({});

  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }

  bool isBookmarked(int id) => state.contains(id);
}
