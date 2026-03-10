enum TreatmentType { organic, chemical, cultural, preventive }

enum SafetyLevel { safe, caution, warning, danger }

class TreatmentStep {
  final int stepNumber;
  final String title;
  final String description;
  final TreatmentType type;
  final SafetyLevel safetyLevel;
  final String? dosage;
  final String? timing;
  final List<String> safetyWarnings;
  final List<String> ppeRequired; // Personal Protective Equipment
  final String? iconPath;
  final bool weatherDependent;

  TreatmentStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.type,
    this.safetyLevel = SafetyLevel.safe,
    this.dosage,
    this.timing,
    this.safetyWarnings = const [],
    this.ppeRequired = const [],
    this.iconPath,
    this.weatherDependent = false,
  });

  // Get safety emoji
  String get safetyEmoji {
    switch (safetyLevel) {
      case SafetyLevel.safe:
        return '✅';
      case SafetyLevel.caution:
        return '⚠️';
      case SafetyLevel.warning:
        return '❗';
      case SafetyLevel.danger:
        return '☠️';
    }
  }

  // Get treatment type emoji
  String get typeEmoji {
    switch (type) {
      case TreatmentType.organic:
        return '🌱';
      case TreatmentType.chemical:
        return '⚗️';
      case TreatmentType.cultural:
        return '🛠️';
      case TreatmentType.preventive:
        return '🛡️';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'type': type.name,
      'safetyLevel': safetyLevel.name,
      'dosage': dosage,
      'timing': timing,
      'safetyWarnings': safetyWarnings.join('|'),
      'ppeRequired': ppeRequired.join('|'),
      'iconPath': iconPath,
      'weatherDependent': weatherDependent ? 1 : 0,
    };
  }

  factory TreatmentStep.fromMap(Map<String, dynamic> map) {
    return TreatmentStep(
      stepNumber: map['stepNumber'],
      title: map['title'],
      description: map['description'],
      type: TreatmentType.values.firstWhere((e) => e.name == map['type']),
      safetyLevel:
          SafetyLevel.values.firstWhere((e) => e.name == map['safetyLevel']),
      dosage: map['dosage'],
      timing: map['timing'],
      safetyWarnings: map['safetyWarnings']?.split('|') ?? [],
      ppeRequired: map['ppeRequired']?.split('|') ?? [],
      iconPath: map['iconPath'],
      weatherDependent: map['weatherDependent'] == 1,
    );
  }

  factory TreatmentStep.fromJson(Map<String, dynamic> json) {
    return TreatmentStep(
      stepNumber: json['step_number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: TreatmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TreatmentType.cultural,
      ),
      safetyLevel: SafetyLevel.values.firstWhere(
        (e) => e.name == json['safety_level'],
        orElse: () => SafetyLevel.safe,
      ),
      dosage: json['dosage'],
      timing: json['timing'],
      safetyWarnings: (json['safety_warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ppeRequired: (json['ppe_required'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      iconPath: json['icon_path'],
      weatherDependent: json['weather_dependent'] ?? false,
    );
  }
}

class Treatment {
  final String diseaseId;
  final String diseaseName;
  final List<TreatmentStep> organicSteps;
  final List<TreatmentStep> chemicalSteps;
  final String? generalAdvice;
  final bool rainWarning;
  final String? weatherCondition;

  Treatment({
    required this.diseaseId,
    required this.diseaseName,
    this.organicSteps = const [],
    this.chemicalSteps = const [],
    this.generalAdvice,
    this.rainWarning = false,
    this.weatherCondition,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      diseaseId: json['disease_id'] ?? '',
      diseaseName: json['disease_name'] ?? '',
      organicSteps: (json['organic_steps'] as List<dynamic>?)
              ?.map((e) => TreatmentStep.fromJson(e))
              .toList() ??
          [],
      chemicalSteps: (json['chemical_steps'] as List<dynamic>?)
              ?.map((e) => TreatmentStep.fromJson(e))
              .toList() ??
          [],
      generalAdvice: json['general_advice'],
      rainWarning: json['rain_warning'] ?? false,
      weatherCondition: json['weather_condition'],
    );
  }
}
