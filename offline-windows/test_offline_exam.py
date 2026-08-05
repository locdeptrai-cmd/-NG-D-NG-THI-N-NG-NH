import random
import unittest

from offline_exam import (
    excluded_ids_from_history,
    is_tsn_question,
    normalize_subject_history,
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

    def test_sup_skips_tsn_ratio(self):
        self.assertFalse(uses_tsn_ratio("SUP"))
        selected = select_balanced_exam(
            self.questions,
            20,
            subject_code="SUP",
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
