import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/submission.dart';
import '../models/diagnosis_result.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw Exception("SQLite not supported on Web in this configuration. Use Backend.");
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'crop_disease.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Submissions table
    await db.execute('''
      CREATE TABLE submissions (
        id TEXT PRIMARY KEY,
        mediaPath TEXT NOT NULL,
        mediaType TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        uploadedAt TEXT,
        diagnosedAt TEXT,
        diagnosisId TEXT
      )
    ''');

    // Diagnosis results table
    await db.execute('''
      CREATE TABLE diagnosis_results (
        id TEXT PRIMARY KEY,
        submissionId TEXT NOT NULL,
        diseaseName TEXT NOT NULL,
        severity TEXT NOT NULL,
        confidence REAL NOT NULL,
        diseaseIcon TEXT,
        description TEXT,
        diagnosedAt TEXT NOT NULL,
        isUnknown INTEGER NOT NULL,
        FOREIGN KEY (submissionId) REFERENCES submissions (id) ON DELETE CASCADE
      )
    ''');

    if (kDebugMode) {
      print('Database created successfully');
    }
  }

  // Submission CRUD operations
  Future<void> saveSubmission(Submission submission) async {
    if (kIsWeb) return; // No-op on web
    final db = await database;
    await db.insert(
      'submissions',
      submission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (kDebugMode) {
      print('Submission saved: ${submission.id}');
    }
  }

  Future<void> updateSubmission(Submission submission) async {
    if (kIsWeb) return; // No-op on web
    final db = await database;
    await db.update(
      'submissions',
      submission.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Changed to replace to handle partial updates
      where: 'id = ?',
      whereArgs: [submission.id],
    );
    if (kDebugMode) {
      print('Submission updated: ${submission.id}');
    }
  }

  Future<void> deleteSubmission(String id) async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete(
      'submissions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (kDebugMode) {
      print('Submission deleted: $id');
    }
  }

  Future<Submission?> getSubmission(String id) async {
    if (kIsWeb) return null;
    final db = await database;
    final results = await db.query(
      'submissions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return Submission.fromMap(results.first);
  }

  Future<List<Submission>> getAllSubmissions() async {
    if (kIsWeb) return [];
    final db = await database;
    final results = await db.query(
      'submissions',
      orderBy: 'createdAt DESC',
    );

    return results.map((map) => Submission.fromMap(map)).toList();
  }

  Future<List<Submission>> getPendingSubmissions() async {
    if (kIsWeb) return []; // No pending local submissions on Web
    final db = await database;
    final results = await db.query(
      'submissions',
      where: 'status = ? OR status = ?',
      whereArgs: [SubmissionStatus.saved.name, SubmissionStatus.failed.name],
      orderBy: 'createdAt ASC', // FIFO
    );

    return results.map((map) => Submission.fromMap(map)).toList();
  }

  // Diagnosis result operations
  Future<void> saveDiagnosisResult(DiagnosisResult result) async {
    if (kIsWeb) return;
    final db = await database;
    await db.insert(
      'diagnosis_results',
      result.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (kDebugMode) {
      print('Diagnosis result saved: ${result.id}');
    }
  }

  Future<DiagnosisResult?> getDiagnosisResult(String submissionId) async {
    if (kIsWeb) return null;
    final db = await database;
    final results = await db.query(
      'diagnosis_results',
      where: 'submissionId = ?',
      whereArgs: [submissionId],
    );

    if (results.isEmpty) return null;
    return DiagnosisResult.fromMap(results.first);
  }

  Future<void> deleteDiagnosisResult(String id) async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete(
      'diagnosis_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('submissions');
    await db.delete('diagnosis_results');
    if (kDebugMode) {
      print('All data cleared');
    }
  }

  // Close database
  Future<void> close() async {
    if (kIsWeb) return;
    final db = await database;
    await db.close();
  }
}
