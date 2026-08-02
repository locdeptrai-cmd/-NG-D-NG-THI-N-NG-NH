import random
import unittest

from offline_exam import is_tsn_question, select_balanced_exam, tsn_target_count


class OfflineQuestionSelectionTests(unittest.TestCase):
    def setUp(self):
        self.questions = []
        question_id = 1
        for category in range(4):
            for _ in range(15):
                self.questions.append(self.question(question_id, category, True))
                question_id += 1
        for category in range(4, 10):
            for _ in range(15):
                self.questions.append(self.question(question_id, category, False))
                question_id += 1

    @staticmethod
    def question(question_id, category, is_tsn):
        return {
            "id": question_id,
            "code": f"ADC-{'TSN' if is_tsn else 'GENERAL'}-{question_id}",
            "content": f"Question {question_id}",
            "category": f"Category {category}",
        }

    def test_ratio_and_balanced_categories(self):
        self.assertEqual([tsn_target_count(n) for n in (10, 20, 50)], [4, 7, 18])
        for total, expected_tsn in ((10, 4), (20, 7), (50, 18)):
            selected = select_balanced_exam(
                self.questions,
                total,
                rng=random.Random(total),
            )
            tsn = [item for item in selected if is_tsn_question(item)]
            self.assertEqual(len(selected), total)
            self.assertEqual(len(tsn), expected_tsn)

    def test_excludes_previous_question_ids(self):
        excluded = {item["id"] for item in self.questions[:10]}
        selected = select_balanced_exam(
            self.questions,
            20,
            excluded_ids=excluded,
            rng=random.Random(2),
        )
        self.assertFalse({item["id"] for item in selected} & excluded)


if __name__ == "__main__":
    unittest.main()
