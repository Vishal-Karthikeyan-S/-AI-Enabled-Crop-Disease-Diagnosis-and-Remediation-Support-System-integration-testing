class CropModel {
  final String id;
  final String name;
  final String category; // 'paddy', 'wheat', 'vegetables', 'fruits'
  final String? subcategory; // e.g., 'tomato', 'potato', 'mango', 'banana'
  final Map<String, String> nameTranslations; // Multi-language support
  final Map<String, String> careInstructions;
  final Map<String, String> waterRequirements;
  final Map<String, String> growthDuration;
  final Map<String, List<Disease>> commonDiseases;
  final String? imagePath;

  CropModel({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.nameTranslations,
    required this.careInstructions,
    required this.waterRequirements,
    required this.growthDuration,
    required this.commonDiseases,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'nameTranslations': nameTranslations,
      'careInstructions': careInstructions,
      'waterRequirements': waterRequirements,
      'growthDuration': growthDuration,
      'commonDiseases': commonDiseases.map(
        (lang, diseases) => MapEntry(
          lang,
          diseases.map((d) => d.toJson()).toList(),
        ),
      ),
      'imagePath': imagePath,
    };
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      nameTranslations: Map<String, String>.from(json['nameTranslations']),
      careInstructions: Map<String, String>.from(json['careInstructions']),
      waterRequirements: Map<String, String>.from(json['waterRequirements']),
      growthDuration: Map<String, String>.from(json['growthDuration']),
      commonDiseases: (json['commonDiseases'] as Map<String, dynamic>).map(
        (lang, diseases) => MapEntry(
          lang,
          (diseases as List).map((d) => Disease.fromJson(d)).toList(),
        ),
      ),
      imagePath: json['imagePath'] as String?,
    );
  }
}

class Disease {
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> remedies;
  final String? imagePath;

  Disease({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.remedies,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'remedies': remedies,
      'imagePath': imagePath,
    };
  }

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'] as String,
      description: json['description'] as String,
      symptoms: List<String>.from(json['symptoms']),
      remedies: List<String>.from(json['remedies']),
      imagePath: json['imagePath'] as String?,
    );
  }
}
