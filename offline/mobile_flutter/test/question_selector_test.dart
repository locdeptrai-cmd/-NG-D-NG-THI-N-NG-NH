import 'dart:math';

import 'package:atc_offline_mobile/data/models/exam_models.dart';
import 'package:atc_offline_mobile/data/repositories/question_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selects 35 percent TSN and balances knowledge categories', () {
    final questions = <QuestionItem>[];
    var id = 1;
    for (var category = 1; category <= 4; category++) {
      for (var index = 0; index < 15; index++) {
        questions.add(_question(id++, category, true));
      }
    }
    for (var category = 5; category <= 10; category++) {
      for (var index = 0; index < 15; index++) {
        questions.add(_question(id++, category, false));
      }
    }

    for (final entry in {10: 4, 20: 7, 50: 18}.entries) {
      final selected = selectBalancedMockQuestions(
        questions,
        entry.key,
        random: Random(entry.key),
      );
      final tsn = selected.where(isTsnQuestion).toList();
      final other = selected.where((item) => !isTsnQuestion(item)).toList();
      expect(selected, hasLength(entry.key));
      expect(tsn, hasLength(entry.value));
      _expectBalanced(tsn);
      _expectBalanced(other);
    }
  });

  test('excludes every question from the latest completed session', () {
    final questions = <QuestionItem>[];
    for (var id = 1; id <= 80; id++) {
      questions.add(_question(id, id % 8, id <= 30));
    }
    final excluded = questions.take(10).map((item) => item.id).toSet();
    final selected = selectBalancedMockQuestions(
      questions,
      20,
      excludedQuestionIds: excluded,
      random: Random(3),
    );
    expect(selected.map((item) => item.id).toSet().intersection(excluded),
        isEmpty);
  });
}

QuestionItem _question(int id, int category, bool tsn) {
  return QuestionItem(
    id: id,
    code: tsn ? 'ADC-TSN-$id' : 'ADC-GENERAL-$id',
    content: 'Question $id',
    questionType: 'single',
    categoryId: category,
    category: 'Category $category',
    difficulty: '',
    topic: '',
    explanation: '',
    referenceText: '',
    answers: const [],
  );
}

void _expectBalanced(List<QuestionItem> questions) {
  final counts = <int, int>{};
  for (final question in questions) {
    counts.update(question.categoryId!, (value) => value + 1,
        ifAbsent: () => 1);
  }
  final values = counts.values.toList();
  expect(values.reduce(max) - values.reduce(min), lessThanOrEqualTo(1));
}
