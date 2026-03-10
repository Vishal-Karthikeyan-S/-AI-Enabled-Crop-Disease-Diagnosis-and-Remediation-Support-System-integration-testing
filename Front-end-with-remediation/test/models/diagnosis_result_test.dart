import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/models/diagnosis_result.dart';

void main() {
  group('DiagnosisResult', () {
    late DiagnosisResult testResult;
    late DateTime testDiagnosedAt;

    setUp(() {
      testDiagnosedAt = DateTime(2024, 2, 1, 14, 30);
      testResult = DiagnosisResult(
        id: 'diag123',
        submissionId: 'sub456',
        diseaseName: 'Leaf Blight',
        severity: DiseaseSeverity.medium,
        confidence: 0.85,
        diseaseIcon: '/icons/leaf_blight.png',
        description: 'A fungal disease affecting leaves',
        diagnosedAt: testDiagnosedAt,
        isUnknown: false,
      );
    });

    group('DiseaseSeverity enum', () {
      test('should have all severity levels', () {
        expect(DiseaseSeverity.values.length, 4);
        expect(DiseaseSeverity.low.name, 'low');
        expect(DiseaseSeverity.medium.name, 'medium');
        expect(DiseaseSeverity.high.name, 'high');
        expect(DiseaseSeverity.unknown.name, 'unknown');
      });
    });

    group('Constructor', () {
      test('should create DiagnosisResult with all fields', () {
        expect(testResult.id, 'diag123');
        expect(testResult.submissionId, 'sub456');
        expect(testResult.diseaseName, 'Leaf Blight');
        expect(testResult.severity, DiseaseSeverity.medium);
        expect(testResult.confidence, 0.85);
        expect(testResult.diseaseIcon, '/icons/leaf_blight.png');
        expect(testResult.description, 'A fungal disease affecting leaves');
        expect(testResult.diagnosedAt, testDiagnosedAt);
        expect(testResult.isUnknown, false);
      });

      test('should default isUnknown to false', () {
        final result = DiagnosisResult(
          id: 'diag789',
          submissionId: 'sub789',
          diseaseName: 'Test Disease',
          severity: DiseaseSeverity.low,
          confidence: 0.9,
          diagnosedAt: testDiagnosedAt,
        );

        expect(result.isUnknown, false);
      });
    });

    group('severityColor', () {
      test('should return green for low severity', () {
        final result = DiagnosisResult(
          id: 'test',
          submissionId: 'test',
          diseaseName: 'Test',
          severity: DiseaseSeverity.low,
          confidence: 0.9,
          diagnosedAt: testDiagnosedAt,
        );

        expect(result.severityColor, 'green');
      });

      test('should return yellow for medium severity', () {
        expect(testResult.severityColor, 'yellow');
      });

      test('should return red for high severity', () {
        final result = DiagnosisResult(
          id: 'test',
          submissionId: 'test',
          diseaseName: 'Test',
          severity: DiseaseSeverity.high,
          confidence: 0.9,
          diagnosedAt: testDiagnosedAt,
        );

        expect(result.severityColor, 'red');
      });

      test('should return grey for unknown severity', () {
        final result = DiagnosisResult(
          id: 'test',
          submissionId: 'test',
          diseaseName: 'Test',
          severity: DiseaseSeverity.unknown,
          confidence: 0.5,
          diagnosedAt: testDiagnosedAt,
        );

        expect(result.severityColor, 'grey');
      });
    });

    group('severityEmoji', () {
      test('should return correct emoji for each severity level', () {
        final severityEmojis = {
          DiseaseSeverity.low: '🟢',
          DiseaseSeverity.medium: '🟡',
          DiseaseSeverity.high: '🔴',
          DiseaseSeverity.unknown: '⚪',
        };

        for (final entry in severityEmojis.entries) {
          final result = DiagnosisResult(
            id: 'test',
            submissionId: 'test',
            diseaseName: 'Test',
            severity: entry.key,
            confidence: 0.9,
            diagnosedAt: testDiagnosedAt,
          );

          expect(result.severityEmoji, entry.value,
              reason: 'Expected ${entry.value} for ${entry.key}');
        }
      });
    });

    group('toMap', () {
      test('should serialize all fields correctly', () {
        final map = testResult.toMap();

        expect(map['id'], 'diag123');
        expect(map['submissionId'], 'sub456');
        expect(map['diseaseName'], 'Leaf Blight');
        expect(map['severity'], 'medium');
        expect(map['confidence'], 0.85);
        expect(map['diseaseIcon'], '/icons/leaf_blight.png');
        expect(map['description'], 'A fungal disease affecting leaves');
        expect(map['diagnosedAt'], testDiagnosedAt.toIso8601String());
        expect(map['isUnknown'], 0);
      });

      test('should serialize isUnknown as 1 when true', () {
        final result = DiagnosisResult(
          id: 'test',
          submissionId: 'test',
          diseaseName: 'Unknown',
          severity: DiseaseSeverity.unknown,
          confidence: 0.4,
          diagnosedAt: testDiagnosedAt,
          isUnknown: true,
        );

        final map = result.toMap();
        expect(map['isUnknown'], 1);
      });
    });

    group('fromMap', () {
      test('should deserialize all fields correctly', () {
        final map = {
          'id': 'diag123',
          'submissionId': 'sub456',
          'diseaseName': 'Leaf Blight',
          'severity': 'medium',
          'confidence': 0.85,
          'diseaseIcon': '/icons/leaf_blight.png',
          'description': 'A fungal disease affecting leaves',
          'diagnosedAt': '2024-02-01T14:30:00.000',
          'isUnknown': 0,
        };

        final result = DiagnosisResult.fromMap(map);

        expect(result.id, 'diag123');
        expect(result.submissionId, 'sub456');
        expect(result.diseaseName, 'Leaf Blight');
        expect(result.severity, DiseaseSeverity.medium);
        expect(result.confidence, 0.85);
        expect(result.isUnknown, false);
      });

      test('should deserialize isUnknown as true when value is 1', () {
        final map = {
          'id': 'test',
          'submissionId': 'test',
          'diseaseName': 'Unknown',
          'severity': 'unknown',
          'confidence': 0.4,
          'diagnosedAt': '2024-02-01T14:30:00.000',
          'isUnknown': 1,
        };

        final result = DiagnosisResult.fromMap(map);
        expect(result.isUnknown, true);
      });
    });

    group('fromJson', () {
      test('should deserialize API response with snake_case keys', () {
        final json = {
          'id': 'diag123',
          'submission_id': 'sub456',
          'disease_name': 'Leaf Blight',
          'severity': 'medium',
          'confidence': 0.85,
          'disease_icon': '/icons/leaf_blight.png',
          'description': 'A fungal disease',
          'diagnosed_at': '2024-02-01T14:30:00.000',
        };

        final result = DiagnosisResult.fromJson(json);

        expect(result.id, 'diag123');
        expect(result.submissionId, 'sub456');
        expect(result.diseaseName, 'Leaf Blight');
        expect(result.severity, DiseaseSeverity.medium);
        expect(result.confidence, 0.85);
        expect(result.isUnknown, false);
      });

      test('should set isUnknown to true when confidence is below 0.7', () {
        final json = {
          'id': 'diag123',
          'submission_id': 'sub456',
          'disease_name': 'Unknown',
          'severity': 'unknown',
          'confidence': 0.5,
        };

        final result = DiagnosisResult.fromJson(json);

        expect(result.isUnknown, true);
      });

      test('should handle missing fields with defaults', () {
        final json = <String, dynamic>{};

        final result = DiagnosisResult.fromJson(json);

        expect(result.id, '');
        expect(result.submissionId, '');
        expect(result.diseaseName, 'Unknown');
        expect(result.confidence, 0.0);
        expect(result.isUnknown, true);
      });

      test('should handle null severity', () {
        final json = {
          'id': 'diag123',
          'severity': null,
          'confidence': 0.9,
        };

        final result = DiagnosisResult.fromJson(json);

        expect(result.severity, DiseaseSeverity.unknown);
      });

      test('should parse severity case-insensitively', () {
        final json = {
          'id': 'diag123',
          'severity': 'HIGH',
          'confidence': 0.9,
        };

        final result = DiagnosisResult.fromJson(json);

        expect(result.severity, DiseaseSeverity.high);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toMap/fromMap cycle', () {
        final map = testResult.toMap();
        final reconstructed = DiagnosisResult.fromMap(map);

        expect(reconstructed.id, testResult.id);
        expect(reconstructed.submissionId, testResult.submissionId);
        expect(reconstructed.diseaseName, testResult.diseaseName);
        expect(reconstructed.severity, testResult.severity);
        expect(reconstructed.confidence, testResult.confidence);
        expect(reconstructed.isUnknown, testResult.isUnknown);
      });
    });
  });
}
