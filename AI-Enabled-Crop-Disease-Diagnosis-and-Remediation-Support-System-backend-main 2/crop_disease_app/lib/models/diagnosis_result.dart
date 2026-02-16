enum DiseaseSeverity { low, medium, high, unknown }

class DiagnosisResult {
  final String id;
  final String submissionId;
  final String diseaseName;
  final DiseaseSeverity severity;
  final double confidence; // 0.0 to 1.0
  final String? diseaseIcon; // Path to disease icon
  final String? description;
  final DateTime diagnosedAt;
  final bool isUnknown; // True if confidence is too low

  DiagnosisResult({
    required this.id,
    required this.submissionId,
    required this.diseaseName,
    required this.severity,
    required this.confidence,
    this.diseaseIcon,
    this.description,
    required this.diagnosedAt,
    this.isUnknown = false,
  });

  // Get severity color
  String get severityColor {
    switch (severity) {
      case DiseaseSeverity.low:
        return 'green';
      case DiseaseSeverity.medium:
        return 'yellow';
      case DiseaseSeverity.high:
        return 'red';
      case DiseaseSeverity.unknown:
        return 'grey';
    }
  }

  // Get severity emoji
  String get severityEmoji {
    switch (severity) {
      case DiseaseSeverity.low:
        return '🟢';
      case DiseaseSeverity.medium:
        return '🟡';
      case DiseaseSeverity.high:
        return '🔴';
      case DiseaseSeverity.unknown:
        return '⚪';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'submissionId': submissionId,
      'diseaseName': diseaseName,
      'severity': severity.name,
      'confidence': confidence,
      'diseaseIcon': diseaseIcon,
      'description': description,
      'diagnosedAt': diagnosedAt.toIso8601String(),
      'isUnknown': isUnknown ? 1 : 0,
    };
  }

  factory DiagnosisResult.fromMap(Map<String, dynamic> map) {
    return DiagnosisResult(
      id: map['id'],
      submissionId: map['submissionId'],
      diseaseName: map['diseaseName'],
      severity:
          DiseaseSeverity.values.firstWhere((e) => e.name == map['severity']),
      confidence: map['confidence'],
      diseaseIcon: map['diseaseIcon'],
      description: map['description'],
      diagnosedAt: DateTime.parse(map['diagnosedAt']),
      isUnknown: map['isUnknown'] == 1,
    );
  }

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    // Parse from backend API response
    final confidence = (json['confidence'] ?? 0.0).toDouble();
    final isUnknown = confidence < 0.7; // Threshold for unknown

    return DiagnosisResult(
      id: json['id'] ?? '',
      submissionId: json['submission_id'] ?? '',
      diseaseName: json['disease_name'] ?? 'Unknown',
      severity: _parseSeverity(json['severity']),
      confidence: confidence,
      diseaseIcon: json['disease_icon'],
      description: json['description'],
      diagnosedAt: json['diagnosed_at'] != null
          ? DateTime.parse(json['diagnosed_at'])
          : DateTime.now(),
      isUnknown: isUnknown,
    );
  }

  static DiseaseSeverity _parseSeverity(dynamic severity) {
    if (severity == null) return DiseaseSeverity.unknown;
    if (severity is String) {
      return DiseaseSeverity.values.firstWhere(
        (e) => e.name.toLowerCase() == severity.toLowerCase(),
        orElse: () => DiseaseSeverity.unknown,
      );
    }
    return DiseaseSeverity.unknown;
  }
}
