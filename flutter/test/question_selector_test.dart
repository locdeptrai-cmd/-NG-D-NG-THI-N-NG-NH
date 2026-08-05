import 'dart:math';

import 'package:atc_offline_mobile/data/models/exam_models.dart';
import 'package:atc_offline_mobile/data/repositories/question_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selects 35 percent TSN and balances knowledge categories', () {
    final questions = <QuestionItem>[];
    var id = 1;
    for (var category = 1; category <= 4; category++) {
      for (var index = 0; index < 40; index++) {
        questions.add(_question(id++, category, true));
      }
    }
    for (var category = 5; category <= 10; category++) {
      for (var index = 0; index < 40; index++) {
        questions.add(_question(id++, category, false));
      }
    }

    expect(resolveTsnPercent(tsnAvailable: 40, otherAvailable: 100, total: 100)!.percent, 35);
    expect(resolveTsnPercent(tsnAvailable: 30, otherAvailable: 100, total: 100)!.percent, 25);
    expect(resolveTsnPercent(tsnAvailable: 18, otherAvailable: 100, total: 100)!.percent, 15);
    expect(resolveTsnPercent(tsnAvailable: 16, otherAvailable: 100, total: 100), isNull);
    expect(resolveTsnPercent(tsnAvailable: 0, otherAvailable: 100, total: 100), isNull);

    for (final entry in {20: 7, 50: 18, 100: 35}.entries) {
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

  test('falls back to lower TSN percent when pool is small but share >= 15%', () {
    final questions = <QuestionItem>[];
    var id = 1;
    for (var index = 0; index < 20; index++) {
      questions.add(_question(id++, 1, true));
    }
    for (var category = 2; category <= 5; category++) {
      for (var index = 0; index < 25; index++) {
        questions.add(_question(id++, category, false));
      }
    }
    final selected = selectBalancedMockQuestions(
      questions,
      100,
      random: Random(3),
    );
    expect(selected, hasLength(100));
    expect(selected.where(isTsnQuestion), hasLength(15));
  });

  test('low TSN share uses equal category distribution', () {
    final questions = <QuestionItem>[];
    var id = 1;
    for (var index = 0; index < 10; index++) {
      questions.add(_question(id++, 1, true));
    }
    for (var category = 2; category <= 6; category++) {
      for (var index = 0; index < 30; index++) {
        questions.add(_question(id++, category, false));
      }
    }
    expect(
      resolveTsnPercent(tsnAvailable: 10, otherAvailable: 150, total: 100),
      isNull,
    );
    final selected = selectBalancedMockQuestions(
      questions,
      100,
      subjectCode: 'APS',
      random: Random(11),
    );
    expect(selected, hasLength(100));
    expect(selected.map((item) => item.id).toSet(), hasLength(100));
  });

  test('SUP and ACS SUP subjects skip TSN ratio and balance categories', () {
    final questions = <QuestionItem>[];
    var id = 1;
    for (var category = 1; category <= 5; category++) {
      for (var index = 0; index < 25; index++) {
        questions.add(_question(id++, category, category == 1));
      }
    }
    for (final code in ['ACC HAN', 'ACS SUP HCM', 'SUP ACS HAN']) {
      final selected = selectBalancedMockQuestions(
        questions,
        20,
        subjectCode: code,
        random: Random(4),
      );
      expect(selected, hasLength(20));
      expect(usesTsnRatio(code), isFalse);
      _expectBalanced(selected);
    }
    expect(usesTsnRatio('ADC'), isTrue);
    expect(usesTsnRatio('APS'), isTrue);
    expect(usesTsnRatio('SUP'), isTrue);
  });

  test('excludes questions from recent sessions and avoids duplicates', () {
    final questions = <QuestionItem>[];
    var id = 1;
    for (var category = 1; category <= 4; category++) {
      for (var index = 0; index < 40; index++) {
        questions.add(_question(id++, category, true));
      }
    }
    for (var category = 5; category <= 10; category++) {
      for (var index = 0; index < 40; index++) {
        questions.add(_question(id++, category, false));
      }
    }
    final excluded = <int>{
      ...questions.where(isTsnQuestion).take(42).map((item) => item.id),
      ...questions
          .where((item) => !isTsnQuestion(item))
          .take(78)
          .map((item) => item.id),
    };
    final selected = selectBalancedMockQuestions(
      questions,
      20,
      excludedQuestionIds: excluded,
      random: Random(3),
    );
    final selectedIds = selected.map((item) => item.id).toList();
    expect(selectedIds.toSet().intersection(excluded), isEmpty);
    expect(selectedIds.toSet(), hasLength(selectedIds.length));
    expect(supportedMockQuestionCounts, [20, 50, 100]);
    expect(recentExamExclusionLimit, 6);
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
