import 'package:atc_offline_mobile/data/repositories/exam_history_rotation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rotates only ADC APS SUP and ACS rating banks', () {
    expect(usesHistoryRotation('ADC'), isTrue);
    expect(usesHistoryRotation('APS'), isTrue);
    expect(usesHistoryRotation('SUP'), isTrue);
    expect(usesHistoryRotation('ACS SUP HCM'), isTrue);
    expect(usesHistoryRotation('SUP ACS HAN'), isTrue);
    expect(usesHistoryRotation('ACC HAN'), isFalse);
  });

  test('clears history when every bank question has been used', () {
    expect(
      shouldClearExamHistory(
        subjectCode: 'ADC',
        bankQuestionIds: {1, 2, 3},
        allUsedQuestionIds: {1, 2, 3},
        eligibleCount: 3,
        questionCount: 20,
      ),
      isTrue,
    );
  });

  test('clears history when exclusions leave too few eligible questions', () {
    expect(
      shouldClearExamHistory(
        subjectCode: 'APS',
        bankQuestionIds: {1, 2, 3, 4},
        allUsedQuestionIds: {1, 2},
        eligibleCount: 10,
        questionCount: 20,
      ),
      isTrue,
    );
  });

  test('keeps history while unused questions remain and pool is enough', () {
    expect(
      shouldClearExamHistory(
        subjectCode: 'SUP',
        bankQuestionIds: {1, 2, 3, 4, 5},
        allUsedQuestionIds: {1, 2},
        eligibleCount: 50,
        questionCount: 20,
      ),
      isFalse,
    );
  });

  test('does not clear ACC HAN history by rotation rule', () {
    expect(
      shouldClearExamHistory(
        subjectCode: 'ACC HAN',
        bankQuestionIds: {1, 2, 3},
        allUsedQuestionIds: {1, 2, 3},
        eligibleCount: 0,
        questionCount: 20,
      ),
      isFalse,
    );
  });
}
