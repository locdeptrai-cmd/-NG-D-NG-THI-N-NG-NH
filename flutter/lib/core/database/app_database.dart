import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../data/models/exam_models.dart';

part 'app_database.g.dart';

class LocalSubjects extends Table {
  IntColumn get serverId => integer()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  IntColumn get questionCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {serverId};
}

class LocalPackages extends Table {
  TextColumn get packageId => text()();
  IntColumn get subjectId => integer()();
  TextColumn get subjectCode => text()();
  TextColumn get name => text()();
  IntColumn get version => integer()();
  TextColumn get checksum => text()();
  TextColumn get minimumAppVersion => text()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  IntColumn get questionCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get downloadedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {packageId};
}

class LocalQuestions extends Table {
  IntColumn get id => integer()();
  TextColumn get packageId => text()();
  TextColumn get code => text()();
  TextColumn get content => text()();
  TextColumn get questionType => text()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get category => text().withDefault(const Constant(''))();
  TextColumn get difficulty => text().withDefault(const Constant(''))();
  TextColumn get topic => text().withDefault(const Constant(''))();
  TextColumn get explanation => text().withDefault(const Constant(''))();
  TextColumn get referenceText => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAnswers extends Table {
  IntColumn get id => integer()();
  IntColumn get questionId => integer()();
  TextColumn get label => text()();
  TextColumn get content => text()();
  BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAttempts extends Table {
  TextColumn get id => text()();
  IntColumn get subjectId => integer()();
  TextColumn get subjectCode => text()();
  TextColumn get mode => text().withDefault(const Constant('practice'))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  RealColumn get score => real().nullable()();
  IntColumn get totalQuestions => integer().withDefault(const Constant(0))();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  TextColumn get answersJson => text().withDefault(const Constant('[]'))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueueItems extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get actionName => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class LocalUserProfiles extends Table {
  IntColumn get serverId => integer()();
  TextColumn get username => text()();
  TextColumn get displayName => text()();
  TextColumn get role => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {serverId};
}

@DriftDatabase(
  tables: [
    LocalSubjects,
    LocalPackages,
    LocalQuestions,
    LocalAnswers,
    LocalAttempts,
    SyncQueueItems,
    AppSettings,
    LocalUserProfiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults()
      : super(
          driftDatabase(
            name: 'atc_exam_offline',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
            native: const DriftNativeOptions(shareAcrossIsolates: true),
          ),
        );

  @override
  int get schemaVersion => 1;

  static String downloadedVersionKey(String packageId) =>
      'pkg_downloaded_version:$packageId';

  static String downloadedChecksumKey(String packageId) =>
      'pkg_downloaded_checksum:$packageId';

  Future<void> putSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)
          ..where((item) => item.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> deleteSetting(String key) async {
    await (delete(appSettings)..where((item) => item.key.equals(key))).go();
  }

  Future<void> rememberDownloadedPackageMeta({
    required String packageId,
    required int version,
    required String checksum,
  }) async {
    await putSetting(downloadedVersionKey(packageId), '$version');
    await putSetting(downloadedChecksumKey(packageId), checksum);
  }

  Future<void> clearDownloadedPackageMeta(String packageId) async {
    await deleteSetting(downloadedVersionKey(packageId));
    await deleteSetting(downloadedChecksumKey(packageId));
  }

  Future<({int? version, String? checksum})> downloadedPackageMeta(
    String packageId,
  ) async {
    final versionRaw = await getSetting(downloadedVersionKey(packageId));
    final checksum = await getSetting(downloadedChecksumKey(packageId));
    return (
      version: int.tryParse(versionRaw ?? ''),
      checksum: checksum,
    );
  }

  Future<void> cacheCatalog(
    List<SubjectSummary> subjects,
    List<QuestionPackageSummary> packages,
  ) async {
    await transaction(() async {
      for (final subject in subjects) {
        // Drop stale rows that share the same code but a different server id
        // so UNIQUE(code) cannot abort the whole catalog refresh.
        await (delete(localSubjects)
              ..where(
                (row) =>
                    row.code.equals(subject.code) &
                    row.serverId.isNotValue(subject.id),
              ))
            .go();
        await into(localSubjects).insertOnConflictUpdate(
          LocalSubjectsCompanion.insert(
            serverId: Value(subject.id),
            code: subject.code,
            name: subject.name,
            questionCount: Value(subject.questionCount),
          ),
        );
      }

      final incomingIds = packages.map((item) => item.packageId).toSet();
      for (final item in packages) {
        final legacyId = _legacySpacedPackageId(item);
        final old = await (select(localPackages)
              ..where((row) => row.packageId.equals(item.packageId)))
            .getSingleOrNull();
        LocalPackage? legacy;
        if (legacyId != null && legacyId != item.packageId) {
          legacy = await (select(localPackages)
                ..where((row) => row.packageId.equals(legacyId)))
              .getSingleOrNull();
        }

        final downloadedAt = old?.downloadedAt ?? legacy?.downloadedAt;
        await into(localPackages).insertOnConflictUpdate(
          _packageCompanion(item, downloadedAt: downloadedAt),
        );

        // Migrate questions downloaded under the old spaced package id.
        if (legacy != null && legacy.packageId != item.packageId) {
          await customStatement(
            'UPDATE local_questions SET package_id = ? WHERE package_id = ?',
            [item.packageId, legacy.packageId],
          );
          await (delete(localPackages)
                ..where((row) => row.packageId.equals(legacy!.packageId)))
              .go();
        }
      }

      // Remove catalog rows for packages the server no longer advertises,
      // but keep rows that still have downloaded question data.
      final existing = await select(localPackages).get();
      for (final row in existing) {
        if (incomingIds.contains(row.packageId)) continue;
        if (row.downloadedAt != null) continue;
        await (delete(localPackages)
              ..where((tbl) => tbl.packageId.equals(row.packageId)))
            .go();
      }
    });
  }

  /// Old servers used package ids like `ACC HAN-2026-PRACTICE` (with spaces).
  String? _legacySpacedPackageId(QuestionPackageSummary item) {
    final slug = item.subject.code.replaceAll(' ', '_');
    final prefix = '$slug-';
    if (!item.packageId.startsWith(prefix)) return null;
    final suffix = item.packageId.substring(prefix.length);
    final legacy = '${item.subject.code}-$suffix';
    return legacy == item.packageId ? null : legacy;
  }

  LocalPackagesCompanion _packageCompanion(
    QuestionPackageSummary item, {
    DateTime? downloadedAt,
  }) {
    return LocalPackagesCompanion.insert(
      packageId: item.packageId,
      subjectId: item.subject.id,
      subjectCode: item.subject.code,
      name: item.name,
      version: item.version,
      checksum: item.checksum,
      minimumAppVersion: item.minimumAppVersion,
      updatedAt: item.updatedAt,
      sizeBytes: Value(item.sizeBytes),
      questionCount: Value(item.questionCount),
      downloadedAt: Value(downloadedAt),
    );
  }

  Future<void> replacePackage(QuestionPackageBundle bundle) async {
    await transaction(() async {
      await customStatement(
        'DELETE FROM local_answers WHERE question_id IN '
        '(SELECT id FROM local_questions WHERE package_id = ?)',
        [bundle.packageId],
      );
      await (delete(localQuestions)
            ..where((row) => row.packageId.equals(bundle.packageId)))
          .go();
      await into(localPackages).insertOnConflictUpdate(
        _packageCompanion(bundle, downloadedAt: DateTime.now().toUtc()),
      );
      await rememberDownloadedPackageMeta(
        packageId: bundle.packageId,
        version: bundle.version,
        checksum: bundle.checksum,
      );

      await batch((batch) {
        for (final question in bundle.questions) {
          batch.insert(
            localQuestions,
            LocalQuestionsCompanion.insert(
              id: Value(question.id),
              packageId: bundle.packageId,
              code: question.code,
              content: question.content,
              questionType: question.questionType,
              categoryId: Value(question.categoryId),
              category: Value(question.category),
              difficulty: Value(question.difficulty),
              topic: Value(question.topic),
              explanation: Value(question.explanation),
              referenceText: Value(question.referenceText),
            ),
            mode: InsertMode.insertOrReplace,
          );
          for (final answer in question.answers) {
            batch.insert(
              localAnswers,
              LocalAnswersCompanion.insert(
                id: Value(answer.id),
                questionId: question.id,
                label: answer.label,
                content: answer.content,
                isCorrect: Value(answer.isCorrect),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        }
      });
    });
  }

  Future<List<QuestionPackageSummary>> getPackages() async {
    final rows = await (select(localPackages)
          ..orderBy([(row) => OrderingTerm.asc(row.subjectCode)]))
        .get();
    final packages = <QuestionPackageSummary>[];
    for (final row in rows) {
      final meta = await downloadedPackageMeta(row.packageId);
      packages.add(
        QuestionPackageSummary(
          packageId: row.packageId,
          name: row.name,
          version: row.version,
          checksum: row.checksum,
          minimumAppVersion: row.minimumAppVersion,
          updatedAt: row.updatedAt,
          sizeBytes: row.sizeBytes,
          questionCount: row.questionCount,
          downloadedAt: row.downloadedAt,
          downloadedVersion: meta.version,
          downloadedChecksum: meta.checksum,
          subject: SubjectSummary(
            id: row.subjectId,
            code: row.subjectCode,
            name: row.subjectCode,
            questionCount: row.questionCount,
          ),
        ),
      );
    }
    return packages;
  }

  Future<List<SubjectSummary>> getSubjects() async {
    final rows = await (select(localSubjects)
          ..orderBy([(row) => OrderingTerm.asc(row.code)]))
        .get();
    return rows
        .map(
          (row) => SubjectSummary(
            id: row.serverId,
            code: row.code,
            name: row.name,
            questionCount: row.questionCount,
          ),
        )
        .toList();
  }

  Future<List<QuestionItem>> questionsForPackage(String packageId) async {
    final questionRows = await (select(localQuestions)
          ..where((row) => row.packageId.equals(packageId)))
        .get();
    if (questionRows.isEmpty) return [];
    final ids = questionRows.map((row) => row.id).toList();
    final answerRows = await (select(localAnswers)
          ..where((row) => row.questionId.isIn(ids))
          ..orderBy([
            (row) => OrderingTerm.asc(row.questionId),
            (row) => OrderingTerm.asc(row.label),
          ]))
        .get();
    final answersByQuestion = <int, List<AnswerOption>>{};
    for (final row in answerRows) {
      answersByQuestion.putIfAbsent(row.questionId, () => []).add(
            AnswerOption(
              id: row.id,
              label: row.label,
              content: row.content,
              isCorrect: row.isCorrect,
            ),
          );
    }
    return questionRows
        .map(
          (row) => QuestionItem(
            id: row.id,
            code: row.code,
            content: row.content,
            questionType: row.questionType,
            categoryId: row.categoryId,
            category: row.category,
            difficulty: row.difficulty,
            topic: row.topic,
            explanation: row.explanation,
            referenceText: row.referenceText,
            answers: answersByQuestion[row.id] ?? const [],
          ),
        )
        .where((question) => question.answers.length >= 2)
        .toList();
  }

  Future<void> removePackage(String packageId) async {
    await transaction(() async {
      await customStatement(
        'DELETE FROM local_answers WHERE question_id IN '
        '(SELECT id FROM local_questions WHERE package_id = ?)',
        [packageId],
      );
      await (delete(localQuestions)
            ..where((row) => row.packageId.equals(packageId)))
          .go();
      await (update(localPackages)
            ..where((row) => row.packageId.equals(packageId)))
          .write(const LocalPackagesCompanion(downloadedAt: Value(null)));
      await clearDownloadedPackageMeta(packageId);
    });
  }

  Future<void> saveAttemptAndEnqueue(
    CompletedPracticeAttempt attempt,
    String operationId,
  ) async {
    final payload = jsonEncode(attempt.toSyncJson());
    await transaction(() async {
      await into(localAttempts).insertOnConflictUpdate(
        LocalAttemptsCompanion.insert(
          id: attempt.id,
          subjectId: attempt.subjectId,
          subjectCode: attempt.subjectCode,
          startedAt: attempt.startedAt,
          completedAt: Value(attempt.completedAt),
          score: Value(attempt.score),
          totalQuestions: Value(attempt.totalQuestions),
          correctAnswers: Value(attempt.correctAnswers),
          answersJson: Value(jsonEncode(attempt.answers)),
        ),
      );
      await into(syncQueueItems).insertOnConflictUpdate(
        SyncQueueItemsCompanion.insert(
          id: operationId,
          entityType: 'exam_attempt',
          entityId: attempt.id,
          actionName: 'submit_practice_attempt',
          payloadJson: payload,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    });
  }

  Future<List<SyncQueueItem>> pendingSyncItems() {
    return (select(syncQueueItems)
          ..where((row) => row.status.equals('pending'))
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
  }

  Future<int> pendingSyncCount() async {
    final count = syncQueueItems.id.count();
    final query = selectOnly(syncQueueItems)
      ..addColumns([count])
      ..where(syncQueueItems.status.equals('pending'));
    return (await query.map((row) => row.read(count) ?? 0).getSingle());
  }

  Future<void> markSyncCompleted(String operationId, String entityId) async {
    await transaction(() async {
      await (update(syncQueueItems)..where((row) => row.id.equals(operationId)))
          .write(const SyncQueueItemsCompanion(status: Value('completed')));
      await (update(localAttempts)..where((row) => row.id.equals(entityId)))
          .write(const LocalAttemptsCompanion(syncStatus: Value('completed')));
    });
  }

  Future<void> markSyncFailed(String operationId, String error) async {
    final item = await (select(syncQueueItems)
          ..where((row) => row.id.equals(operationId)))
        .getSingle();
    await (update(syncQueueItems)..where((row) => row.id.equals(operationId)))
        .write(
      SyncQueueItemsCompanion(
        retryCount: Value(item.retryCount + 1),
        lastError: Value(error),
      ),
    );
  }

  Future<List<LocalAttempt>> getAttempts() {
    return (select(localAttempts)
          ..orderBy([(row) => OrderingTerm.desc(row.startedAt)]))
        .get();
  }

  Future<Set<int>> latestCompletedQuestionIds(String subjectCode) {
    return recentCompletedQuestionIds(subjectCode, limit: 1);
  }

  Future<Set<int>> recentCompletedQuestionIds(
    String subjectCode, {
    int limit = 6,
  }) async {
    final rows = await (select(localAttempts)
          ..where(
            (item) =>
                item.subjectCode.equals(subjectCode) &
                item.completedAt.isNotNull(),
          )
          ..orderBy([(item) => OrderingTerm.desc(item.completedAt)])
          ..limit(limit))
        .get();
    return _questionIdsFromAttempts(rows);
  }

  Future<Set<int>> allCompletedQuestionIds(String subjectCode) async {
    final rows = await (select(localAttempts)
          ..where(
            (item) =>
                item.subjectCode.equals(subjectCode) &
                item.completedAt.isNotNull(),
          ))
        .get();
    return _questionIdsFromAttempts(rows);
  }

  Set<int> _questionIdsFromAttempts(List<LocalAttempt> rows) {
    final excluded = <int>{};
    for (final row in rows) {
      try {
        final answers = jsonDecode(row.answersJson) as List<dynamic>;
        for (final item in answers) {
          final questionId =
              ((item as Map<String, dynamic>)['question_id'] as num?)?.toInt();
          if (questionId != null) excluded.add(questionId);
        }
      } catch (_) {
        // Ignore malformed local history rows.
      }
    }
    return excluded;
  }

  /// Drop completed practice history for [subjectCode] so a fresh cycle can start.
  Future<int> clearCompletedAttemptsForSubject(String subjectCode) async {
    return (delete(localAttempts)
          ..where(
            (item) =>
                item.subjectCode.equals(subjectCode) &
                item.completedAt.isNotNull(),
          ))
        .go();
  }

  Future<void> cacheUser(UserProfile profile) async {
    await into(localUserProfiles).insertOnConflictUpdate(
      LocalUserProfilesCompanion.insert(
        serverId: Value(profile.id),
        username: profile.username,
        displayName: profile.displayName,
        role: Value(profile.role),
        cachedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<UserProfile?> getCachedUser() async {
    final row = await (select(localUserProfiles)
          ..orderBy([(item) => OrderingTerm.desc(item.cachedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return UserProfile(
      id: row.serverId,
      username: row.username,
      displayName: row.displayName,
      role: row.role,
    );
  }
}
