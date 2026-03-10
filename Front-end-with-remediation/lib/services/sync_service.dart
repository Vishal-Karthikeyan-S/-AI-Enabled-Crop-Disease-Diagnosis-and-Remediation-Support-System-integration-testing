import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/submission.dart';
import '../models/diagnosis_result.dart';
import '../models/treatment_step.dart';
import 'storage_service.dart';

class SyncService {
  final StorageService _storageService;
  final String baseUrl;

  final _uploadProgressController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get uploadProgressStream =>
      _uploadProgressController.stream;

  bool _isSyncing = false;
  Timer? _syncTimer;

  SyncService({
    required StorageService storageService,
    this.baseUrl = 'http://127.0.0.1:8000',
  }) : _storageService = storageService;

  // Start automatic sync service
  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (timer) {
      syncPendingSubmissions();
    });
  }

  // Stop automatic sync
  void stopAutoSync() {
    _syncTimer?.cancel();
  }

  // Sync all pending submissions
  Future<void> syncPendingSubmissions({bool manualTrigger = false}) async {
    if (_isSyncing) {
      if (kDebugMode) print('Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;
    if (kDebugMode && manualTrigger) print('Manual sync triggered');

    try {
      final pendingSubmissions = await _storageService.getPendingSubmissions();

      if (kDebugMode) {
        print('Found ${pendingSubmissions.length} pending submissions to sync');
      }

      for (var submission in pendingSubmissions) {
        // Double check status before starting
        if (submission.status == SubmissionStatus.submitted) continue;
        
        final success = await uploadSubmission(submission);
        if (!success) {
           if (kDebugMode) print('Failed to sync submission ${submission.id}, continuing to next.');
        }
        
        // Professional anti-throttle delay
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Critical error during sync: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Upload a single submission
  Future<bool> uploadSubmission(Submission submission) async {
    try {
      // Update status to uploading
      submission = submission.copyWith(status: SubmissionStatus.uploading);
      await _storageService.updateSubmission(submission);
      _uploadProgressController.add({
        'id': submission.id,
        'status': SubmissionStatus.uploading,
        'progress': 0.0,
      });

      // Simulate file upload (replace with actual upload logic)
      // In a real implementation, you would:
      // 1. Read the file from submission.mediaPath
      // 2. Create a multipart request
      // 3. Upload to backend API
      // 4. Get response with diagnosis_id

      final response = await _mockUpload(submission);

      if (response['success']) {
        submission = submission.copyWith(
          status: SubmissionStatus.submitted,
          uploadedAt: DateTime.now(),
          diagnosisId: response['diagnosis_id'],
        );
        await _storageService.updateSubmission(submission);

        _uploadProgressController.add({
          'id': submission.id,
          'status': SubmissionStatus.submitted,
          'progress': 1.0,
        });

        if (kDebugMode) {
          print('Upload successful: ${submission.id}');
        }

        return true;
      } else {
        throw Exception(response['error'] ?? 'Upload failed');
      }
    } catch (e) {
      // Mark as failed
      submission = submission.copyWith(status: SubmissionStatus.failed);
      await _storageService.updateSubmission(submission);

      _uploadProgressController.add({
        'id': submission.id,
        'status': SubmissionStatus.failed,
        'progress': 0.0,
      });

      if (kDebugMode) {
        print('Upload failed: ${submission.id}, error: $e');
      }

      return false;
    }
  }

  // Actual upload implementation with retry logic
  Future<Map<String, dynamic>> _uploadToBackend(Submission submission) async {
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      try {
        attempts++;
        if (kDebugMode) {
          print('Upload attempt $attempts for ${submission.id}');
        }

        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload-media'));
        
        final bool isWebEnv = kIsWeb || identical(0, 0.0);
        
        if (kDebugMode) {
          print('Uploading submission ${submission.id} (Web: $isWebEnv) from path: ${submission.mediaPath}');
        }

        if (isWebEnv) {
          try {
            // On Web, we MUST use readBytes or similar to get the data from the Blob URL
            final bytes = await http.readBytes(Uri.parse(submission.mediaPath));
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: 'upload-${submission.id}.jpg',
            ));
          } catch (e) {
            if (kDebugMode) print('Web Upload Error: $e');
            throw Exception('Image data expired or lost. On the Web, images must be uploaded before the page is refreshed. Please retake the photo.');
          }
        } else {
          // Mobile/Desktop only
          request.files.add(await http.MultipartFile.fromPath('file', submission.mediaPath));
        }
        
        var response = await request.send().timeout(const Duration(seconds: 30));
        var responseData = await response.stream.bytesToString();
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(responseData);
          return {
            'success': true,
            'diagnosis_id': data['media_id'],
            'message': data['message']
          };
        } else {
          if (kDebugMode) {
            print('Server returned ${response.statusCode}: $responseData');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Upload error (Attempt $attempts): $e');
        }
        if (attempts >= maxAttempts) {
          return {'success': false, 'error': e.toString()};
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    return {'success': false, 'error': 'Max attempts reached'};
  }

  // Replace mock upload with real one
  Future<Map<String, dynamic>> _mockUpload(Submission submission) => _uploadToBackend(submission);

  // Fetch diagnosis result from backend
  Future<DiagnosisResult?> fetchDiagnosisResult(String mediaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/prediction/$mediaId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        
        // If status is still processing or uploaded, return null to keep polling
        if (status == 'UPLOADED' || status == 'PROCESSING') {
           return null;
        }

        // If status is FAILED, return a result that indicates error
        if (status == 'FAILED') {
          return DiagnosisResult.fromJson({
            'id': data['media_id'],
            'submission_id': data['media_id'],
            'disease_name': 'Error during analysis',
            'severity': 'unknown',
            'confidence': 0.0,
            'description': 'The AI model encountered an error while analyzing this photo.',
            'diagnosed_at': DateTime.now().toIso8601String(),
          });
        }

        // Must be COMPLETED
        final result = DiagnosisResult.fromJson({
          'id': data['media_id'],
          'submission_id': data['media_id'],
          'disease_name': data['result'] ?? 'Unknown',
          'severity': data['severity']?.toLowerCase() ?? 'unknown',
          'confidence': data['confidence'] ?? 0.0,
          'description': 'Analysis complete.',
          'diagnosed_at': DateTime.now().toIso8601String(),
        });
        
        await _storageService.saveDiagnosisResult(result);
        return result;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching diagnosis: $e');
      }
      return null;
    }
  }

  // Fetch treatment steps from backend
  Future<Treatment?> fetchTreatment(String diseaseIdOrName, {DiseaseSeverity? severity}) async {
    final baseUrl = await _apiBaseUrl;
    try {
      // If passing name, map to ID first (or the backend handles both)
      // Our backend handles both names and indices.
      String url = '$baseUrl/api/remediation/$diseaseIdOrName';
      
      final queryParams = <String, String>{};
      if (severity != null) {
        queryParams['severity'] = severity.name;
      }
      
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return Treatment.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching treatment: $e');
      }
      return null;
    }
  }

  // Get current API base URL
  Future<String> get _apiBaseUrl async => baseUrl;

  void dispose() {
    _syncTimer?.cancel();
    _uploadProgressController.close();
  }
}
