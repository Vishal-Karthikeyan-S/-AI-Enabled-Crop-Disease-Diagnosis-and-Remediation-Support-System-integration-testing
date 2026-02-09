import 'package:flutter/foundation.dart';
import '../models/submission.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';

class SubmissionProvider with ChangeNotifier {
  final StorageService _storageService;
  final SyncService _syncService;

  List<Submission> _submissions = [];
  bool _isLoading = false;
  String? _error;

  List<Submission> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingCount =>
      _submissions.where((s) => s.status == SubmissionStatus.saved).length;
  int get uploadingCount =>
      _submissions.where((s) => s.status == SubmissionStatus.uploading).length;

  SubmissionProvider({
    required StorageService storageService,
    required SyncService syncService,
  })  : _storageService = storageService,
        _syncService = syncService {
    _init();
  }

  Future<void> _init() async {
    await loadSubmissions();

    // Listen to sync service updates
    _syncService.uploadProgressStream.listen((event) {
      _updateSubmissionStatus(
        event['id'],
        event['status'],
        event['progress'],
        diagnosisId: event['diagnosisId'],
      );
    });
  }

  Future<void> loadSubmissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Capture pending local items (that might not be in backend yet)
      // On Web, StorageService doesn't persist, so we rely on current memory state for pending items.
      final pendingItems = _submissions.where((s) {
        return s.status == SubmissionStatus.saved || 
               s.status == SubmissionStatus.uploading || 
               s.status == SubmissionStatus.failed;
      }).toList();

      // Fetch from backend
      final backendHistory = await _syncService.fetchHistory();
      
      // Merge: Keep local pending items if they aren't already in backend history
      final backendIds = backendHistory.map((s) => s.id).toSet();
      final uniquePending = pendingItems.where((s) => !backendIds.contains(s.id)).toList();
      
      _submissions = [...uniquePending, ...backendHistory];
      
      // Sort ensures newest first
      _submissions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error loading submissions: $e');
      }
    }
  }

  Future<void> addSubmission(Submission submission) async {
    try {
      await _storageService.saveSubmission(submission);
      _submissions.insert(0, submission); // Add to beginning
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('Error adding submission: $e');
      }
    }
  }

  Future<void> updateSubmission(Submission submission) async {
    try {
      await _storageService.updateSubmission(submission);
      final index = _submissions.indexWhere((s) => s.id == submission.id);
      if (index != -1) {
        _submissions[index] = submission;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('Error updating submission: $e');
      }
    }
  }

  Future<void> deleteSubmission(String id) async {
    try {
      await _storageService.deleteSubmission(id);
      _submissions.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      if (kDebugMode) {
        print('Error deleting submission: $e');
      }
    }
  }

  void _updateSubmissionStatus(
      String id, SubmissionStatus status, double progress,
      {String? diagnosisId}) {
    final index = _submissions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _submissions[index] = _submissions[index].copyWith(
        status: status,
        diagnosisId: diagnosisId ?? _submissions[index].diagnosisId,
      );
      notifyListeners();
    }
  }

  Future<void> syncPendingItems() async {
    final pendingSubmissions = _submissions.where((s) => 
      s.status == SubmissionStatus.saved || s.status == SubmissionStatus.failed
    ).toList();

    if (kDebugMode) {
      print('Syncing ${pendingSubmissions.length} pending items from memory');
    }

    for (var submission in pendingSubmissions) {
      await _syncService.uploadSubmission(submission);
      // Small delay to prevent overwhelming the server/network
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> retryFailedUploads() async {
    await syncPendingItems();
  }

  Future<void> uploadSubmission(Submission submission) async {
    await _syncService.uploadSubmission(submission);
  }

  Submission? getSubmissionById(String id) {
    try {
      return _submissions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
