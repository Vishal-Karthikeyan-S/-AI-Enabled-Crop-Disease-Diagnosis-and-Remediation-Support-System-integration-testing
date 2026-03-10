import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/models/treatment_step.dart';

void main() {
  group('TreatmentStep', () {
    late TreatmentStep testStep;

    setUp(() {
      testStep = TreatmentStep(
        stepNumber: 1,
        title: 'Apply Organic Spray',
        description: 'Mix neem oil with water and spray on affected leaves',
        type: TreatmentType.organic,
        safetyLevel: SafetyLevel.safe,
        dosage: '10ml per liter',
        timing: 'Early morning',
        safetyWarnings: ['Avoid contact with eyes', 'Wash hands after use'],
        ppeRequired: ['Gloves', 'Mask'],
        iconPath: '/icons/spray.png',
        weatherDependent: true,
      );
    });

    group('TreatmentType enum', () {
      test('should have all treatment types', () {
        expect(TreatmentType.values.length, 4);
        expect(TreatmentType.organic.name, 'organic');
        expect(TreatmentType.chemical.name, 'chemical');
        expect(TreatmentType.cultural.name, 'cultural');
        expect(TreatmentType.preventive.name, 'preventive');
      });
    });

    group('SafetyLevel enum', () {
      test('should have all safety levels', () {
        expect(SafetyLevel.values.length, 4);
        expect(SafetyLevel.safe.name, 'safe');
        expect(SafetyLevel.caution.name, 'caution');
        expect(SafetyLevel.warning.name, 'warning');
        expect(SafetyLevel.danger.name, 'danger');
      });
    });

    group('Constructor', () {
      test('should create TreatmentStep with all fields', () {
        expect(testStep.stepNumber, 1);
        expect(testStep.title, 'Apply Organic Spray');
        expect(testStep.description, contains('neem oil'));
        expect(testStep.type, TreatmentType.organic);
        expect(testStep.safetyLevel, SafetyLevel.safe);
        expect(testStep.dosage, '10ml per liter');
        expect(testStep.timing, 'Early morning');
        expect(testStep.safetyWarnings.length, 2);
        expect(testStep.ppeRequired.length, 2);
        expect(testStep.weatherDependent, true);
      });

      test('should use default values for optional fields', () {
        final step = TreatmentStep(
          stepNumber: 1,
          title: 'Simple Step',
          description: 'A simple treatment step',
          type: TreatmentType.cultural,
        );

        expect(step.safetyLevel, SafetyLevel.safe);
        expect(step.dosage, isNull);
        expect(step.timing, isNull);
        expect(step.safetyWarnings, isEmpty);
        expect(step.ppeRequired, isEmpty);
        expect(step.iconPath, isNull);
        expect(step.weatherDependent, false);
      });
    });

    group('safetyEmoji', () {
      test('should return correct emoji for each safety level', () {
        final safetyEmojis = {
          SafetyLevel.safe: '✅',
          SafetyLevel.caution: '⚠️',
          SafetyLevel.warning: '❗',
          SafetyLevel.danger: '☠️',
        };

        for (final entry in safetyEmojis.entries) {
          final step = TreatmentStep(
            stepNumber: 1,
            title: 'Test',
            description: 'Test',
            type: TreatmentType.organic,
            safetyLevel: entry.key,
          );

          expect(step.safetyEmoji, entry.value,
              reason: 'Expected ${entry.value} for ${entry.key}');
        }
      });
    });

    group('typeEmoji', () {
      test('should return correct emoji for each treatment type', () {
        final typeEmojis = {
          TreatmentType.organic: '🌱',
          TreatmentType.chemical: '⚗️',
          TreatmentType.cultural: '🛠️',
          TreatmentType.preventive: '🛡️',
        };

        for (final entry in typeEmojis.entries) {
          final step = TreatmentStep(
            stepNumber: 1,
            title: 'Test',
            description: 'Test',
            type: entry.key,
          );

          expect(step.typeEmoji, entry.value,
              reason: 'Expected ${entry.value} for ${entry.key}');
        }
      });
    });

    group('toMap', () {
      test('should serialize all fields correctly', () {
        final map = testStep.toMap();

        expect(map['stepNumber'], 1);
        expect(map['title'], 'Apply Organic Spray');
        expect(map['description'], contains('neem oil'));
        expect(map['type'], 'organic');
        expect(map['safetyLevel'], 'safe');
        expect(map['dosage'], '10ml per liter');
        expect(map['timing'], 'Early morning');
        expect(map['safetyWarnings'],
            'Avoid contact with eyes|Wash hands after use');
        expect(map['ppeRequired'], 'Gloves|Mask');
        expect(map['iconPath'], '/icons/spray.png');
        expect(map['weatherDependent'], 1);
      });

      test('should serialize empty lists as empty strings', () {
        final step = TreatmentStep(
          stepNumber: 1,
          title: 'Test',
          description: 'Test',
          type: TreatmentType.cultural,
        );

        final map = step.toMap();

        expect(map['safetyWarnings'], '');
        expect(map['ppeRequired'], '');
      });

      test('should serialize weatherDependent as 0 when false', () {
        final step = TreatmentStep(
          stepNumber: 1,
          title: 'Test',
          description: 'Test',
          type: TreatmentType.cultural,
          weatherDependent: false,
        );

        final map = step.toMap();

        expect(map['weatherDependent'], 0);
      });
    });

    group('fromMap', () {
      test('should deserialize all fields correctly', () {
        final map = {
          'stepNumber': 1,
          'title': 'Apply Organic Spray',
          'description': 'Mix neem oil with water',
          'type': 'organic',
          'safetyLevel': 'safe',
          'dosage': '10ml per liter',
          'timing': 'Early morning',
          'safetyWarnings': 'Avoid contact with eyes|Wash hands after use',
          'ppeRequired': 'Gloves|Mask',
          'iconPath': '/icons/spray.png',
          'weatherDependent': 1,
        };

        final step = TreatmentStep.fromMap(map);

        expect(step.stepNumber, 1);
        expect(step.title, 'Apply Organic Spray');
        expect(step.type, TreatmentType.organic);
        expect(step.safetyLevel, SafetyLevel.safe);
        expect(step.safetyWarnings.length, 2);
        expect(step.safetyWarnings[0], 'Avoid contact with eyes');
        expect(step.ppeRequired.length, 2);
        expect(step.weatherDependent, true);
      });

      test('should handle null safetyWarnings and ppeRequired', () {
        final map = {
          'stepNumber': 1,
          'title': 'Test',
          'description': 'Test',
          'type': 'cultural',
          'safetyLevel': 'safe',
          'safetyWarnings': null,
          'ppeRequired': null,
          'weatherDependent': 0,
        };

        final step = TreatmentStep.fromMap(map);

        expect(step.safetyWarnings, isEmpty);
        expect(step.ppeRequired, isEmpty);
      });
    });

    group('fromJson', () {
      test('should deserialize API response with snake_case keys', () {
        final json = {
          'step_number': 1,
          'title': 'Apply Organic Spray',
          'description': 'Mix neem oil with water',
          'type': 'organic',
          'safety_level': 'caution',
          'dosage': '10ml per liter',
          'timing': 'Early morning',
          'safety_warnings': [
            'Avoid contact with eyes',
            'Wash hands after use'
          ],
          'ppe_required': ['Gloves', 'Mask'],
          'icon_path': '/icons/spray.png',
          'weather_dependent': true,
        };

        final step = TreatmentStep.fromJson(json);

        expect(step.stepNumber, 1);
        expect(step.title, 'Apply Organic Spray');
        expect(step.type, TreatmentType.organic);
        expect(step.safetyLevel, SafetyLevel.caution);
        expect(step.safetyWarnings.length, 2);
        expect(step.ppeRequired.length, 2);
        expect(step.weatherDependent, true);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final step = TreatmentStep.fromJson(json);

        expect(step.stepNumber, 0);
        expect(step.title, '');
        expect(step.description, '');
        expect(step.type, TreatmentType.cultural); // default orElse
        expect(step.safetyLevel, SafetyLevel.safe); // default orElse
        expect(step.safetyWarnings, isEmpty);
        expect(step.ppeRequired, isEmpty);
        expect(step.weatherDependent, false);
      });

      test('should handle invalid type with default', () {
        final json = {
          'type': 'invalid_type',
        };

        final step = TreatmentStep.fromJson(json);

        expect(step.type, TreatmentType.cultural);
      });
    });
  });

  group('Treatment', () {
    group('fromJson', () {
      test('should deserialize Treatment with nested TreatmentSteps', () {
        final json = {
          'disease_id': 'disease123',
          'disease_name': 'Leaf Blight',
          'organic_steps': [
            {
              'step_number': 1,
              'title': 'Organic Step 1',
              'description': 'Description 1',
              'type': 'organic',
              'safety_level': 'safe',
            },
          ],
          'chemical_steps': [
            {
              'step_number': 1,
              'title': 'Chemical Step 1',
              'description': 'Description 1',
              'type': 'chemical',
              'safety_level': 'warning',
            },
          ],
          'general_advice': 'Keep plants dry',
          'rain_warning': true,
          'weather_condition': 'Avoid rain for 24 hours',
        };

        final treatment = Treatment.fromJson(json);

        expect(treatment.diseaseId, 'disease123');
        expect(treatment.diseaseName, 'Leaf Blight');
        expect(treatment.organicSteps.length, 1);
        expect(treatment.chemicalSteps.length, 1);
        expect(treatment.organicSteps[0].type, TreatmentType.organic);
        expect(treatment.chemicalSteps[0].safetyLevel, SafetyLevel.warning);
        expect(treatment.generalAdvice, 'Keep plants dry');
        expect(treatment.rainWarning, true);
        expect(treatment.weatherCondition, 'Avoid rain for 24 hours');
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final treatment = Treatment.fromJson(json);

        expect(treatment.diseaseId, '');
        expect(treatment.diseaseName, '');
        expect(treatment.organicSteps, isEmpty);
        expect(treatment.chemicalSteps, isEmpty);
        expect(treatment.generalAdvice, isNull);
        expect(treatment.rainWarning, false);
        expect(treatment.weatherCondition, isNull);
      });

      test('should handle null step arrays', () {
        final json = {
          'disease_id': 'disease123',
          'organic_steps': null,
          'chemical_steps': null,
        };

        final treatment = Treatment.fromJson(json);

        expect(treatment.organicSteps, isEmpty);
        expect(treatment.chemicalSteps, isEmpty);
      });
    });
  });
}
