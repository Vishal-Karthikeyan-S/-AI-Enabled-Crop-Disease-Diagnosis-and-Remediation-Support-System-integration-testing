import 'package:flutter_test/flutter_test.dart';
import 'package:crop_disease_app/models/submission.dart';

// Note: This file tests the Submission model behavior used by SubmissionProvider.
// Full SubmissionProvider integration tests require a database setup which is
// covered by widget tests or integration tests.

void main() {
  group('Submission Model for Provider', () {
    group('Status transitions', () {
      test('should start with saved status by default', () {
        final submission = Submission(
          id: 'test_id',
          mediaPath: '/path/to/image.jpg',
          mediaType: MediaType.image,
          createdAt: DateTime.now(),
        );

        expect(submission.status, SubmissionStatus.saved);
      });

      test('should transition from saved to uploading', () {
        final submission = Submission(
          id: 'test_id',
          mediaPath: '/path/to/image.jpg',
          mediaType: MediaType.image,
          status: SubmissionStatus.saved,
          createdAt: DateTime.now(),
        );

        final uploading = submission.copyWith(
          status: SubmissionStatus.uploading,
        );

        expect(uploading.status, SubmissionStatus.uploading);
        expect(submission.status, SubmissionStatus.saved); // Original unchanged
      });

      test('should transition from uploading to submitted', () {
        final submission = Submission(
          id: 'test_id',
          mediaPath: '/path/to/image.jpg',
          mediaType: MediaType.image,
          status: SubmissionStatus.uploading,
          createdAt: DateTime.now(),
        );

        final submitted = submission.copyWith(
          status: SubmissionStatus.submitted,
          uploadedAt: DateTime.now(),
        );

        expect(submitted.status, SubmissionStatus.submitted);
        expect(submitted.uploadedAt, isNotNull);
      });

      test('should transition from uploading to failed', () {
        final submission = Submission(
          id: 'test_id',
          mediaPath: '/path/to/image.jpg',
          mediaType: MediaType.image,
          status: SubmissionStatus.uploading,
          createdAt: DateTime.now(),
        );

        final failed = submission.copyWith(
          status: SubmissionStatus.failed,
        );

        expect(failed.status, SubmissionStatus.failed);
      });

      test('should transition from submitted to diagnosed', () {
        final submission = Submission(
          id: 'test_id',
          mediaPath: '/path/to/image.jpg',
          mediaType: MediaType.image,
          status: SubmissionStatus.submitted,
          createdAt: DateTime.now(),
          uploadedAt: DateTime.now(),
        );

        final diagnosed = submission.copyWith(
          status: SubmissionStatus.diagnosed,
          diagnosedAt: DateTime.now(),
          diagnosisId: 'diag_123',
        );

        expect(diagnosed.status, SubmissionStatus.diagnosed);
        expect(diagnosed.diagnosedAt, isNotNull);
        expect(diagnosed.diagnosisId, 'diag_123');
      });
    });

    group('List operations for provider logic', () {
      test('should filter submissions by status (pending)', () {
        final submissions = [
          Submission(
            id: 'sub1',
            mediaPath: '/path1',
            mediaType: MediaType.image,
            status: SubmissionStatus.saved,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub2',
            mediaPath: '/path2',
            mediaType: MediaType.image,
            status: SubmissionStatus.submitted,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub3',
            mediaPath: '/path3',
            mediaType: MediaType.image,
            status: SubmissionStatus.saved,
            createdAt: DateTime.now(),
          ),
        ];

        final pending = submissions
            .where((s) => s.status == SubmissionStatus.saved)
            .toList();

        expect(pending.length, 2);
        expect(pending.every((s) => s.status == SubmissionStatus.saved), true);
      });

      test('should filter submissions by status (uploading)', () {
        final submissions = [
          Submission(
            id: 'sub1',
            mediaPath: '/path1',
            mediaType: MediaType.image,
            status: SubmissionStatus.uploading,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub2',
            mediaPath: '/path2',
            mediaType: MediaType.image,
            status: SubmissionStatus.submitted,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub3',
            mediaPath: '/path3',
            mediaType: MediaType.image,
            status: SubmissionStatus.uploading,
            createdAt: DateTime.now(),
          ),
        ];

        final uploading = submissions
            .where((s) => s.status == SubmissionStatus.uploading)
            .toList();

        expect(uploading.length, 2);
      });

      test('should find submission by ID', () {
        final submissions = [
          Submission(
            id: 'sub1',
            mediaPath: '/path1',
            mediaType: MediaType.image,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub2',
            mediaPath: '/path2',
            mediaType: MediaType.video,
            createdAt: DateTime.now(),
          ),
        ];

        final found = submissions.where((s) => s.id == 'sub2').firstOrNull;

        expect(found, isNotNull);
        expect(found!.id, 'sub2');
        expect(found.mediaType, MediaType.video);
      });

      test('should return null when ID not found', () {
        final submissions = [
          Submission(
            id: 'sub1',
            mediaPath: '/path1',
            mediaType: MediaType.image,
            createdAt: DateTime.now(),
          ),
        ];

        final found =
            submissions.where((s) => s.id == 'non_existent').firstOrNull;

        expect(found, isNull);
      });

      test('should update submission in list', () {
        final submissions = [
          Submission(
            id: 'sub1',
            mediaPath: '/path1',
            mediaType: MediaType.image,
            status: SubmissionStatus.saved,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub2',
            mediaPath: '/path2',
            mediaType: MediaType.image,
            status: SubmissionStatus.saved,
            createdAt: DateTime.now(),
          ),
        ];

        // Simulate update logic
        final updatedSubmission = submissions[0].copyWith(
          status: SubmissionStatus.submitted,
        );
        final index = submissions.indexWhere((s) => s.id == 'sub1');
        submissions[index] = updatedSubmission;

        expect(submissions[0].status, SubmissionStatus.submitted);
        expect(submissions[1].status, SubmissionStatus.saved);
      });

      test('should remove submission from list', () {
        final submissions = [
          Submission(
            id: 'sub1',
            mediaPath: '/path1',
            mediaType: MediaType.image,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub2',
            mediaPath: '/path2',
            mediaType: MediaType.image,
            createdAt: DateTime.now(),
          ),
        ];

        submissions.removeWhere((s) => s.id == 'sub1');

        expect(submissions.length, 1);
        expect(submissions[0].id, 'sub2');
      });

      test('should add submission at beginning of list', () {
        final submissions = <Submission>[];

        final sub1 = Submission(
          id: 'sub1',
          mediaPath: '/path1',
          mediaType: MediaType.image,
          createdAt: DateTime.now(),
        );
        submissions.insert(0, sub1);

        final sub2 = Submission(
          id: 'sub2',
          mediaPath: '/path2',
          mediaType: MediaType.image,
          createdAt: DateTime.now(),
        );
        submissions.insert(0, sub2);

        expect(submissions[0].id, 'sub2');
        expect(submissions[1].id, 'sub1');
      });
    });

    group('Failed submission handling', () {
      test('should identify failed submissions for retry', () {
        final submissions = [
          Submission(
            id: 'sub1',
            mediaPath: '/path1',
            mediaType: MediaType.image,
            status: SubmissionStatus.failed,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub2',
            mediaPath: '/path2',
            mediaType: MediaType.image,
            status: SubmissionStatus.submitted,
            createdAt: DateTime.now(),
          ),
          Submission(
            id: 'sub3',
            mediaPath: '/path3',
            mediaType: MediaType.image,
            status: SubmissionStatus.failed,
            createdAt: DateTime.now(),
          ),
        ];

        final failed = submissions
            .where((s) => s.status == SubmissionStatus.failed)
            .toList();

        expect(failed.length, 2);
        expect(failed[0].id, 'sub1');
        expect(failed[1].id, 'sub3');
      });
    });
  });
}
