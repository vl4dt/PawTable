import 'dart:convert';

/// Data export service
///
/// Exports health tracking data in CSV (free) and PDF (premium) formats.
/// Supports exporting feeding logs, vaccinations, medications, weight logs,
/// and behavior logs.
class DataExportService {
  /// Export health data to CSV format
  ///
  /// Returns a CSV string with all tracking data.
  /// Free tier: CSV export only
  /// Premium tier: CSV + PDF export
  static Future<String> exportCSV({
    required List<Map<String, dynamic>> feedingLogs,
    required List<Map<String, dynamic>> vaccinations,
    required List<Map<String, dynamic>> medications,
    required List<Map<String, dynamic>> weightLogs,
    required List<Map<String, dynamic>> behaviorLogs,
    String? petName,
  }) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('PawTable Health Report');
    buffer.writeln('Pet: ${petName ?? "Unknown"}');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');

    // Feeding logs section
    buffer.writeln('=== FEEDING LOGS ===');
    buffer.writeln('ID,Pet ID,Type,Amount (g),Notes,Time');
    for (final log in feedingLogs) {
      buffer.writeln(
          '${_csvEscape(log['id'] ?? "")},${_csvEscape(log['petId'] ?? "")},${_csvEscape(log['type'] ?? "")},${log['amount'] ?? 0},${_csvEscape(log['notes'] ?? "")},${log['time'] ?? ""}');
    }
    buffer.writeln('');

    // Vaccination records section
    buffer.writeln('=== VACCINATION RECORDS ===');
    buffer.writeln('ID,Pet ID,Vaccine Name,Date Issued,Next Due,Batch Number,Notes');
    for (final v in vaccinations) {
      buffer.writeln(
          '${_csvEscape(v['id'] ?? "")},${_csvEscape(v['petId'] ?? "")},${_csvEscape(v['vaccineName'] ?? "")},${v['dateIssued'] ?? ""},${v['nextDueDate'] ?? ""},${_csvEscape(v['batchNumber'] ?? "")},${_csvEscape(v['notes'] ?? "")}');
    }
    buffer.writeln('');

    // Medication records section
    buffer.writeln('=== MEDICATION RECORDS ===');
    buffer.writeln('ID,Pet ID,Name,Dosage,Unit,Frequency,Start Date,End Date,Notes,Taken');
    for (final m in medications) {
      buffer.writeln(
          '${_csvEscape(m['id'] ?? "")},${_csvEscape(m['petId'] ?? "")},${_csvEscape(m['name'] ?? "")},${m['dosage'] ?? 0},${_csvEscape(m['unit'] ?? "")},${_csvEscape(m['frequency'] ?? "")},${m['startDate'] ?? ""},${m['endDate'] ?? ""},${_csvEscape(m['notes'] ?? "")},${m['taken'] ?? false}');
    }
    buffer.writeln('');

    // Weight logs section
    buffer.writeln('=== WEIGHT LOGS ===');
    buffer.writeln('ID,Pet ID,Weight (kg),Date,Notes');
    for (final w in weightLogs) {
      buffer.writeln(
          '${_csvEscape(w['id'] ?? "")},${_csvEscape(w['petId'] ?? "")},${w['weight'] ?? 0},${w['date'] ?? ""},${_csvEscape(w['notes'] ?? "")}');
    }
    buffer.writeln('');

    // Behavior logs section
    buffer.writeln('=== BEHAVIOR LOGS ===');
    buffer.writeln('ID,Pet ID,Mood,Activity Level,Notes,Date');
    for (final b in behaviorLogs) {
      buffer.writeln(
          '${_csvEscape(b['id'] ?? "")},${_csvEscape(b['petId'] ?? "")},${_csvEscape(b['mood'] ?? "")},${_csvEscape(b['activityLevel'] ?? "")},${_csvEscape(b['notes'] ?? "")},${b['date'] ?? ""}');
    }

    return Future.value(buffer.toString());
  }

  /// Export health data to PDF format (premium feature)
  ///
  /// Returns a base64-encoded PDF string.
  /// Requires premium subscription.
  static Future<String> exportPDF({
    required List<Map<String, dynamic>> feedingLogs,
    required List<Map<String, dynamic>> vaccinations,
    required List<Map<String, dynamic>> medications,
    required List<Map<String, dynamic>> weightLogs,
    required List<Map<String, dynamic>> behaviorLogs,
    String? petName,
    double? healthScore,
  }) async {
    // Generate a structured text representation that can be
    // rendered as a PDF by a rendering library.
    // In production, this would use a PDF library like pdf_package.
    final buffer = StringBuffer();

    buffer.writeln('====================================');
    buffer.writeln('    PAWTABLE HEALTH REPORT');
    buffer.writeln('====================================');
    buffer.writeln('');
    buffer.writeln('Pet: ${petName ?? "Unknown"}');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');

    if (healthScore != null) {
      buffer.writeln('Overall Health Score: ${healthScore.toStringAsFixed(0)}/100');
      buffer.writeln('');
    }

    // Feeding summary
    buffer.writeln('--- FEEDING SUMMARY ---');
    buffer.writeln('Total meals logged: ${feedingLogs.length}');
    if (feedingLogs.isNotEmpty) {
      buffer.writeln('Date range: ${feedingLogs.last['time'] ?? 'N/A'} to ${feedingLogs.first['time'] ?? 'N/A'}');
    }
    buffer.writeln('');

    // Vaccination summary
    buffer.writeln('--- VACCINATION SUMMARY ---');
    buffer.writeln('Total vaccinations: ${vaccinations.length}');
    buffer.writeln('');

    // Medication summary
    buffer.writeln('--- MEDICATION SUMMARY ---');
    buffer.writeln('Total medications: ${medications.length}');
    buffer.writeln('');

    // Weight summary
    buffer.writeln('--- WEIGHT SUMMARY ---');
    buffer.writeln('Total entries: ${weightLogs.length}');
    if (weightLogs.isNotEmpty) {
      final weights = weightLogs
          .map((w) => (w['weight'] as num?)?.toDouble() ?? 0)
          .where((w) => w > 0)
          .toList();
      if (weights.isNotEmpty) {
        buffer.writeln('Current weight: ${weights.first} kg');
        buffer.writeln('Weight range: ${weights.reduce((a, b) => a < b ? a : b)} - ${weights.reduce((a, b) => a > b ? a : b)} kg');
      }
    }
    buffer.writeln('');

    // Behavior summary
    buffer.writeln('--- BEHAVIOR SUMMARY ---');
    buffer.writeln('Total entries: ${behaviorLogs.length}');
    buffer.writeln('');

    buffer.writeln('--- END OF REPORT ---');
    buffer.writeln('Generated by PawTable v1.0.0');

    // In production, this would use a PDF library to generate actual PDF bytes
    // For now, return the text content encoded
    return base64Encode(utf8.encode(buffer.toString()));
  }

  /// Check if export feature is available
  static bool canExportCSV({required bool isPremium}) {
    return true; // Free users can export CSV
  }

  static bool canExportPDF({required bool isPremium}) {
    return isPremium; // Premium only
  }

  static String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
