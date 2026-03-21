import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/bookmarks_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../feed/data/feed_provider.dart';
import 'widgets/search_sections.dart';

const _trendingTopics = [
  'AI Policy',
  'RBI',
  'Budget 2026',
  'Supreme Court',
  'Climate',
  'Education',
  'Digital Privacy',
  'Finance',
  'Technology',
  'Global',
  'Laws',
  'Society',
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';
  final List<String> _recents = [
    'India AI Summit',
    'RBI interest rates',
    'Digital Privacy',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _query = _controller.text.trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<ApiArticle> get _results {
    if (_query.isEmpty) {
      return [];
    }
    final query = _query.toLowerCase();
    final feedArticles = ref.read(feedProvider).valueOrNull ?? [];
    return feedArticles.where((article) {
      return article.title.toLowerCase().contains(query) ||
          (article.source?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _applyQuery(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    setState(() => _query = text);
    _focusNode.unfocus();
    if (!_recents.contains(text)) {
      setState(() {
        _recents.insert(0, text);
        if (_recents.length > 6) {
          _recents.removeLast();
        }
      });
    }
  }

  void _clearRecent(String item) => setState(() => _recents.remove(item));

  void _clearAll() => setState(() => _recents.clear());

  @override
  Widget build(BuildContext context) {
    final bookmarked = ref.watch(bookmarksProvider);
    final showResults = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchBarSection(
              controller: _controller,
              focusNode: _focusNode,
              onClear: () {
                _controller.clear();
                _focusNode.requestFocus();
              },
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: showResults
                  ? SearchResultsBody(
                      query: _query,
                      results: _results,
                      bookmarked: bookmarked,
                      ref: ref,
                    )
                  : SearchIdleBody(
                      recents: _recents,
                      trendingTopics: _trendingTopics,
                      onRecentTap: _applyQuery,
                      onClearRecent: _clearRecent,
                      onClearAll: _clearAll,
                      onTopicTap: _applyQuery,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
