/// Subjects that restart from a clean history once the full bank is used.
const historyRotatingSubjectCodes = {
  'ADC',
  'APS',
  'SUP',
  'ACS SUP HCM',
  'SUP ACS HAN',
};

bool usesHistoryRotation(String? subjectCode) {
  final code = (subjectCode ?? '').trim().toUpperCase();
  return historyRotatingSubjectCodes.contains(code);
}

/// Clear local exam history when the bank is fully consumed, or when recent
/// exclusions leave too few questions to build the next paper.
bool shouldClearExamHistory({
  required String subjectCode,
  required Set<int> bankQuestionIds,
  required Set<int> allUsedQuestionIds,
  required int eligibleCount,
  required int questionCount,
}) {
  if (!usesHistoryRotation(subjectCode)) return false;
  if (allUsedQuestionIds.isEmpty) return false;
  if (bankQuestionIds.isNotEmpty &&
      bankQuestionIds.difference(allUsedQuestionIds).isEmpty) {
    return true;
  }
  return eligibleCount < questionCount;
}
