import 'dart:math';

import '../models/exam_models.dart';

const supportedMockQuestionCounts = [20, 50, 100];
const tsnQuestionPercent = 35;
const recentExamExclusionLimit = 6;
const categoryOnlySubjects = {'SUP', 'ACS SUP HCM', 'SUP ACS HAN'};

bool usesTsnRatio(String? subjectCode) {
  final code = (subjectCode ?? '').trim().toUpperCase();
  return !categoryOnlySubjects.map((item) => item.toUpperCase()).contains(code);
}

int tsnTargetCount(int total) {
  if (!supportedMockQuestionCounts.contains(total)) {
    throw ArgumentError('Số câu chỉ được chọn 20, 50 hoặc 100.');
  }
  return (total * tsnQuestionPercent / 100).round();
}

bool isTsnQuestion(QuestionItem question) {
  final text = [
    question.code,
    question.content,
    question.topic,
  ].join(' ').toUpperCase();
  return RegExp(r'(^|[^A-Z0-9])TSN([^A-Z0-9]|$)').hasMatch(text) ||
      text.contains('TÂN SƠN NHẤT') ||
      text.contains('TAN SON NHAT') ||
      text.contains('TANSONNHAT');
}

List<QuestionItem> selectBalancedMockQuestions(
  List<QuestionItem> available,
  int total, {
  Set<int> excludedQuestionIds = const {},
  String? subjectCode,
  Random? random,
}) {
  final rng = random ?? Random.secure();
  final eligible = available
      .where((question) => !excludedQuestionIds.contains(question.id))
      .toList();

  final List<QuestionItem> selected;
  if (usesTsnRatio(subjectCode)) {
    final tsnCount = tsnTargetCount(total);
    final otherCount = total - tsnCount;
    final tsn = eligible.where(isTsnQuestion).toList();
    final other = eligible.where((question) => !isTsnQuestion(question)).toList();

    if (tsn.length < tsnCount) {
      throw StateError(
        'Ngân hàng chỉ còn ${tsn.length} câu TSN; cần $tsnCount câu '
        'để đạt tỷ lệ $tsnQuestionPercent%.',
      );
    }
    if (other.length < otherCount) {
      throw StateError(
        'Ngân hàng chỉ còn ${other.length} câu ngoài TSN; '
        'cần $otherCount câu.',
      );
    }
    selected = [
      ..._balancedTake(tsn, tsnCount, rng),
      ..._balancedTake(other, otherCount, rng),
    ];
  } else {
    if (eligible.length < total) {
      throw StateError(
        'Ngân hàng chỉ còn ${eligible.length} câu; cần $total câu.',
      );
    }
    selected = _balancedTake(eligible, total, rng);
  }

  final unique = <QuestionItem>[];
  final seenIds = <int>{};
  for (final question in selected) {
    if (!seenIds.add(question.id)) continue;
    unique.add(question);
  }
  if (unique.length != total) {
    throw StateError(
      'Không tạo được đề $total câu không trùng '
      '(chỉ chọn được ${unique.length} câu).',
    );
  }
  unique.shuffle(rng);
  return unique;
}

List<QuestionItem> _balancedTake(
  List<QuestionItem> questions,
  int count,
  Random random,
) {
  final buckets = <String, List<QuestionItem>>{};
  final seenIds = <int>{};
  for (final question in questions) {
    if (!seenIds.add(question.id)) continue;
    final key = question.categoryId?.toString() ?? question.category;
    buckets.putIfAbsent(key, () => []).add(question);
  }
  final keys = buckets.keys.toList()..shuffle(random);
  for (final bucket in buckets.values) {
    bucket.shuffle(random);
  }

  final selected = <QuestionItem>[];
  final selectedIds = <int>{};
  while (selected.length < count) {
    var progressed = false;
    for (final key in keys) {
      final bucket = buckets[key]!;
      if (bucket.isEmpty) continue;
      final question = bucket.removeLast();
      if (!selectedIds.add(question.id)) continue;
      selected.add(question);
      progressed = true;
      if (selected.length == count) break;
    }
    if (!progressed) break;
  }
  return selected;
}
