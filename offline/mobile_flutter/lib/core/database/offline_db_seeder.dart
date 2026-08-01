import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../data/models/exam_models.dart';
import 'app_database.dart';

/// Seeds Drift from the bundled `assets/offline_exam.db` so offline mobile
/// apps can practice APS/ADC/ACC HAN/SUP without an initial network download.
class OfflineDbSeeder {
  OfflineDbSeeder(this._database);

  final AppDatabase _database;

  Future<void> seedIfNeeded() async {
    if (kIsWeb) return;

    final packages = await _database.getPackages();
    if (packages.any((item) => item.isDownloaded)) return;

    final existingQuestions = await (_database.select(_database.localQuestions)
          ..limit(1))
        .get();
    if (existingQuestions.isNotEmpty) return;

    ByteData bytes;
    try {
      bytes = await rootBundle.load('assets/offline_exam.db');
    } catch (_) {
      return;
    }

    final temp = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}atc_offline_seed.db',
    );
    await temp.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );

    final conn = sqlite3.open(temp.path, mode: OpenMode.readOnly);
    try {
      final subjects = conn.select(
        'SELECT DISTINCT subject FROM questions ORDER BY subject',
      );
      var subjectId = 1;
      for (final row in subjects) {
        final code = row['subject'] as String;
        await _seedSubject(
          conn: conn,
          subjectCode: code,
          subjectId: subjectId,
        );
        subjectId += 1;
      }
    } finally {
      conn.dispose();
      try {
        await temp.delete();
      } catch (_) {}
    }
  }

  Future<void> _seedSubject({
    required Database conn,
    required String subjectCode,
    required int subjectId,
  }) async {
    final year = DateTime.now().year;
    final slug = subjectCode.replaceAll(' ', '_').replaceAll('/', '_');
    final packageId = '$slug-$year-PRACTICE';

    final questionRows = conn.select(
      '''
      SELECT id, code, subject, category, content, explanation, question_type
      FROM questions
      WHERE subject = ?
      ORDER BY id
      ''',
      [subjectCode],
    );
    if (questionRows.isEmpty) return;

    final questions = <QuestionItem>[];
    for (final q in questionRows) {
      final qid = q['id'] as int;
      final answers = conn
          .select(
            '''
            SELECT id, label, content, is_correct
            FROM answers
            WHERE question_id = ?
            ORDER BY ord, id
            ''',
            [qid],
          )
          .map(
            (a) => AnswerOption(
              id: a['id'] as int,
              label: (a['label'] as String?) ?? '',
              content: (a['content'] as String?) ?? '',
              isCorrect: (a['is_correct'] as int? ?? 0) == 1,
            ),
          )
          .toList();
      if (answers.length < 2) continue;

      questions.add(
        QuestionItem(
          id: qid,
          code: (q['code'] as String?) ?? '$subjectCode-$qid',
          content: (q['content'] as String?) ?? '',
          questionType: (q['question_type'] as String?) ?? 'single',
          categoryId: null,
          category: (q['category'] as String?) ?? '',
          difficulty: '',
          topic: '',
          explanation: (q['explanation'] as String?) ?? '',
          referenceText: '',
          answers: answers,
        ),
      );
    }
    if (questions.isEmpty) return;

    final bundle = QuestionPackageBundle(
      packageId: packageId,
      name: 'Ngân hàng luyện tập $subjectCode',
      version: 1,
      checksum: 'bundled:$packageId',
      minimumAppVersion: '1.0.0',
      updatedAt: DateTime.now().toUtc(),
      sizeBytes: 0,
      questionCount: questions.length,
      subject: SubjectSummary(
        id: subjectId,
        code: subjectCode,
        name: subjectCode,
        questionCount: questions.length,
      ),
      questions: questions,
    );
    await _database.replacePackage(bundle);
  }
}
