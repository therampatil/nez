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
    this.description,
    this.imageUrl,
    this.source,
    this.publishedAt,
    this.categoryId,
    this.overview,
    this.inContext,
    this.whyItMatters,
  });

  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? source;
  final DateTime? publishedAt;
  final int? categoryId;

  // ── AI-generated 3-section breakdown ──────────────────────────────────
  /// What Happened — plain prose paragraph.
  final String? overview;

  /// In Context — background paragraph.
  final String? inContext;

  /// Why It Matters — newline-separated bullet strings (e.g. "• Foo\n• Bar").
  final String? whyItMatters;

  /// Parsed bullet list from [whyItMatters].
  List<String> get whyItMattersBullets {
    if (whyItMatters == null || whyItMatters!.trim().isEmpty) return [];
    return whyItMatters!
        .split('\n')
        .map((b) => b.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').trim())
        .where((b) => b.isNotEmpty)
        .toList();
  }

  factory ApiArticle.fromJson(Map<String, dynamic> json) {
    return ApiArticle(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: (json['image_url'] as String?)?.isNotEmpty == true
          ? json['image_url'] as String
          : null,
      source: json['source'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      categoryId: json['category_id'] as int?,
      overview: json['overview'] as String?,
      inContext: json['in_context'] as String?,
      whyItMatters: json['why_it_matters'] as String?,
    );
  }

  /// Convert a static [Article] (mock data) into an [ApiArticle] so
  /// screens that still use the local article list can open ImpactScreen.
  factory ApiArticle.fromArticle(Article local, {int id = 0}) {
    final impact = local.impact;
    return ApiArticle(
      id: id,
      title: local.headline,
      description: impact?.whatHappened,
      source: local.source,
      overview: impact?.whatHappened,
      inContext: impact?.whatYouShouldKnow,
      whyItMatters: impact?.whyItMatters.map((b) => '• $b').join('\n'),
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
  final response = await client.get('/feed/', queryParameters: {'limit': 50});
  final list = response.data['articles'] as List<dynamic>;
  return list
      .map((e) => ApiArticle.fromJson(e as Map<String, dynamic>))
      .toList();
});
