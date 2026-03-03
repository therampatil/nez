// ──────────────────────────────────────────────
// NOTIFICATION MODEL
// ──────────────────────────────────────────────
enum NotificationType { ai, finance, news, general }

class NezNotification {
  const NezNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    this.sourceName,
    this.articleIndex, // non-null = links to a news article
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final String? sourceName;

  /// When set, tapping the notification opens the corresponding article.
  final int? articleIndex;

  NezNotification copyWith({bool? isRead}) => NezNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    timeAgo: timeAgo,
    isRead: isRead ?? this.isRead,
    sourceName: sourceName,
    articleIndex: articleIndex,
  );
}

// ──────────────────────────────────────────────
// MOCK NOTIFICATION DATA
// ──────────────────────────────────────────────
final List<NezNotification> mockNotifications = [
  NezNotification(
    id: 'n1',
    type: NotificationType.news,
    title: 'AI Insight Ready',
    body:
        'Your daily AI briefing on "India\'s Tech Policy" is ready. Tap to explore key takeaways.',
    timeAgo: 'Just now',
    sourceName: 'Nez AI',
    articleIndex: 0, // → India Pushes for Human-Centric AI
  ),
  NezNotification(
    id: 'n2',
    type: NotificationType.news,
    title: 'Market Update',
    body:
        'Sensex gains 450 points as RBI holds rates. Check your watchlist for top movers.',
    timeAgo: '15 min ago',
    sourceName: 'Economic Times',
    articleIndex: 1, // → RBI Holds Interest Rates
  ),
  NezNotification(
    id: 'n3',
    type: NotificationType.news,
    title: 'New Analysis Available',
    body:
        'AI has summarised the Supreme Court\'s ruling on digital privacy. Read the 2-min brief.',
    timeAgo: '1 hr ago',
    sourceName: 'Nez AI',
    articleIndex: 4, // → Supreme Court Rules on Digital Privacy
  ),
  NezNotification(
    id: 'n4',
    type: NotificationType.finance,
    title: 'Budget Alert',
    body:
        'Finance Ministry releases mid-year budget review. New tax slabs may affect your savings.',
    timeAgo: '3 hr ago',
    sourceName: 'LiveMint',
  ),
  NezNotification(
    id: 'n5',
    type: NotificationType.ai,
    title: 'Weekly AI Digest',
    body:
        'Your personalised week-in-review is ready — 5 stories, 3 key themes, 1 deep-dive.',
    timeAgo: '6 hr ago',
    sourceName: 'Nez AI',
    isRead: true,
  ),
  NezNotification(
    id: 'n6',
    type: NotificationType.finance,
    title: 'Investment Insight',
    body:
        'Gold hits ₹75,000 per 10g. Analysts suggest re-evaluating portfolio allocation.',
    timeAgo: '8 hr ago',
    sourceName: 'Business Standard',
    isRead: true,
  ),
  NezNotification(
    id: 'n7',
    type: NotificationType.news,
    title: 'Climate Story',
    body:
        'New Climate Council agreements decoded — understand the impact on Indian industries.',
    timeAgo: 'Yesterday',
    sourceName: 'Nez AI',
    isRead: true,
    articleIndex: 3, // → Climate Council Agrees on Emission Targets
  ),
  NezNotification(
    id: 'n8',
    type: NotificationType.finance,
    title: 'Currency Alert',
    body:
        'Rupee strengthens to ₹83.2 vs USD. Positive signal for import-heavy sectors.',
    timeAgo: 'Yesterday',
    sourceName: 'Reuters',
    isRead: true,
  ),
];
