import 'package:equatable/equatable.dart';

/// Health log entry — local Hive/SQLite model
class HealthLogLocalModel extends Equatable {
  final String id;
  final String petId;
  final String logType;
  final String title;
  final String? description;
  final String date;
  final String? severity;
  final String? imageUrl;

  const HealthLogLocalModel({
    required this.id,
    required this.petId,
    required this.logType,
    this.title = '',
    this.description,
    required this.date,
    this.severity,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'logType': logType,
        'title': title,
        'description': description,
        'date': date,
        'severity': severity,
        'imageUrl': imageUrl,
      };

  factory HealthLogLocalModel.fromJson(Map<String, dynamic> json) {
    return HealthLogLocalModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      logType: json['logType'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      date: json['date'] as String,
      severity: json['severity'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, petId, logType, title, description, date, severity, imageUrl];
}
