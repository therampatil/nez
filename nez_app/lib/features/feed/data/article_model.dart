// ──────────────────────────────────────────────
// IMPACT DETAIL — three-panel breakdown
// ──────────────────────────────────────────────
class ArticleImpact {
  const ArticleImpact({
    required this.whatHappened,
    required this.whatYouShouldKnow,
    required this.whyItMatters, // list of bullet points
  });

  final String whatHappened;
  final String whatYouShouldKnow;
  final List<String> whyItMatters;
}

// ──────────────────────────────────────────────
// ARTICLE MODEL — shared across home + bookmarks
// ──────────────────────────────────────────────
class Article {
  const Article({
    required this.headline,
    required this.timeAgo,
    required this.source,
    this.hasAudio = false,
    this.impact,
    this.category = 'News Feed',
  });

  final String headline;
  final String timeAgo;
  final String source;
  final bool hasAudio;
  final ArticleImpact? impact;

  /// Category tag — matches one of the values in _feedCategories on HomeScreen.
  final String category;
}

// ──────────────────────────────────────────────
// MOCK ARTICLE DATA
// ──────────────────────────────────────────────
const List<Article> allArticles = [
  Article(
    headline: 'India Pushes for "Human-Centric AI" at Global Summit',
    timeAgo: '2 hr ago',
    source: 'Hindustan Times',
    hasAudio: true,
    category: 'Technology',
    impact: ArticleImpact(
      whatHappened:
          'India said AI must remain human-centric and inclusive, with fair access '
          'to AI resources.\nAt the upcoming AI Impact Summit 2026, the government '
          'positioned India as a voice for responsible AI growth.',
      whatYouShouldKnow:
          'No new AI law has been announced yet. India says it prefers an '
          'innovation-first approach, but regulation may follow if needed. '
          'Global AI governance talks are still in early stages.',
      whyItMatters: [
        'Strong policy support for Indian AI startups',
        'More focus on AI innovation within India',
        'Potential long-term growth in AI jobs & research',
      ],
    ),
  ),
  Article(
    headline: 'RBI Holds Interest Rates Steady Amid Global Uncertainty',
    timeAgo: '4 hr ago',
    source: 'Economic Times',
    category: 'Finance',
    impact: ArticleImpact(
      whatHappened:
          'The Reserve Bank of India kept the repo rate unchanged at 6.5% during '
          'its February 2026 monetary policy meeting, citing global economic '
          'headwinds and the need to monitor inflation trends.',
      whatYouShouldKnow:
          'Home loan and EMI rates are unlikely to change in the near term. '
          'The RBI is watching global cues — especially US Fed decisions — '
          'before making any rate cuts.',
      whyItMatters: [
        'Your home loan EMI stays the same for now',
        'Fixed deposits will continue to offer current rates',
        'Stock markets may react positively to stability',
      ],
    ),
  ),
  Article(
    headline: 'New Education Policy to Reshape College Admissions by 2027',
    timeAgo: '6 hr ago',
    source: 'NDTV',
    hasAudio: true,
    category: 'Society',
    impact: ArticleImpact(
      whatHappened:
          'The Ministry of Education announced a sweeping overhaul of college '
          'admission processes under NEP 2020. A common entrance test for most '
          'central universities is expected to go live by 2027.',
      whatYouShouldKnow:
          'Students appearing for board exams in 2026–27 should watch for '
          'updated CUET patterns. State universities may follow a separate '
          'timeline under respective state governments.',
      whyItMatters: [
        'Uniform admissions reduce board exam pressure',
        'Skills-based assessment to replace rote learning',
        'Wider choice of subjects for undergraduate students',
      ],
    ),
  ),
  Article(
    headline: 'Climate Council Agrees on New Emission Targets for 2035',
    timeAgo: '8 hr ago',
    source: 'The Hindu',
    category: 'Global',
    impact: ArticleImpact(
      whatHappened:
          'The Global Climate Council finalised binding emission reduction targets '
          'for member nations at its February summit. India committed to cutting '
          'carbon intensity by 45% from 2005 levels by 2035.',
      whatYouShouldKnow:
          'India\'s commitment aligns with its existing NDC targets. Heavy '
          'industries like steel, cement and coal will face stricter timelines. '
          'Green energy investment is expected to surge.',
      whyItMatters: [
        'Faster push for renewable energy projects',
        'Higher green taxes may affect some consumer goods',
        'New jobs in solar, wind and EV sectors',
      ],
    ),
  ),
  Article(
    headline: 'Supreme Court Rules on Right to Digital Privacy',
    timeAgo: '10 hr ago',
    source: 'LiveLaw',
    hasAudio: true,
    category: 'Laws',
    impact: ArticleImpact(
      whatHappened:
          'The Supreme Court of India delivered a landmark judgment affirming '
          'digital privacy as a fundamental right. The ruling sets boundaries on '
          'how government agencies can access personal digital data.',
      whatYouShouldKnow:
          'The judgment applies to government surveillance, not private companies '
          'directly. However, it strengthens the case for a robust Data Protection '
          'Act and may influence upcoming digital policy.',
      whyItMatters: [
        'Your personal data gets stronger legal protection',
        'Stricter rules on government digital surveillance',
        'Boost to India\'s data protection framework',
      ],
    ),
  ),
];
