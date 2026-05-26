import 'package:flutter/material.dart';

/// Mental wellness score calculator
///
/// Computes a composite mental wellness score (0-100) based on:
/// - Mood trends from behavior logs
/// - Activity level consistency
/// - Feeding regularity
/// - Vaccination compliance
/// - Medication adherence
class MentalWellnessScorer {
  /// Calculate overall mental wellness score (0-100)
  ///
  /// [avgBehaviorScore] — Average wellness score from behavior logs (0-100)
  /// [behaviorConsistency] — How consistent the behavior logs are (0-1, where 1 = very consistent)
  /// [feedingRegularity] — How regular the feeding is (0-1)
  /// [medicationAdherence] — Medication adherence rate (0-100)
  /// [daysSinceLastLog] — Days since last behavior log (0 = today)
  static double calculate({
    required double avgBehaviorScore,
    required double behaviorConsistency,
    required double feedingRegularity,
    required double medicationAdherence,
    required int daysSinceLastLog,
  }) {
    // Base score from behavior logs
    double score = avgBehaviorScore;

    // Consistency bonus (up to 15 points)
    score += behaviorConsistency * 15;

    // Feeding regularity contribution (up to 10 points)
    score += feedingRegularity * 10;

    // Medication adherence contribution (up to 5 points)
    score += (medicationAdherence / 100) * 5;

    // Decay for missing logs (lose 5 points per day without a log, max 30)
    if (daysSinceLastLog > 0) {
      final decay = (daysSinceLastLog * 5).clamp(0, 30);
      score -= decay;
    }

    return score.clamp(0, 100).toDouble();
  }

  /// Determine wellness category from score
  static String getCategory(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    if (score >= 30) return 'Needs Attention';
    return 'Critical';
  }

  /// Get category color
  static Color getCategoryColor(double score) {
    if (score >= 85) return const Color(0xFF52B788); // success dark
    if (score >= 70) return const Color(0xFFA8D5BA); // success
    if (score >= 50) return const Color(0xFFF8E167); // warning
    if (score >= 30) return const Color(0xFFF4A261); // primary
    return const Color(0xFFF2B8B8); // error
  }

  /// Get category icon
  static IconData getCategoryIcon(double score) {
    if (score >= 85) return Icons.emoji_objects;
    if (score >= 70) return Icons.sentiment_satisfied;
    if (score >= 50) return Icons.sentiment_neutral;
    if (score >= 30) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  /// Get wellness tips based on score
  static List<String> getTips(double score) {
    final tips = <String>[];

    if (score < 30) {
      tips.add('Consider consulting your veterinarian about your pet\'s wellbeing');
      tips.add('Ensure your pet is getting adequate rest and comfortable surroundings');
    }
    if (score < 50) {
      tips.add('Try increasing playtime and social interaction');
      tips.add('Monitor appetite and energy levels closely');
    }
    if (score < 70) {
      tips.add('Maintain a consistent daily routine for your pet');
      tips.add('Regular exercise helps reduce anxiety and improve mood');
    }
    tips.add('Keep logging behavior and activities to track progress');
    tips.add('Socialization and mental stimulation are key to wellness');

    return tips;
  }
}
