import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/models/submission.dart';

void main() {
  group('Submission', () {
    late Submission testSubmission;
    late DateTime testCreatedAt;

    setUp(() {
      testCreatedAt = DateTime(2024, 2, 1, 10, 30);
      testSubmission = Submission(
        id: 'sub123',
        mediaPath: '/path/to/image.jpg',
        mediaType: MediaType.image,
        status: SubmissionStatus.saved,
        createdAt: testCreatedAt,
      );
    });

    group('MediaType enum', () {
      test('should have image and video types', () {
        expect(MediaType.values.length, 2);
        expect(MediaType.values.contains(MediaType.image), isTrue);
        expect(MediaType.values.contains(MediaType.video), isTrue);
      });
    });

    group('SubmissionStatus enum', () {
      test('should have all status types', () {
        expect(SubmissionStatus.values.length, 5);
        expect(SubmissionStatus.saved.name, 'saved');
        expect(SubmissionStatus.uploading.name, 'uploading');
        expect(SubmissionStatus.submitted.name, 'submitted');
        expect(SubmissionStatus.failed.name, 'failed');
        expect(SubmissionStatus.diagnosed.name, 'diagnosed');
      });
    });

    group('Constructor', () {
      test('should create Submission with all fields', () {
        expect(testSubmission.id, 'sub123');
        expect(testSubmission.mediaPath, '/path/to/image.jpg');
        expect(testSubmission.mediaType, MediaType.image);
        expect(testSubmission.status, SubmissionStatus.saved);
        expect(testSubmission.createdAt, testCreatedAt);
        expect(testSubmission.uploadedAt, isNull);
        expect(testSubmission.diagnosedAt, isNull);
        expect(testSubmission.diagnosisId, isNull);
      });

      test('should default status to saved', () {
        final submission = Submission(
          id: 'sub456',
          mediaPath: '/path/to/video.mp4',
          mediaType: MediaType.video,
          createdAt: testCreatedAt,
        );

        expect(submission.status, SubmissionStatus.saved);
      });

      test('should create Submission with optional fields', () {
        final uploadedAt = DateTime(2024, 2, 1, 11, 0);
        final diagnosedAt = DateTime(2024, 2, 1, 11, 30);

        final submission = Submission(
          id: 'sub789',
          mediaPath: '/path/to/image.jpg',
          mediaType: MediaType.image,
          status: SubmissionStatus.diagnosed,
          createdAt: testCreatedAt,
          uploadedAt: uploadedAt,
          diagnosedAt: diagnosedAt,
          diagnosisId: 'diag123',
        );

        expect(submission.uploadedAt, uploadedAt);
        expect(submission.diagnosedAt, diagnosedAt);
        expect(submission.diagnosisId, 'diag123');
      });
    });

    group('toMap', () {
      test('should serialize all fields correctly', () {
        final map = testSubmission.toMap();

        expect(map['id'], 'sub123');
        expect(map['mediaPath'], '/path/to/image.jpg');
        expect(map['mediaType'], 'image');
        expect(map['status'], 'saved');
        expect(map['createdAt'], testCreatedAt.toIso8601String());
        expect(map['uploadedAt'], isNull);
        expect(map['diagnosedAt'], isNull);
        expect(map['diagnosisId'], isNull);
      });

      test('should serialize DateTime fields as ISO8601 strings', () {
        final uploadedAt = DateTime(2024, 2, 1, 11, 0);
        final submission = testSubmission.copyWith(
          uploadedAt: uploadedAt,
        );

        final map = submission.toMap();

        expect(map['uploadedAt'], uploadedAt.toIso8601String());
      });
    });

    group('fromMap', () {
      test('should deserialize all fields correctly', () {
        final map = {
          'id': 'sub123',
          'mediaPath': '/path/to/image.jpg',
          'mediaType': 'image',
          'status': 'saved',
          'createdAt': '2024-02-01T10:30:00.000',
          'uploadedAt': null,
          'diagnosedAt': null,
          'diagnosisId': null,
        };

        final submission = Submission.fromMap(map);

        expect(submission.id, 'sub123');
        expect(submission.mediaPath, '/path/to/image.jpg');
        expect(submission.mediaType, MediaType.image);
        expect(submission.status, SubmissionStatus.saved);
      });

      test('should deserialize video media type', () {
        final map = {
          'id': 'sub456',
          'mediaPath': '/path/to/video.mp4',
          'mediaType': 'video',
          'status': 'uploading',
          'createdAt': '2024-02-01T10:30:00.000',
        };

        final submission = Submission.fromMap(map);

        expect(submission.mediaType, MediaType.video);
        expect(submission.status, SubmissionStatus.uploading);
      });

      test('should deserialize all status types', () {
        final statuses = [
          'saved',
          'uploading',
          'submitted',
          'failed',
          'diagnosed'
        ];
        final expectedStatuses = [
          SubmissionStatus.saved,
          SubmissionStatus.uploading,
          SubmissionStatus.submitted,
          SubmissionStatus.failed,
          SubmissionStatus.diagnosed,
        ];

        for (var i = 0; i < statuses.length; i++) {
          final map = {
            'id': 'sub$i',
            'mediaPath': '/path/to/file',
            'mediaType': 'image',
            'status': statuses[i],
            'createdAt': '2024-02-01T10:30:00.000',
          };

          final submission = Submission.fromMap(map);
          expect(submission.status, expectedStatuses[i]);
        }
      });
    });

    group('copyWith', () {
      test('should create copy with updated status', () {
        final updated = testSubmission.copyWith(
          status: SubmissionStatus.uploading,
        );

        expect(updated.id, testSubmission.id);
        expect(updated.mediaPath, testSubmission.mediaPath);
        expect(updated.status, SubmissionStatus.uploading);
      });

      test('should create copy with all updated fields', () {
        final newUploadedAt = DateTime(2024, 2, 1, 11, 0);
        final newDiagnosedAt = DateTime(2024, 2, 1, 11, 30);

        final updated = testSubmission.copyWith(
          status: SubmissionStatus.diagnosed,
          uploadedAt: newUploadedAt,
          diagnosedAt: newDiagnosedAt,
          diagnosisId: 'diag456',
        );

        expect(updated.status, SubmissionStatus.diagnosed);
        expect(updated.uploadedAt, newUploadedAt);
        expect(updated.diagnosedAt, newDiagnosedAt);
        expect(updated.diagnosisId, 'diag456');
      });

      test('should preserve original when no fields specified', () {
        final copy = testSubmission.copyWith();

        expect(copy.id, testSubmission.id);
        expect(copy.mediaPath, testSubmission.mediaPath);
        expect(copy.mediaType, testSubmission.mediaType);
        expect(copy.status, testSubmission.status);
        expect(copy.createdAt, testSubmission.createdAt);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through toMap/fromMap cycle', () {
        final map = testSubmission.toMap();
        final reconstructed = Submission.fromMap(map);

        expect(reconstructed.id, testSubmission.id);
        expect(reconstructed.mediaPath, testSubmission.mediaPath);
        expect(reconstructed.mediaType, testSubmission.mediaType);
        expect(reconstructed.status, testSubmission.status);
      });
    });
  });
}
