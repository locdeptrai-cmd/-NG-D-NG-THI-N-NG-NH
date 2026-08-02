import 'dart:convert';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.role,
  });

  final int id;
  final String username;
  final String displayName;
  final String? role;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final firstName = (json['first_name'] ?? '').toString().trim();
    final lastName = (json['last_name'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();
    return UserProfile(
      id: json['id'] as int,
      username: json['username'].toString(),
      displayName: fullName.isEmpty ? json['username'].toString() : fullName,
      role: json['role']?.toString(),
    );
  }
}

class SubjectSummary {
  const SubjectSummary({
    required this.id,
    required this.code,
    required this.name,
    required this.questionCount,
  });

  final int id;
  final String code;
  final String name;
  final int questionCount;

  factory SubjectSummary.fromJson(Map<String, dynamic> json) {
    return SubjectSummary(
      id: json['id'] as int,
      code: json['code'].toString(),
      name: json['name'].toString(),
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuestionPackageSummary {
  const QuestionPackageSummary({
    required this.packageId,
    required this.name,
    required this.version,
    required this.checksum,
    required this.minimumAppVersion,
    required this.updatedAt,
    required this.sizeBytes,
    required this.questionCount,
    required this.subject,
    this.downloadedAt,
  });

  final String packageId;
  final String name;
  final int version;
  final String checksum;
  final String minimumAppVersion;
  final DateTime updatedAt;
  final int sizeBytes;
  final int questionCount;
  final SubjectSummary subject;
  final DateTime? downloadedAt;

  bool get isDownloaded => downloadedAt != null;

  factory QuestionPackageSummary.fromJson(Map<String, dynamic> json) {
    final subject = SubjectSummary.fromJson({
      ...(json['subject'] as Map<String, dynamic>),
      'question_count': json['question_count'],
    });
    return QuestionPackageSummary(
      packageId: json['package_id'].toString(),
      name: json['name'].toString(),
      version: (json['version'] as num).toInt(),
      checksum: json['checksum'].toString(),
      minimumAppVersion: json['minimum_app_version'].toString(),
      updatedAt: DateTime.parse(json['updated_at'].toString()).toUtc(),
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
      subject: subject,
    );
  }
}

class QuestionPackageBundle extends QuestionPackageSummary {
  const QuestionPackageBundle({
    required super.packageId,
    required super.name,
    required super.version,
    required super.checksum,
    required super.minimumAppVersion,
    required super.updatedAt,
    required super.sizeBytes,
    required super.questionCount,
    required super.subject,
    required this.questions,
  });

  final List<QuestionItem> questions;

  factory QuestionPackageBundle.fromJson(Map<String, dynamic> json) {
    final summary = QuestionPackageSummary.fromJson(json);
    return QuestionPackageBundle(
      packageId: summary.packageId,
      name: summary.name,
      version: summary.version,
      checksum: summary.checksum,
      minimumAppVersion: summary.minimumAppVersion,
      updatedAt: summary.updatedAt,
      sizeBytes: summary.sizeBytes,
      questionCount: summary.questionCount,
      subject: summary.subject,
      questions: (json['questions'] as List<dynamic>)
          .map(
            (item) => QuestionItem.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class QuestionItem {
  const QuestionItem({
    required this.id,
    required this.code,
    required this.content,
    required this.questionType,
    required this.categoryId,
    required this.category,
    required this.difficulty,
    required this.topic,
    required this.explanation,
    required this.referenceText,
    required this.answers,
  });

  final int id;
  final String code;
  final String content;
  final String questionType;
  final int? categoryId;
  final String category;
  final String difficulty;
  final String topic;
  final String explanation;
  final String referenceText;
  final List<AnswerOption> answers;

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    final correct = (json['correct_answer'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toSet();
    return QuestionItem(
      id: (json['id'] as num).toInt(),
      code: json['code'].toString(),
      content: json['content'].toString(),
      questionType: (json['question_type'] ?? 'single').toString(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      category: (json['category'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? '').toString(),
      topic: (json['topic'] ?? '').toString(),
      explanation: (json['explanation'] ?? '').toString(),
      referenceText: (json['reference'] ?? '').toString(),
      answers: (json['answers'] as List<dynamic>)
          .map(
            (item) => AnswerOption.fromJson(
              item as Map<String, dynamic>,
              correct,
            ),
          )
          .toList(),
    );
  }
}

class AnswerOption {
  const AnswerOption({
    required this.id,
    required this.label,
    required this.content,
    required this.isCorrect,
  });

  final int id;
  final String label;
  final String content;
  final bool isCorrect;

  factory AnswerOption.fromJson(
    Map<String, dynamic> json,
    Set<String> correct,
  ) {
    return AnswerOption(
      id: (json['id'] as num).toInt(),
      label: json['label'].toString(),
      content: json['content'].toString(),
      isCorrect: correct.contains(json['label'].toString()),
    );
  }
}

class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.subject,
    required this.startedAt,
    required this.questions,
  });

  final String id;
  final SubjectSummary subject;
  final DateTime startedAt;
  final List<QuestionItem> questions;
}

class CompletedPracticeAttempt {
  const CompletedPracticeAttempt({
    required this.id,
    required this.subjectId,
    required this.subjectCode,
    required this.startedAt,
    required this.completedAt,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.answers,
  });

  final String id;
  final int subjectId;
  final String subjectCode;
  final DateTime startedAt;
  final DateTime completedAt;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final List<Map<String, dynamic>> answers;

  Map<String, dynamic> toSyncJson() {
    return {
      'local_attempt_id': id,
      'subject_id': subjectId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'answers': answers,
      'started_at': startedAt.toUtc().toIso8601String(),
      'completed_at': completedAt.toUtc().toIso8601String(),
    };
  }
}

Map<String, dynamic> decodeJsonMap(String source) {
  return jsonDecode(source) as Map<String, dynamic>;
}
