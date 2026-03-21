import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/api_routes.dart';
import 'article_model.dart';

// ──────────────────────────────────────────────
// API ARTICLE MODEL (from backend)
// ──────────────────────────────────────────────
class ApiArticle {
  const ApiArticle({
    required this.id,
    required this.title,
    this.articleUrl,
    this.imageUrl,
    this.source,
    this.publishedAt,
    this.category,
    this.overview,
    this.whyThisMatters,
    this.impact,
  });

  final int id;
  final String title;
  final String? articleUrl;
  final String? imageUrl;
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
      title: (json['title'] ?? json['headline']) as String,
      articleUrl: (json['url'] ?? json['article_url']) as String?,
      imageUrl: (json['image_url'] ??
              json['imageUrl'] ??
              json['image'] ??
              json['url_to_image']) as String?,
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

  factory ApiArticle.fromHeadlineJson(Map<String, dynamic> json) {
    return ApiArticle(
      id: json['id'] as int,
      title: json['headline'] as String,
      articleUrl: json['article_url'] as String?,
      imageUrl: (json['image_url'] ??
              json['imageUrl'] ??
              json['image'] ??
              json['url_to_image']) as String?,
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
  final response = await client.get(ApiRoutes.feed, queryParameters: {'limit': 100});
  final list = response.data['articles'] as List<dynamic>;
  return list
      .map((e) => ApiArticle.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ──────────────────────────────────────────────
// HEADLINES PROVIDER (read-only from news DB)
// ──────────────────────────────────────────────
final headlinesProvider = FutureProvider.autoDispose<List<ApiArticle>>((ref) async {
  final client = ref.read(apiClientProvider).client;
  try {
    final latestResponse = await client.get(
      ApiRoutes.headlinesLatest,
      queryParameters: {'limit': 12},
    );
    final latestList = latestResponse.data as List<dynamic>;
    return latestList
        .map((e) => ApiArticle.fromHeadlineJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    try {
      final latestNoSlashResponse = await client.get(
        ApiRoutes.headlinesLatestNoSlash,
        queryParameters: {'limit': 12},
      );
      final latestNoSlashList = latestNoSlashResponse.data as List<dynamic>;
      return latestNoSlashList
          .map((e) => ApiArticle.fromHeadlineJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      try {
        final listResponse = await client.get(
          ApiRoutes.headlinesList,
          queryParameters: {'limit': 12},
        );
        final list = listResponse.data as List<dynamic>;
        return list
            .map((e) => ApiArticle.fromHeadlineJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Graceful fallback to avoid crashing UI when this API isn't deployed yet.
        return [];
      }
    }
  }
});

// ──────────────────────────────────────────────
// BIG PICTURE PROVIDER
// ──────────────────────────────────────────────
final bigPictureProvider = FutureProvider.autoDispose<BigPictureData?>((ref) async {
  // TODO: Fetch from backend /big-picture/ endpoint
  // For now, return mock data
  return _mockBigPicture;
});

// Mock Big Picture Data
final _mockBigPicture = BigPictureData(
  title: 'AI is taking control of coding — and most CS students don\'t see it coming',
  subtitle: 'GitHub Copilot now writes 46% of all code. Junior dev roles dropped 22% in one quarter. This is the story that changes how you think about your degree.',
  categories: ['AI', 'CAREERS', 'EDUCATION'],
  readTime: '8 min · 5 layers',
  sections: [
    BigPictureSection(
      title: 'What happened',
      content: [
        TextBlock(
          'GitHub released new data showing that AI coding assistants like Copilot now generate 46% of all code written by developers globally. This represents a massive shift from just 27% six months ago.',
        ),
        StatBlock(
          stat: '46%',
          description: 'of all code is now written by AI assistants',
        ),
        TextBlock(
          'Meanwhile, major tech companies including Google, Microsoft, and Meta have reduced their junior developer hiring by 22% in Q1 2025 compared to the previous quarter. Entry-level positions that traditionally trained new graduates are disappearing.',
        ),
        StatBlock(
          stat: '-22%',
          description: 'drop in junior developer roles in one quarter',
        ),
      ],
    ),
    BigPictureSection(
      title: 'Why now',
      content: [
        TextBlock(
          'Three converging factors are accelerating this shift:',
        ),
        BulletListBlock([
          'AI models like GPT-4 and Claude have reached a threshold where they can generate production-quality code with minimal human oversight',
          'Economic pressure is pushing companies to reduce headcount while maintaining output',
          'The traditional "learn by doing" pathway for junior developers is being automated away',
        ]),
        QuoteBlock(
          quote: 'We\'re seeing a generational shift. The skills that got you hired five years ago won\'t get you hired today.',
          author: 'Tech recruiter at major FAANG company',
        ),
        TextBlock(
          'Universities haven\'t caught up. Most CS curricula still focus on teaching syntax and algorithms without addressing how to work effectively with AI tools or develop skills that AI cannot replicate.',
        ),
      ],
    ),
    BigPictureSection(
      title: 'The big shift',
      content: [
        TextBlock(
          'This isn\'t just about fewer jobs. It\'s about a fundamental restructuring of the software engineering career ladder:',
        ),
        BulletListBlock([
          'The "junior developer" role is evolving into "AI-assisted developer" requiring different skills',
          'Companies now expect new hires to be productive from day one using AI tools',
          'Traditional mentorship pathways are breaking down as senior developers manage AI systems instead of training juniors',
          'The skills gap between graduates and industry requirements is widening rapidly',
        ]),
        StatBlock(
          stat: '3-5 years',
          description: 'estimated time before AI can handle 70%+ of routine coding tasks',
        ),
        TextBlock(
          'Industry experts predict that within 3-5 years, AI will handle 70% or more of routine coding tasks. The developers who survive this transition will be those who can do what AI cannot: system design, architectural decisions, understanding business context, and creative problem-solving.',
        ),
      ],
    ),
    BigPictureSection(
      title: 'Who it affects',
      content: [
        TextBlock(
          'This shift has ripple effects across multiple groups:',
        ),
        BulletListBlock([
          'Current CS students: Your degree alone is no longer enough. You need to develop AI-augmented skills and differentiate yourself',
          'Junior developers: 40% of entry-level positions have disappeared. Competition for remaining roles is intense',
          'Bootcamp graduates: Programs that teach basic coding are losing value. Focus is shifting to AI prompt engineering and system design',
          'Mid-level developers: Safe for now, but need to adapt. Senior positions require orchestrating AI tools effectively',
          'Companies: Facing pressure to adopt AI or fall behind competitors who are 2-3x more productive',
        ]),
        StatBlock(
          stat: '1.5M',
          description: 'CS students in India potentially affected by this shift',
        ),
        TextBlock(
          'In India alone, approximately 1.5 million students are currently pursuing CS degrees. Most are unaware that the job market they\'re preparing for has fundamentally changed in the past 12 months.',
        ),
      ],
    ),
    BigPictureSection(
      title: 'What comes next — 3 scenarios',
      content: [
        TextBlock(
          'Three possible futures are emerging:',
        ),
        TextBlock(
          '1. The Great Consolidation\nAI becomes so capable that software teams shrink to 1/4 of their current size. Only the most exceptional developers remain employed. This leads to a massive surplus of CS graduates and a rethinking of tech education.',
        ),
        TextBlock(
          '2. The New Specialization\nDevelopers split into two tracks: "AI Orchestrators" who manage AI systems and "Deep Specialists" who handle complex problems AI cannot solve. Both tracks require skills not taught in current curricula.',
        ),
        TextBlock(
          '3. The Augmented Developer\nMost developers successfully adapt by becoming "AI-augmented." They use AI for routine tasks while focusing on higher-level work. This future requires massive re-training and curriculum updates.',
        ),
        QuoteBlock(
          quote: 'We\'re not preparing students for the world that exists. We\'re preparing them for a world that no longer exists.',
          author: 'CS Department Head, IIT Delhi',
        ),
        TextBlock(
          'The most likely outcome is a hybrid: some consolidation, new specializations emerging, and most developers adapting. But the transition will be painful for those caught unprepared.',
        ),
        BulletListBlock([
          'Universities must update curricula within 1-2 years or risk graduating unemployable students',
          'Students need to learn AI tool proficiency alongside traditional CS skills',
          'Companies must balance AI adoption with maintaining institutional knowledge',
          'Policy makers should consider reskilling programs for affected workers',
        ]),
      ],
    ),
  ],
);

// ──────────────────────────────────────────────
// BIG PICTURE DATA MODELS
// ──────────────────────────────────────────────

class BigPictureData {
  const BigPictureData({
    required this.title,
    required this.subtitle,
    required this.categories,
    required this.sections,
    this.readTime,
  });

  final String title;
  final String subtitle;
  final List<String> categories;
  final List<BigPictureSection> sections;
  final String? readTime;
}

class BigPictureSection {
  const BigPictureSection({
    required this.title,
    required this.content,
  });

  final String title;
  final List<ContentBlock> content;
}

// Content block types
abstract class ContentBlock {}

class TextBlock implements ContentBlock {
  const TextBlock(this.text);
  final String text;
}

class BulletListBlock implements ContentBlock {
  const BulletListBlock(this.items);
  final List<String> items;
}

class StatBlock implements ContentBlock {
  const StatBlock({
    required this.stat,
    required this.description,
  });
  final String stat;
  final String description;
}

class QuoteBlock implements ContentBlock {
  const QuoteBlock({
    required this.quote,
    this.author,
  });
  final String quote;
  final String? author;
}
