import 'package:flutter/material.dart';

class PersonalizedInsight {
  PersonalizedInsight({
    required this.category,
    required this.icon,
    required this.title,
    required this.insight,
    required this.actionLabel,
    required this.color,
  });

  final String category;
  final IconData icon;
  final String title;
  final String insight;
  final String actionLabel;
  final Color color;
}
