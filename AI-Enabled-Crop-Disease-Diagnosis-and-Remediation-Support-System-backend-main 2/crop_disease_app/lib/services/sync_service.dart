import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:convert'; // Will be needed for real API implementation
import 'package:http/http.dart' as http; // Will be needed for real API implementation
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
    this.baseUrl = 'http://localhost:8000', // Use localhost for Web/Desktop
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
  Future<void> syncPendingSubmissions() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('Sync already in progress, skipping');
      }
      return;
    }

    _isSyncing = true;

    try {
      final pendingSubmissions = await _storageService.getPendingSubmissions();

      if (kDebugMode) {
        print('Syncing ${pendingSubmissions.length} pending submissions');
      }

      for (var submission in pendingSubmissions) {
        await uploadSubmission(submission);
        // Add small delay between uploads to avoid overwhelming server
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during sync: $e');
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

      // Real upload logic
      final response = await _uploadToBackend(submission);

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
          'diagnosisId': response['diagnosis_id'],
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

  // Perform actual upload to backend
  Future<Map<String, dynamic>> _uploadToBackend(Submission submission) async {
    try {
      if (kDebugMode) {
        print('Uploading to $baseUrl/api/upload-media');
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/upload-media'));
      
      // Add the submission ID as media_id for deduplication
      request.fields['media_id'] = submission.id;

      if (kIsWeb) {
        // On Web, we can't use fromPath. Fetch bytes from the blob/asset URL.
        final fileResponse = await http.get(Uri.parse(submission.mediaPath));
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileResponse.bodyBytes,
          filename: 'upload.jpg', // Name doesn't matter much for backend logic
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', submission.mediaPath));
      }
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
         final data = json.decode(responseData);
         return {
          'success': true,
          'diagnosis_id': data['media_id'],
          'message': 'Upload successful',
        };
      } else {
        return {'success': false, 'error': 'Server error: ${response.statusCode} - $responseData'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Fetch history from backend
  Future<List<Submission>> fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/history'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          // Map backend status to frontend status
          SubmissionStatus status = SubmissionStatus.submitted;
          if (item['status'] == 'COMPLETED') status = SubmissionStatus.diagnosed;
          if (item['status'] == 'FAILED') status = SubmissionStatus.failed;
          if (item['status'] == 'PROCESSING') status = SubmissionStatus.uploading;

          // Construct image URL
          String mediaPath = '';
          if (item['file_path'] != null) {
            mediaPath = '$baseUrl/uploads/${item["file_path"]}';
          } else {
            // Fallback if file_path is missing (legacy data)
            mediaPath = '$baseUrl/uploads/${item["media_id"]}.jpg'; 
          }

          return Submission(
            id: item['media_id'],
            mediaPath: mediaPath,
            mediaType: MediaType.image, // Assume image for now
            status: status,
            createdAt: DateTime.tryParse(item['created_at']) ?? DateTime.now(),
            uploadedAt: DateTime.tryParse(item['created_at']),
            diagnosedAt: item['status'] == 'COMPLETED' ? DateTime.now() : null, // Approximate
            diagnosisId: item['media_id'],
          );
        }).toList();
      } else {
        if (kDebugMode) {
          print('Error fetching history: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching history: $e');
      }
      return [];
    }
  }

  // Fetch diagnosis result from backend
  Future<DiagnosisResult?> fetchDiagnosisResult(String submissionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/prediction/$submissionId'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'COMPLETED') {
             final result = DiagnosisResult(
                id: data['media_id'],
                submissionId: submissionId,
                diseaseName: data['disease'] ?? 'Unknown',
                severity: DiseaseSeverity.high,
                confidence: double.tryParse(data['confidence']?.replaceAll('%', '') ?? '0')! / 100.0,
                description: 'Diagnosed as ${data['disease']}',
                diagnosedAt: DateTime.now(),
                isUnknown: data['disease'] == 'Unknown',
            );
            await _storageService.saveDiagnosisResult(result);
            return result;
        }
        return null;
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
  Future<Treatment?> fetchTreatment(String diseaseId) async {
    try {
      // Mock response for development
      await Future.delayed(const Duration(seconds: 1));

      // Return mock treatment data
      return Treatment(
        diseaseId: diseaseId,
        diseaseName: 'Late Blight',
        organicSteps: [
          TreatmentStep(
            stepNumber: 1,
            title: 'Remove Infected Leaves',
            description:
                'Carefully remove and destroy all infected plant parts to prevent spread',
            type: TreatmentType.organic,
            safetyLevel: SafetyLevel.safe,
            timing: 'Immediately',
            ppeRequired: ['Gloves'],
          ),
          TreatmentStep(
            stepNumber: 2,
            title: 'Apply Copper-Based Fungicide',
            description:
                'Spray copper-based organic fungicide on affected plants',
            type: TreatmentType.organic,
            safetyLevel: SafetyLevel.caution,
            dosage: '50ml per liter of water',
            timing: 'Every 7-10 days',
            ppeRequired: ['Gloves', 'Mask'],
            weatherDependent: true,
          ),
        ],
        chemicalSteps: [
          TreatmentStep(
            stepNumber: 1,
            title: 'Apply Mancozeb Fungicide',
            description: 'Use Mancozeb fungicide as directed',
            type: TreatmentType.chemical,
            safetyLevel: SafetyLevel.warning,
            dosage: '2g per liter of water',
            timing: 'Every 5-7 days',
            safetyWarnings: ['Toxic if ingested', 'Avoid contact with skin'],
            ppeRequired: ['Gloves', 'Mask', 'Protective clothing'],
            weatherDependent: true,
          ),
        ],
        generalAdvice:
            'Ensure good air circulation and avoid overhead watering',
        rainWarning: true,
        weatherCondition: 'Rain expected in 24 hours',
      );

      /* Real implementation:
      final response = await http.get(
        Uri.parse('$baseUrl/api/treatments/$diseaseId'),
      );
      
      if (response.statusCode == 200) {
        return Treatment.fromJson(json.decode(response.body));
      }
      return null;
      */
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching treatment: $e');
      }
      return null;
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _uploadProgressController.close();
  }
}
