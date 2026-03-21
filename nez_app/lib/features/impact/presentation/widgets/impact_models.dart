import '../../../feed/data/article_model.dart';

enum PanelType { paragraph, bullets }

class PanelData {
  const PanelData({
    required this.label,
    required this.labelIndex,
    required this.content,
    required this.type,
    this.bullets,
  });

  final String label;
  final String labelIndex;
  final String content;
  final PanelType type;
  final List<String>? bullets;
}

List<PanelData> buildImpactPanels(ArticleImpact impact) {
  return [
    PanelData(
      label: 'OVERVIEW',
      labelIndex: '01',
      content: impact.whatHappened,
      type: PanelType.paragraph,
    ),
    PanelData(
      label: 'IN CONTEXT',
      labelIndex: '02',
      content: impact.whatYouShouldKnow,
      type: PanelType.paragraph,
    ),
    PanelData(
      label: 'WHY IT MATTERS',
      labelIndex: '03',
      content: '',
      bullets: impact.whyItMatters,
      type: PanelType.bullets,
    ),
  ];
}
