import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/api_client.dart';
import 'article_model.dart';

// ──────────────────────────────────────────────
// API ARTICLE MODEL (from backend)
// ──────────────────────────────────────────────
class ApiArticle {
  const ApiArticle({
    required this.id,
    required this.title,
    this.source,
    this.publishedAt,
    this.category,
    this.overview,
    this.whyThisMatters,
    this.impact,
  });

  final int id;
  final String title;
  final String? source;
  final DateTime? publishedAt;

  /// Category tag — matches values in _feedCategories on HomeScreen
  /// (e.g. 'Technology', 'Laws', 'Business', etc.)
  final String? category;

  // ── News article breakdown fields ──────────────────────────
  /// What Happened — plain prose paragraph.
  final String? overview;

  /// Why This Matters — plain prose paragraph.
  final String? whyThisMatters;

  /// Impact / What You Should Know — plain prose paragraph.
  final String? impact;

  /// Parsed bullet list from [whyThisMatters].
  List<String> get whyItMattersBullets {
    if (whyThisMatters == null || whyThisMatters!.trim().isEmpty) return [];
    return whyThisMatters!
        .split('\n')
        .map((b) => b.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim())
        .where((b) => b.isNotEmpty)
        .toList();
  }

  factory ApiArticle.fromJson(Map<String, dynamic> json) {
    return ApiArticle(
      id: json['id'] as int,
      title: json['title'] as String,
      source: json['source'] as String?,
      publishedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      category: json['category'] as String?,
      overview: json['overview'] as String?,
      whyThisMatters: json['why_this_matters'] as String?,
      impact: json['impact'] as String?,
    );
  }

  /// Convert a static [Article] (mock data) into an [ApiArticle] so
  /// screens that still use the local article list can open ImpactScreen.
  factory ApiArticle.fromArticle(Article local, {int id = 0}) {
    final imp = local.impact;
    return ApiArticle(
      id: id,
      title: local.headline,
      source: local.source,
      category: local.category,
      overview: imp?.whatHappened,
      whyThisMatters: imp?.whyItMatters.map((b) => '• $b').join('\n'),
      impact: imp?.whatYouShouldKnow,
    );
  }

  /// Human-readable relative time string.
  String get timeAgo {
    if (publishedAt == null) return '';
    final diff = DateTime.now().difference(publishedAt!.toLocal());
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ──────────────────────────────────────────────
// FEED PROVIDER (personalized, JWT-authenticated)
// ──────────────────────────────────────────────
final feedProvider = FutureProvider.autoDispose<List<ApiArticle>>((ref) async {
  final client = ref.read(apiClientProvider).client;
  final response = await client.get('/feed/', queryParameters: {'limit': 100});
  final list = response.data['articles'] as List<dynamic>;
  return list
      .map((e) => ApiArticle.fromJson(e as Map<String, dynamic>))
      .toList();
});
