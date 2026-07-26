import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const OfflineExamApp());
}

class OfflineExamApp extends StatelessWidget {
  const OfflineExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ATC Offline Exam',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0A2A66),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A2A66)),
      ),
      home: const StartPage(),
    );
  }
}

class QItem {
  QItem({required this.id, required this.subject, required this.content, required this.answers});

  final int id;
  final String subject;
  final String content;
  final List<AItem> answers;
}

class AItem {
  AItem({required this.id, required this.label, required this.content, required this.isCorrect});

  final int id;
  final String label;
  final String content;
  final bool isCorrect;
}

class OfflineDb {
  static Database? _db;

  static Future<Database> open() async {
    if (_db != null) return _db!;

    final dbDir = await getDatabasesPath();
    final dbPath = p.join(dbDir, 'offline_exam.db');

    final exists = await databaseExists(dbPath);
    if (!exists) {
      final data = await rootBundle.load('assets/offline_exam.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(dbPath, readOnly: true);
    return _db!;
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  String group = 'APS';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    await OfflineDb.open();
    setState(() => loading = false);
  }

  Future<List<QItem>> _loadExam(String subject) async {
    final db = await OfflineDb.open();
    final qRows = await db.query('questions', where: 'subject = ?', whereArgs: [subject]);
    final all = <QItem>[];
    for (final r in qRows) {
      final qid = r['id'] as int;
      final aRows = await db.query('answers', where: 'question_id = ?', whereArgs: [qid], orderBy: 'ord, id');
      if (aRows.length < 2) continue;
      final answers = aRows
          .map((a) => AItem(
                id: a['id'] as int,
                label: (a['label'] ?? '').toString(),
                content: (a['content'] ?? '').toString(),
                isCorrect: (a['is_correct'] as int) == 1,
              ))
          .toList();
      all.add(QItem(
        id: qid,
        subject: (r['subject'] ?? '').toString(),
        content: (r['content'] ?? '').toString(),
        answers: answers,
      ));
    }

    if (all.length > 50) {
      all.shuffle(Random());
      return all.take(50).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Thi thử offline', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Chọn nhóm đề', style: TextStyle(color: Colors.white, fontSize: 16)),
            Row(
              children: [
                Radio<String>(value: 'APS', groupValue: group, onChanged: (v) => setState(() => group = v!)),
                const Text('APS', style: TextStyle(color: Colors.white)),
                Radio<String>(value: 'ADC', groupValue: group, onChanged: (v) => setState(() => group = v!)),
                const Text('ADC', style: TextStyle(color: Colors.white)),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final exam = await _loadExam(group);
                if (exam.length < 50) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Nhóm $group chỉ có ${exam.length} câu, chưa đủ 50.')),
                  );
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (_) => ExamPage(exam: exam, group: group)));
              },
              child: const Text('Bắt đầu thi 50 câu'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamPage extends StatefulWidget {
  const ExamPage({super.key, required this.exam, required this.group});
  final List<QItem> exam;
  final String group;

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  int index = 0;
  final Map<int, int> selectedByQuestion = {};

  @override
  Widget build(BuildContext context) {
    final q = widget.exam[index];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Nhóm ${widget.group} - Câu ${index + 1}/50', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(12),
                child: ListView(
                  children: [
                    Text(q.content, style: const TextStyle(color: Color(0xFF0A2A66), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...q.answers.map((a) => RadioListTile<int>(
                          value: a.id,
                          groupValue: selectedByQuestion[index],
                          onChanged: (v) => setState(() => selectedByQuestion[index] = v!),
                          title: Text('${a.label}. ${a.content}', style: const TextStyle(color: Color(0xFF0A2A66))),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: index > 0 ? () => setState(() => index--) : null,
                  child: const Text('Câu trước'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: index < 49 ? () => setState(() => index++) : null,
                  child: const Text('Câu tiếp'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Nộp bài'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    int correct = 0;
    for (int i = 0; i < widget.exam.length; i++) {
      final q = widget.exam[i];
      final selectedId = selectedByQuestion[i];
      if (selectedId == null) continue;
      final ok = q.answers.where((a) => a.isCorrect).any((a) => a.id == selectedId);
      if (ok) correct++;
    }
    final score = (correct / widget.exam.length) * 10;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(score: score, correct: correct, total: widget.exam.length),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.score, required this.correct, required this.total});
  final double score;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kết quả thi', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Điểm: ${score.toStringAsFixed(2)}/10', style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Số câu đúng: $correct/$total', style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('Làm bài mới')),
          ],
        ),
      ),
    );
  }
}

