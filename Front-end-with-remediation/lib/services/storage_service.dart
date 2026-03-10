import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/submission.dart';
import '../models/diagnosis_result.dart';

class StorageService {
  final SharedPreferences _prefs;
  
  static const String _submissionsKey = 'submissions_data';
  static const String _resultsKey = 'diagnosis_results_data';

  // In-memory cache for performance
  final Map<String, Submission> _submissions = {};
  final Map<String, DiagnosisResult> _diagnosisResults = {};

  StorageService(this._prefs) {
    _loadFromDisk();
  }

  void _loadFromDisk() {
    try {
      // Load Submissions
      final subStr = _prefs.getString(_submissionsKey);
      if (subStr != null) {
        final Map<String, dynamic> decoded = json.decode(subStr);
        decoded.forEach((key, value) {
          _submissions[key] = Submission.fromMap(value);
        });
      }

      // Load Diagnosis Results
      final resStr = _prefs.getString(_resultsKey);
      if (resStr != null) {
        final Map<String, dynamic> decoded = json.decode(resStr);
        decoded.forEach((key, value) {
          _diagnosisResults[key] = DiagnosisResult.fromMap(value);
        });
      }
      
      if (kDebugMode) {
        print('StorageService initialized: ${_submissions.length} submissions loaded.');
      }
    } catch (e) {
      if (kDebugMode) print('Error loading data from disk: $e');
    }
  }

  Future<void> _saveToDisk() async {
    try {
      // Save Submissions
      final subMap = _submissions.map((key, value) => MapEntry(key, value.toMap()));
      await _prefs.setString(_submissionsKey, json.encode(subMap));

      // Save Results
      final resMap = _diagnosisResults.map((key, value) => MapEntry(key, value.toMap()));
      await _prefs.setString(_resultsKey, json.encode(resMap));
    } catch (e) {
      if (kDebugMode) print('Error saving data to disk: $e');
    }
  }

  // Submission CRUD operations
  Future<void> saveSubmission(Submission submission) async {
    _submissions[submission.id] = submission;
    await _saveToDisk();
    if (kDebugMode) print('Submission saved: ${submission.id}');
  }

  Future<void> updateSubmission(Submission submission) async {
    _submissions[submission.id] = submission;
    await _saveToDisk();
    if (kDebugMode) print('Submission updated: ${submission.id}');
  }

  Future<void> deleteSubmission(String id) async {
    _submissions.remove(id);
    await _saveToDisk();
    if (kDebugMode) print('Submission deleted: $id');
  }

  Future<Submission?> getSubmission(String id) async {
    return _submissions[id];
  }

  Future<List<Submission>> getAllSubmissions() async {
    final list = _submissions.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<List<Submission>> getPendingSubmissions() async {
    return _submissions.values
        .where((s) =>
            s.status == SubmissionStatus.saved ||
            s.status == SubmissionStatus.failed)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  // Diagnosis result operations
  Future<void> saveDiagnosisResult(DiagnosisResult result) async {
    _diagnosisResults[result.submissionId] = result;
    await _saveToDisk();
    if (kDebugMode) print('Diagnosis result saved: ${result.id}');
  }

  Future<DiagnosisResult?> getDiagnosisResult(String submissionId) async {
    return _diagnosisResults[submissionId];
  }

  Future<void> deleteDiagnosisResult(String id) async {
    _diagnosisResults.removeWhere((key, value) => value.id == id);
    await _saveToDisk();
  }

  // Clear all data
  Future<void> clearAllData() async {
    _submissions.clear();
    _diagnosisResults.clear();
    await _prefs.remove(_submissionsKey);
    await _prefs.remove(_resultsKey);
    if (kDebugMode) print('All data cleared');
  }

  Future<void> close() async {}
}
