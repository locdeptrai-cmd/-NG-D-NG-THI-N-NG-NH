import random
import unittest

from offline_exam import (
    excluded_ids_from_history,
    is_tsn_question,
    normalize_subject_history,
    resolve_tsn_percent,
    select_balanced_exam,
    tsn_target_count,
    uses_tsn_ratio,
)


class OfflineQuestionSelectionTests(unittest.TestCase):
    def setUp(self):
        self.questions = []
        question_id = 1
        for category in range(4):
            for _ in range(40):
                self.questions.append(self.question(question_id, category, True))
                question_id += 1
        for category in range(4, 10):
            for _ in range(40):
                self.questions.append(self.question(question_id, category, False))
                question_id += 1

    @staticmethod
    def question(question_id, category, is_tsn):
        return {
            "id": question_id,
            "code": f"ADC-{'TSN' if is_tsn else 'GENERAL'}-{question_id}",
            "content": f"Question {question_id}",
            "category": f"Category {category}",
            "subject": "ADC",
        }

    def test_ratio_and_balanced_categories(self):
        self.assertEqual([tsn_target_count(n) for n in (20, 50, 100)], [7, 18, 35])
        self.assertEqual(resolve_tsn_percent(40, 100, 100), (35, 35, 65))
        self.assertEqual(resolve_tsn_percent(30, 100, 100), (25, 25, 75))
        self.assertEqual(resolve_tsn_percent(16, 100, 100), (15, 15, 85))
        for total, expected_tsn in ((20, 7), (50, 18), (100, 35)):
            selected = select_balanced_exam(
                self.questions,
                total,
                subject_code="ADC",
                rng=random.Random(total),
            )
            tsn = [item for item in selected if is_tsn_question(item)]
            self.assertEqual(len(selected), total)
            self.assertEqual(len(tsn), expected_tsn)

    def test_tsn_ratio_falls_back_when_pool_is_small(self):
        small_pool = [
            item for item in self.questions if is_tsn_question(item)
        ][:20] + [
            item for item in self.questions if not is_tsn_question(item)
        ]
        selected = select_balanced_exam(
            small_pool,
            100,
            subject_code="ADC",
            rng=random.Random(3),
        )
        self.assertEqual(len(selected), 100)
        self.assertEqual(sum(1 for item in selected if is_tsn_question(item)), 15)

    def test_category_only_subjects_skip_tsn_ratio(self):
        self.assertTrue(uses_tsn_ratio("SUP"))
        for code in ("ACC HAN", "ACS SUP HCM", "SUP ACS HAN"):
            self.assertFalse(uses_tsn_ratio(code))
            selected = select_balanced_exam(
                self.questions,
                20,
                subject_code=code,
                rng=random.Random(5),
            )
            self.assertEqual(len(selected), 20)

    def test_excludes_previous_question_ids(self):
        excluded = {item["id"] for item in self.questions[:10]}
        selected = select_balanced_exam(
            self.questions,
            20,
            excluded_ids=excluded,
            subject_code="ADC",
            rng=random.Random(2),
        )
        self.assertFalse({item["id"] for item in selected} & excluded)
        self.assertEqual(len(selected), len({item["id"] for item in selected}))

    def test_history_keeps_last_six_exams(self):
        history = {
            "ADC": [
                list(range(1, 11)),
                list(range(11, 21)),
                list(range(21, 31)),
                list(range(31, 41)),
                list(range(41, 51)),
                list(range(51, 61)),
                list(range(61, 71)),
            ]
        }
        normalized = normalize_subject_history(history["ADC"])
        self.assertEqual(len(normalized), 6)
        self.assertEqual(normalized[0][0], 11)
        excluded = excluded_ids_from_history(history, "ADC")
        self.assertEqual(excluded, set(range(11, 71)))
        self.assertEqual(
            normalize_subject_history(list(range(1, 6))),
            [list(range(1, 6))],
        )


if __name__ == "__main__":
    unittest.main()
