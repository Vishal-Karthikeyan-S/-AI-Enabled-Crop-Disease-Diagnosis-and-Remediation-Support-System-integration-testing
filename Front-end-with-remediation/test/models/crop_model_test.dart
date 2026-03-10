import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/models/crop_model.dart';

void main() {
  group('CropModel', () {
    late CropModel testCrop;
    late Disease testDisease;

    setUp(() {
      testDisease = Disease(
        name: 'Leaf Blight',
        description: 'A fungal disease affecting leaves',
        symptoms: ['Yellow spots', 'Wilting leaves', 'Brown edges'],
        remedies: ['Apply fungicide', 'Remove affected leaves'],
        imagePath: '/images/leaf_blight.jpg',
      );

      testCrop = CropModel(
        id: 'crop123',
        name: 'Rice',
        category: 'paddy',
        subcategory: 'basmati',
        nameTranslations: {
          'en': 'Rice',
          'hi': 'चावल',
          'te': 'బియ్యం',
        },
        careInstructions: {
          'en': 'Keep soil moist',
          'hi': 'मिट्टी को नम रखें',
        },
        waterRequirements: {
          'en': 'High water requirement',
          'hi': 'उच्च पानी की आवश्यकता',
        },
        growthDuration: {
          'en': '120-150 days',
          'hi': '120-150 दिन',
        },
        commonDiseases: {
          'en': [testDisease],
        },
        imagePath: '/images/rice.jpg',
      );
    });

    group('Disease', () {
      group('Constructor', () {
        test('should create Disease with all fields', () {
          expect(testDisease.name, 'Leaf Blight');
          expect(testDisease.description, 'A fungal disease affecting leaves');
          expect(testDisease.symptoms.length, 3);
          expect(testDisease.remedies.length, 2);
          expect(testDisease.imagePath, '/images/leaf_blight.jpg');
        });

        test('should create Disease with null imagePath', () {
          final disease = Disease(
            name: 'Test Disease',
            description: 'Test description',
            symptoms: [],
            remedies: [],
          );

          expect(disease.imagePath, isNull);
        });
      });

      group('toJson', () {
        test('should serialize all fields correctly', () {
          final json = testDisease.toJson();

          expect(json['name'], 'Leaf Blight');
          expect(json['description'], 'A fungal disease affecting leaves');
          expect(json['symptoms'],
              ['Yellow spots', 'Wilting leaves', 'Brown edges']);
          expect(
              json['remedies'], ['Apply fungicide', 'Remove affected leaves']);
          expect(json['imagePath'], '/images/leaf_blight.jpg');
        });

        test('should serialize null imagePath', () {
          final disease = Disease(
            name: 'Test',
            description: 'Test',
            symptoms: [],
            remedies: [],
          );

          final json = disease.toJson();

          expect(json['imagePath'], isNull);
        });
      });

      group('fromJson', () {
        test('should deserialize all fields correctly', () {
          final json = {
            'name': 'Leaf Blight',
            'description': 'A fungal disease',
            'symptoms': ['Symptom 1', 'Symptom 2'],
            'remedies': ['Remedy 1'],
            'imagePath': '/images/disease.jpg',
          };

          final disease = Disease.fromJson(json);

          expect(disease.name, 'Leaf Blight');
          expect(disease.description, 'A fungal disease');
          expect(disease.symptoms.length, 2);
          expect(disease.remedies.length, 1);
          expect(disease.imagePath, '/images/disease.jpg');
        });

        test('should handle null imagePath', () {
          final json = {
            'name': 'Test',
            'description': 'Test',
            'symptoms': [],
            'remedies': [],
            'imagePath': null,
          };

          final disease = Disease.fromJson(json);

          expect(disease.imagePath, isNull);
        });
      });

      group('Round-trip serialization', () {
        test('should maintain data integrity through toJson/fromJson cycle',
            () {
          final json = testDisease.toJson();
          final reconstructed = Disease.fromJson(json);

          expect(reconstructed.name, testDisease.name);
          expect(reconstructed.description, testDisease.description);
          expect(reconstructed.symptoms, testDisease.symptoms);
          expect(reconstructed.remedies, testDisease.remedies);
          expect(reconstructed.imagePath, testDisease.imagePath);
        });
      });
    });

    group('CropModel', () {
      group('Constructor', () {
        test('should create CropModel with all fields', () {
          expect(testCrop.id, 'crop123');
          expect(testCrop.name, 'Rice');
          expect(testCrop.category, 'paddy');
          expect(testCrop.subcategory, 'basmati');
          expect(testCrop.nameTranslations.length, 3);
          expect(testCrop.careInstructions.length, 2);
          expect(testCrop.waterRequirements.length, 2);
          expect(testCrop.growthDuration.length, 2);
          expect(testCrop.commonDiseases['en']?.length, 1);
          expect(testCrop.imagePath, '/images/rice.jpg');
        });

        test('should create CropModel with null optional fields', () {
          final crop = CropModel(
            id: 'crop456',
            name: 'Wheat',
            category: 'wheat',
            nameTranslations: {'en': 'Wheat'},
            careInstructions: {},
            waterRequirements: {},
            growthDuration: {},
            commonDiseases: {},
          );

          expect(crop.subcategory, isNull);
          expect(crop.imagePath, isNull);
        });
      });

      group('toJson', () {
        test('should serialize all fields correctly', () {
          final json = testCrop.toJson();

          expect(json['id'], 'crop123');
          expect(json['name'], 'Rice');
          expect(json['category'], 'paddy');
          expect(json['subcategory'], 'basmati');
          expect(json['nameTranslations']['en'], 'Rice');
          expect(json['nameTranslations']['hi'], 'चावल');
          expect(json['imagePath'], '/images/rice.jpg');
        });

        test('should serialize nested diseases', () {
          final json = testCrop.toJson();
          final diseases = json['commonDiseases']['en'] as List;

          expect(diseases.length, 1);
          expect(diseases[0]['name'], 'Leaf Blight');
        });
      });

      group('fromJson', () {
        test('should deserialize all fields correctly', () {
          final json = {
            'id': 'crop123',
            'name': 'Rice',
            'category': 'paddy',
            'subcategory': 'basmati',
            'nameTranslations': {'en': 'Rice', 'hi': 'चावल'},
            'careInstructions': {'en': 'Keep moist'},
            'waterRequirements': {'en': 'High'},
            'growthDuration': {'en': '120 days'},
            'commonDiseases': {
              'en': [
                {
                  'name': 'Leaf Blight',
                  'description': 'A disease',
                  'symptoms': ['Symptom 1'],
                  'remedies': ['Remedy 1'],
                },
              ],
            },
            'imagePath': '/images/rice.jpg',
          };

          final crop = CropModel.fromJson(json);

          expect(crop.id, 'crop123');
          expect(crop.name, 'Rice');
          expect(crop.category, 'paddy');
          expect(crop.subcategory, 'basmati');
          expect(crop.nameTranslations['en'], 'Rice');
          expect(crop.commonDiseases['en']?.length, 1);
          expect(crop.commonDiseases['en']?[0].name, 'Leaf Blight');
        });

        test('should handle null optional fields', () {
          final json = {
            'id': 'crop456',
            'name': 'Wheat',
            'category': 'wheat',
            'subcategory': null,
            'nameTranslations': {'en': 'Wheat'},
            'careInstructions': {'en': 'Water regularly'},
            'waterRequirements': {'en': 'Medium'},
            'growthDuration': {'en': '90 days'},
            'commonDiseases': {
              'en': [
                {
                  'name': 'Rust',
                  'description': 'Fungal disease',
                  'symptoms': ['Yellow patches'],
                  'remedies': ['Apply fungicide'],
                },
              ],
            },
            'imagePath': null,
          };

          final crop = CropModel.fromJson(json);

          expect(crop.subcategory, isNull);
          expect(crop.imagePath, isNull);
        });
      });

      group('Category validation', () {
        test('should accept valid categories', () {
          final categories = ['paddy', 'wheat', 'vegetables', 'fruits'];

          for (final category in categories) {
            final crop = CropModel(
              id: 'test',
              name: 'Test',
              category: category,
              nameTranslations: {},
              careInstructions: {},
              waterRequirements: {},
              growthDuration: {},
              commonDiseases: {},
            );

            expect(crop.category, category);
          }
        });
      });

      group('Round-trip serialization', () {
        test('should maintain data integrity through toJson/fromJson cycle',
            () {
          final json = testCrop.toJson();
          final reconstructed = CropModel.fromJson(json);

          expect(reconstructed.id, testCrop.id);
          expect(reconstructed.name, testCrop.name);
          expect(reconstructed.category, testCrop.category);
          expect(reconstructed.subcategory, testCrop.subcategory);
          expect(reconstructed.nameTranslations['en'],
              testCrop.nameTranslations['en']);
          expect(reconstructed.nameTranslations['hi'],
              testCrop.nameTranslations['hi']);
          expect(reconstructed.imagePath, testCrop.imagePath);
        });

        test('should maintain nested Disease data through cycle', () {
          final json = testCrop.toJson();
          final reconstructed = CropModel.fromJson(json);
          final originalDisease = testCrop.commonDiseases['en']?[0];
          final reconstructedDisease = reconstructed.commonDiseases['en']?[0];

          expect(reconstructedDisease?.name, originalDisease?.name);
          expect(
              reconstructedDisease?.description, originalDisease?.description);
          expect(reconstructedDisease?.symptoms, originalDisease?.symptoms);
          expect(reconstructedDisease?.remedies, originalDisease?.remedies);
        });
      });
    });
  });
}
