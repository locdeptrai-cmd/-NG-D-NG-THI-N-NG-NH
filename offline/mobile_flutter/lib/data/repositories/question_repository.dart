import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../core/api/api_client.dart';
import '../../core/database/app_database.dart';
import '../../core/database/offline_db_seeder.dart';
import '../models/exam_models.dart';

class QuestionRepository {
  QuestionRepository({
    required AppDatabase database,
    required ApiClient api,
  })  : _database = database,
        _api = api,
        _seeder = OfflineDbSeeder(database);

  final AppDatabase _database;
  final ApiClient _api;
  final OfflineDbSeeder _seeder;
  final Uuid _uuid = const Uuid();

  Future<void> initialize() async {
    await _api.initialize();
    await _seeder.seedIfNeeded();
  }

  Future<bool> isOnline() => _api.isOnline();

  Future<bool> recoverDefaultServer() => _api.recoverDefaultBaseUrl();

  Future<bool> hasSession() => _api.hasSession();

  Future<UserProfile?> cachedUser() => _database.getCachedUser();

  Future<UserProfile> login(String username, String password) async {
    await _api.login(username, password);
    final profile = await _api.me();
    await _database.cacheUser(profile);
    await refreshCatalog();
    return profile;
  }

  Future<void> logout() => _api.logout();

  Future<void> setBaseUrl(String value) => _api.setBaseUrl(value);

  Future<void> resetToProductionBaseUrl() => _api.resetToProductionBaseUrl();

  String get baseUrl => _api.baseUrl;

  String get productionBaseUrl => ApiClient.productionBaseUrl;

  Future<void> refreshCatalog() async {
    final results = await Future.wait([
      _api.getSubjects(),
      _api.getPackages(),
    ]);
    await _database.cacheCatalog(
      results[0] as List<SubjectSummary>,
      results[1] as List<QuestionPackageSummary>,
    );
  }

  Future<List<SubjectSummary>> getSubjects() => _database.getSubjects();

  Future<List<QuestionPackageSummary>> getPackages() {
    return _database.getPackages();
  }

  Future<void> downloadPackage(String packageId) async {
    final package = await _api.downloadPackage(packageId);
    await _database.replacePackage(package);
  }

  Future<void> removePackage(String packageId) {
    return _database.removePackage(packageId);
  }

  Future<PracticeSession> createPractice(
    QuestionPackageSummary package, {
    int questionCount = 20,
  }) async {
    final available = await _database.questionsForPackage(package.packageId);
    if (available.isEmpty) {
      throw StateError('Gói ${package.subject.code} chưa được tải.');
    }
    available.shuffle(Random.secure());
    final count = min(questionCount, available.length);
    return PracticeSession(
      id: 'local-${_uuid.v4()}',
      subject: package.subject,
      startedAt: DateTime.now().toUtc(),
      questions: available.take(count).toList(),
    );
  }

  Future<void> completePractice(
    PracticeSession session,
    Map<int, int> selections,
  ) async {
    var correct = 0;
    final answers = <Map<String, dynamic>>[];
    for (final question in session.questions) {
      final answerId = selections[question.id];
      final isCorrect = question.answers.any(
        (answer) => answer.id == answerId && answer.isCorrect,
      );
      if (isCorrect) correct += 1;
      answers.add({
        'question_id': question.id,
        'answer_ids': answerId == null ? <int>[] : [answerId],
        'is_correct': isCorrect,
      });
    }
    final score = correct / session.questions.length * 100;
    final attempt = CompletedPracticeAttempt(
      id: session.id,
      subjectId: session.subject.id,
      subjectCode: session.subject.code,
      startedAt: session.startedAt,
      completedAt: DateTime.now().toUtc(),
      score: score,
      totalQuestions: session.questions.length,
      correctAnswers: correct,
      answers: answers,
    );
    await _database.saveAttemptAndEnqueue(
      attempt,
      'op-${_uuid.v4()}',
    );
  }

  Future<int> syncPending() async {
    if (!await _api.isOnline() || !await _api.hasSession()) return 0;
    final preferences = await _database.getCachedUser();
    if (preferences == null) return 0;
    final clientId = 'pwa-${preferences.id}';
    final pending = await _database.pendingSyncItems();
    if (pending.isEmpty) return 0;
    final operations = pending
        .map(
          (item) => {
            'operation_id': item.id,
            'type': item.actionName,
            'payload': decodeJsonMap(item.payloadJson),
          },
        )
        .toList();
    try {
      final results = await _api.sync(clientId, operations);
      var completed = 0;
      for (final result in results) {
        final operationId = result['operation_id'].toString();
        final local = pending.firstWhere((item) => item.id == operationId);
        if (result['status'] == 'completed') {
          await _database.markSyncCompleted(operationId, local.entityId);
          completed += 1;
        } else {
          await _database.markSyncFailed(
            operationId,
            (result['error'] ?? 'Đồng bộ thất bại').toString(),
          );
        }
      }
      return completed;
    } catch (error) {
      for (final item in pending) {
        await _database.markSyncFailed(item.id, error.toString());
      }
      rethrow;
    }
  }

  Future<int> pendingSyncCount() => _database.pendingSyncCount();

  Future<List<LocalAttempt>> getAttempts() => _database.getAttempts();
}
