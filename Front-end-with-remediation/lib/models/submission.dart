enum MediaType { image, video }

enum SubmissionStatus {
  saved, // Saved locally, not uploaded yet
  uploading, // Currently uploading
  submitted, // Successfully uploaded
  failed, // Upload failed
  diagnosed, // Diagnosis result received
}

class Submission {
  final String id;
  final String mediaPath;
  final MediaType mediaType;
  SubmissionStatus status;
  final DateTime createdAt;
  DateTime? uploadedAt;
  DateTime? diagnosedAt;
  String? diagnosisId;

  Submission({
    required this.id,
    required this.mediaPath,
    required this.mediaType,
    this.status = SubmissionStatus.saved,
    required this.createdAt,
    this.uploadedAt,
    this.diagnosedAt,
    this.diagnosisId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mediaPath': mediaPath,
      'mediaType': mediaType.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'uploadedAt': uploadedAt?.toIso8601String(),
      'diagnosedAt': diagnosedAt?.toIso8601String(),
      'diagnosisId': diagnosisId,
    };
  }

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'],
      mediaPath: map['mediaPath'],
      mediaType: MediaType.values.firstWhere((e) => e.name == map['mediaType']),
      status:
          SubmissionStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['createdAt']),
      uploadedAt:
          map['uploadedAt'] != null ? DateTime.parse(map['uploadedAt']) : null,
      diagnosedAt: map['diagnosedAt'] != null
          ? DateTime.parse(map['diagnosedAt'])
          : null,
      diagnosisId: map['diagnosisId'],
    );
  }

  Submission copyWith({
    String? id,
    String? mediaPath,
    MediaType? mediaType,
    SubmissionStatus? status,
    DateTime? createdAt,
    DateTime? uploadedAt,
    DateTime? diagnosedAt,
    String? diagnosisId,
  }) {
    return Submission(
      id: id ?? this.id,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaType: mediaType ?? this.mediaType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      diagnosedAt: diagnosedAt ?? this.diagnosedAt,
      diagnosisId: diagnosisId ?? this.diagnosisId,
    );
  }
}
