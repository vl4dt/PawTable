import 'package:flutter/material.dart';

/// Health score calculator — composite wellness metric
///
/// Aggregates data from multiple tracking sources to produce
/// an overall health score (0-100) with detailed breakdown.
class HealthScoreCalculator {
  /// Calculate overall health score (0-100)
  ///
  /// Weights:
  /// - Behavior/Mood: 25%
  /// - Nutrition (feeding regularity): 25%
  /// - Medical compliance: 20% (vaccination + medication)
  /// - Physical (activity + weight trend): 15%
  /// - Hydration: 15%
  static HealthScoreResult calculate({
    required double? avgBehaviorScore,
    required double? feedingRegularity,
    required double? medicationAdherence,
    required int? vaccinationsUpToDate,
    required double? totalVaccinations,
    required double? avgActivityLevel,
    required double? weightStability,
    required double? hydrationLevel,
    required int? daysSinceLastBehaviorLog,
  }) {
    // Behavior/Mood score (max 25)
    final behaviorScore = avgBehaviorScore != null
        ? (avgBehaviorScore / 100) * 25
        : 0;

    // Nutrition score (max 25)
    final nutritionScore = feedingRegularity != null
        ? feedingRegularity * 25
        : 0;

    // Medical compliance score (max 20)
    final medScore = medicationAdherence != null
        ? (medicationAdherence / 100) * 10
        : 0;
    final vaccineScore = (totalVaccinations != null && totalVaccinations > 0)
        ? ((vaccinationsUpToDate ?? 0) / totalVaccinations) * 10
        : 0;
    final medicalScore = medScore + vaccineScore;

    // Physical score (max 15)
    final physicalScore = (avgActivityLevel != null
            ? (avgActivityLevel / 4.0) * 8
            : 4) +
        (weightStability != null ? weightStability * 7 : 3.5);

    // Hydration score (max 15)
    final hydrationScore = hydrationLevel != null ? hydrationLevel * 15 : 5;

    // Total score
    double total = behaviorScore +
        nutritionScore +
        medicalScore +
        physicalScore +
        hydrationScore;

    // Decay for missing logs
    if (daysSinceLastBehaviorLog != null && daysSinceLastBehaviorLog > 0) {
      total -= (daysSinceLastBehaviorLog * 2).clamp(0, 20).toDouble();
    }

    total = total.clamp(0, 100);

    // Determine category
    String category;
    Color categoryColor;
    IconData categoryIcon;

    if (total >= 85) {
      category = 'Excellent';
      categoryColor = const Color(0xFF52B788);
      categoryIcon = Icons.emoji_objects;
    } else if (total >= 70) {
      category = 'Good';
      categoryColor = const Color(0xFFA8D5BA);
      categoryIcon = Icons.sentiment_satisfied;
    } else if (total >= 50) {
      category = 'Fair';
      categoryColor = const Color(0xFFF8E167);
      categoryIcon = Icons.sentiment_neutral;
    } else if (total >= 30) {
      category = 'Needs Attention';
      categoryColor = const Color(0xFFF4A261);
      categoryIcon = Icons.sentiment_dissatisfied;
    } else {
      category = 'Critical';
      categoryColor = const Color(0xFFF2B8B8);
      categoryIcon = Icons.sentiment_very_dissatisfied;
    }

    return HealthScoreResult(
      score: total.round(),
      category: category,
      categoryColor: categoryColor,
      categoryIcon: categoryIcon,
      breakdown: {
        'behavior': behaviorScore.toDouble(),
        'nutrition': nutritionScore.toDouble(),
        'medical': medicalScore.toDouble(),
        'physical': physicalScore.toDouble(),
        'hydration': hydrationScore.toDouble(),
      },
      tips: _getHealthTips(total),
    );
  }

  static List<String> _getHealthTips(double score) {
    final tips = <String>[];

    if (score < 30) {
      tips.add('🩺 Please consult your veterinarian as soon as possible');
      tips.add('📋 Keep a detailed health journal to share with your vet');
      tips.add('🏠 Ensure your pet has a safe, comfortable environment');
    } else if (score < 50) {
      tips.add('📅 Schedule a wellness checkup with your vet');
      tips.add('🍽️ Monitor your pet\'s appetite and eating habits');
      tips.add('😴 Ensure adequate rest and a calm environment');
    } else if (score < 70) {
      tips.add('🐾 Increase daily exercise and playtime');
      tips.add('🧠 Provide mental stimulation with puzzles and training');
      tips.add('💧 Ensure fresh water is always available');
    }

    tips.add('📝 Regular health logging helps catch issues early');
    tips.add('🗓️ Keep vaccinations and medications up to date');
    tips.add('🤝 Socialization is important for your pet\'s mental health');

    return tips;
  }
}

/// Result of health score calculation
class HealthScoreResult {
  final int score;
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;
  final Map<String, double> breakdown;
  final List<String> tips;

  const HealthScoreResult({
    required this.score,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
    required this.breakdown,
    required this.tips,
  });

  /// Get percentage for a breakdown category (for progress indicators)
  double getPercentage(String category) {
    final value = breakdown[category] ?? 0;
    final maxValues = {
      'behavior': 25.0,
      'nutrition': 25.0,
      'medical': 20.0,
      'physical': 15.0,
      'hydration': 15.0,
    };
    final max = maxValues[category] ?? 1;
    return (value / max * 100).clamp(0, 100);
  }
}
