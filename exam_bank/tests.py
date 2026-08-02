import sqlite3
import tempfile
import random
from collections import Counter
from pathlib import Path
from unittest.mock import patch

from django.core.management import call_command
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone

from .importers import (
    _parse_rating_values,
    _read_csv_records,
    _read_xlsx_records,
    _resolve_subject_targets,
    _target_subject_codes,
    classify_question_category,
)
from .models import (
    SUBJECT_GROUPS,
    Answer,
    Attempt,
    Category,
    Exam,
    ExamQuestion,
    Question,
    Subject,
    User,
)
from .question_selection import (
    is_tsn_question,
    latest_completed_question_ids,
    select_balanced_mock_questions,
    tsn_target_count,
)


class XlsxImportTests(TestCase):
    def test_unsized_worksheet_recalculates_dimension(self):
        class UnsizedWorksheet:
            max_row = None

            def calculate_dimension(self, force=False):
                self.max_row = 2
                return "A1:D2"

            def iter_rows(self, **kwargs):
                self.iter_kwargs = kwargs
                return iter(
                    [
                        ("QUESTION", "A", "B", "ANS"),
                        ("Question?", "One", "Two", "A"),
                    ]
                )

        class Workbook:
            active = UnsizedWorksheet()

            def close(self):
                pass

        with patch("openpyxl.load_workbook", return_value=Workbook()):
            records = _read_xlsx_records(Path("unsized.xlsx"), "ADC")

        self.assertEqual(len(records), 1)
        self.assertEqual(records[0]["question"], "Question?")
        self.assertEqual(Workbook.active.iter_kwargs["max_row"], 2)

    def test_rating_sup_maps_to_sup_subject_group(self):
        class Worksheet:
            max_row = 2

            def iter_rows(self, **kwargs):
                return iter(
                    [
                        ("QUESTION", "A", "B", "ANS", "rating"),
                        ("Supervisor duty?", "One", "Two", "B", "SUP"),
                    ]
                )

        class Workbook:
            active = Worksheet()

            def close(self):
                pass

        with patch("openpyxl.load_workbook", return_value=Workbook()):
            records = _read_xlsx_records(Path("gcu-mixed.xlsx"), "APS")

        self.assertEqual(len(records), 1)
        self.assertEqual(records[0]["subject_codes"], ["SUP"])
        self.assertTrue(records[0]["rating_explicit"])
        self.assertEqual(records[0]["ans"], "B")
        self.assertEqual(
            _resolve_subject_targets(Path("gcu-mixed.xlsx"), records[0]["subject_codes"], True),
            ["SUP"],
        )

    def test_multi_rating_allows_sup_overlap_with_aps_or_adc(self):
        self.assertEqual(_parse_rating_values("SUP,APS"), ["SUP", "APS"])
        self.assertEqual(_parse_rating_values("ADC/SUP"), ["ADC", "SUP"])
        self.assertEqual(
            _resolve_subject_targets(Path("mixed.xlsx"), ["SUP", "APS"], True),
            ["APS", "SUP"],
        )

        class Worksheet:
            max_row = 2

            def iter_rows(self, **kwargs):
                return iter(
                    [
                        ("QUESTION", "A", "B", "ANS", "rating"),
                        ("Shared supervisor question?", "One", "Two", "A", "SUP,ADC"),
                    ]
                )

        class Workbook:
            active = Worksheet()

            def close(self):
                pass

        with patch("openpyxl.load_workbook", return_value=Workbook()):
            records = _read_xlsx_records(Path("overlap.xlsx"), "APS")

        self.assertEqual(records[0]["subject_codes"], ["SUP", "ADC"])
        self.assertEqual(
            _resolve_subject_targets(Path("overlap.xlsx"), records[0]["subject_codes"], True),
            ["ADC", "SUP"],
        )

    def test_missing_rating_uses_fallback_and_filename_rules(self):
        class Worksheet:
            max_row = 2

            def iter_rows(self, **kwargs):
                return iter(
                    [
                        ("QUESTION", "A", "B", "ANS"),
                        ("Question without rating?", "One", "Two", "A"),
                    ]
                )

        class Workbook:
            active = Worksheet()

            def close(self):
                pass

        with patch("openpyxl.load_workbook", return_value=Workbook()):
            records = _read_xlsx_records(Path("bank.xlsx"), "ADC")

        self.assertEqual(len(records), 1)
        self.assertFalse(records[0]["rating_explicit"])
        self.assertEqual(records[0]["subject_code"], "ADC")
        # Form/default group wins when file has no rating.
        self.assertEqual(_target_subject_codes(Path("LTCS SUP questions.xlsx"), "SUP"), ["SUP"])
        self.assertEqual(_target_subject_codes(Path("LTC Q&A.xlsx"), "APS"), ["ADC", "APS"])
        self.assertIn("SUP", SUBJECT_GROUPS)

    def test_csv_rating_routes_after_classification(self):
        import tempfile

        content = (
            "Ma cau hoi,Noi dung cau hoi,A,B,C,D,Dap an dung,Chu de,rating\n"
            "Q1,What is CAVOK?,Clear,Cloudy,Rain,Fog,A,METEOLOGY,SUP\n"
        )
        with tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False, encoding="utf-8") as tmp:
            tmp.write(content)
            path = Path(tmp.name)

        try:
            records = _read_csv_records(path, "APS")
        finally:
            path.unlink(missing_ok=True)

        self.assertEqual(len(records), 1)
        self.assertEqual(records[0]["topic"], "Meteorology")
        self.assertEqual(records[0]["subject_codes"], ["SUP"])
        self.assertTrue(records[0]["rating_explicit"])

    def test_csv_questions_header_and_numeric_ans(self):
        import tempfile

        content = (
            "Loại Kiến Thức,TT,QUESTIONS,A,B,C,D,ANS,rating\n"
            ",1,What is the colour of runway centre line markings?,White,Red,Yellow,Blue,1,SUP\n"
        )
        with tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False, encoding="utf-8") as tmp:
            tmp.write(content)
            path = Path(tmp.name)

        try:
            records = _read_csv_records(path, "APS")
        finally:
            path.unlink(missing_ok=True)

        self.assertEqual(len(records), 1)
        self.assertEqual(records[0]["ans"], "A")
        self.assertEqual(records[0]["subject_codes"], ["SUP"])
        self.assertTrue(records[0]["rating_explicit"])

    def test_xlsx_numeric_option_headers_one_to_four(self):
        class Worksheet:
            max_row = 2

            def iter_rows(self, **kwargs):
                return iter(
                    [
                        ("QUESTION", "1", "2", "3", "4", "ANS", "Rating"),
                        ("Which authority?", "Prime minister", "MOT", "MOD", "MOFA", "1", "ACC HAN"),
                    ]
                )

        class Workbook:
            active = Worksheet()

            def close(self):
                pass

        with patch("openpyxl.load_workbook", return_value=Workbook()):
            records = _read_xlsx_records(Path("ACC HN.xlsx"), "APS")

        self.assertEqual(len(records), 1)
        self.assertEqual(records[0]["A"], "Prime minister")
        self.assertEqual(records[0]["ans"], "A")
        self.assertEqual(records[0]["subject_codes"], ["ACC HAN"])

    def test_rating_sup_acs_han_maps_to_dedicated_group(self):
        self.assertIn("SUP ACS HAN", SUBJECT_GROUPS)
        self.assertEqual(_parse_rating_values("SUP ACS HAN"), ["SUP ACS HAN"])
        self.assertEqual(
            _resolve_subject_targets(
                Path("NHCH KT ACC.xlsx"), ["SUP ACS HAN"], True
            ),
            ["SUP ACS HAN"],
        )

    def test_rating_acc_han_maps_to_acc_han_subject_group(self):
        import tempfile

        content = (
            "Loại Kiến Thức,TT,QUESTIONS,A,B,C,D,ANS,rating\n"
            ",1,What is area control?,One,Two,Three,Four,2,ACC HAN\n"
            ",2,Alias ACC still maps?,One,Two,Three,Four,1,ACC\n"
        )
        with tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False, encoding="utf-8") as tmp:
            tmp.write(content)
            path = Path(tmp.name)

        try:
            records = _read_csv_records(path, "APS")
        finally:
            path.unlink(missing_ok=True)

        self.assertEqual(len(records), 2)
        self.assertEqual(records[0]["ans"], "B")
        self.assertEqual(records[0]["subject_codes"], ["ACC HAN"])
        self.assertEqual(records[1]["subject_codes"], ["ACC HAN"])
        self.assertTrue(records[0]["rating_explicit"])
        self.assertIn("ACC HAN", SUBJECT_GROUPS)
        self.assertEqual(
            _resolve_subject_targets(Path("ltc-acc.xlsx"), records[0]["subject_codes"], True),
            ["ACC HAN"],
        )

    def test_classify_question_category_uses_aliases(self):
        self.assertEqual(classify_question_category("METEOLOGY", "What is CAVOK?"), "Meteorology")
        self.assertEqual(classify_question_category("", "MAYDAY distress call"), "Emergency and SAR")


class ExamAccessTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username="candidate", password="secret")
        self.other_user = User.objects.create_user(username="other", password="secret")
        self.subject = Subject.objects.create(code="ADC", name="ADC")
        category = Category.objects.create(subject=self.subject, name="General")
        self.question = Question.objects.create(
            code="ADC-TEST-1",
            content="Test question",
            subject=self.subject,
            category=category,
            status=Question.STATUS_APPROVED,
        )
        self.exam = Exam.objects.create(name="Test exam", subject=self.subject, created_by=self.user)
        ExamQuestion.objects.create(exam=self.exam, question=self.question, order=1)
        self.attempt = Attempt.objects.create(exam=self.exam, user=self.user)
        self.client.force_login(self.user)

    def test_result_redirects_until_attempt_is_submitted(self):
        response = self.client.get(reverse("exam_result", args=[self.attempt.id]))

        self.assertRedirects(response, reverse("take_exam", args=[self.attempt.id]))

    def test_submitted_attempt_can_view_result(self):
        self.attempt.status = Attempt.STATUS_SUBMITTED
        self.attempt.save(update_fields=["status"])

        response = self.client.get(reverse("exam_result", args=[self.attempt.id]))

        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Kết quả")

    def test_other_user_cannot_view_attempt(self):
        self.client.force_login(self.other_user)

        response = self.client.get(reverse("exam_result", args=[self.attempt.id]))

        self.assertEqual(response.status_code, 403)


class BalancedQuestionSelectionTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="balanced-candidate",
            password="secret",
        )
        self.subject = Subject.objects.create(code="ADC", name="ADC")
        self.tsn_categories = [
            Category.objects.create(subject=self.subject, name=f"TSN {idx}")
            for idx in range(4)
        ]
        self.other_categories = [
            Category.objects.create(subject=self.subject, name=f"Other {idx}")
            for idx in range(6)
        ]
        for category in self.tsn_categories:
            for idx in range(15):
                Question.objects.create(
                    code=f"ADC-TSN-{category.id}-{idx}",
                    content=f"Tan Son Nhat question {category.id}-{idx}",
                    subject=self.subject,
                    category=category,
                    status=Question.STATUS_APPROVED,
                )
        for category in self.other_categories:
            for idx in range(15):
                Question.objects.create(
                    code=f"ADC-GENERAL-{category.id}-{idx}",
                    content=f"General question {category.id}-{idx}",
                    subject=self.subject,
                    category=category,
                    status=Question.STATUS_APPROVED,
                )

    def test_tsn_ratio_and_categories_are_balanced_for_supported_sizes(self):
        self.assertEqual([tsn_target_count(n) for n in (10, 20, 50)], [4, 7, 18])
        for total, expected_tsn in ((10, 4), (20, 7), (50, 18)):
            selected, distribution = select_balanced_mock_questions(
                self.subject,
                total,
                rng=random.Random(total),
            )
            tsn = [question for question in selected if is_tsn_question(question)]
            other = [question for question in selected if not is_tsn_question(question)]
            self.assertEqual(len(selected), total)
            self.assertEqual(len(tsn), expected_tsn)
            self.assertEqual(distribution["tsn_question_count"], expected_tsn)
            for part in (tsn, other):
                counts = Counter(question.category_id for question in part)
                self.assertLessEqual(max(counts.values()) - min(counts.values()), 1)

    def test_next_web_exam_excludes_latest_submitted_exam(self):
        previous, _ = select_balanced_mock_questions(
            self.subject,
            10,
            rng=random.Random(1),
        )
        exam = Exam.objects.create(name="Previous", subject=self.subject)
        for order, question in enumerate(previous, start=1):
            ExamQuestion.objects.create(exam=exam, question=question, order=order)
        Attempt.objects.create(
            exam=exam,
            user=self.user,
            status=Attempt.STATUS_SUBMITTED,
            submitted_at=timezone.now(),
        )
        excluded = latest_completed_question_ids(self.user, self.subject)
        selected, distribution = select_balanced_mock_questions(
            self.subject,
            10,
            excluded_question_ids=excluded,
            rng=random.Random(2),
        )
        self.assertFalse(set(question.id for question in selected) & excluded)
        self.assertEqual(distribution["excluded_previous_questions"], 10)

        self.client.force_login(self.user)
        response = self.client.post(
            reverse("start_exam"),
            {"group_code": "ADC", "question_count": "10"},
        )
        self.assertEqual(response.status_code, 302)
        new_attempt = Attempt.objects.filter(user=self.user).latest("id")
        new_ids = set(
            new_attempt.exam.exam_questions.values_list("question_id", flat=True)
        )
        self.assertEqual(len(new_ids), 10)
        self.assertFalse(new_ids & excluded)
        self.assertEqual(new_attempt.exam.matrix_config["tsn_question_count"], 4)


class SyncExamBankFromSqliteTests(TestCase):
    def test_syncs_missing_acc_han_subject_questions(self):
        Subject.objects.create(code="ACC HAN", name="ACC HAN")

        with tempfile.NamedTemporaryFile(suffix=".sqlite3", delete=False) as tmp:
            source = Path(tmp.name)

        try:
            conn = sqlite3.connect(source)
            conn.executescript(
                """
                CREATE TABLE exam_bank_subject (
                    id INTEGER PRIMARY KEY, code TEXT, name TEXT
                );
                CREATE TABLE exam_bank_document (
                    id INTEGER PRIMARY KEY, code TEXT, title TEXT,
                    description TEXT, url TEXT
                );
                CREATE TABLE exam_bank_category (
                    id INTEGER PRIMARY KEY, name TEXT, subject_id INTEGER
                );
                CREATE TABLE exam_bank_question (
                    id INTEGER PRIMARY KEY, code TEXT, content TEXT,
                    explanation TEXT, question_type TEXT, subject_id INTEGER,
                    category_id INTEGER, difficulty TEXT, topic TEXT,
                    position_scope TEXT, status TEXT,
                    is_locked_for_official_exam INTEGER,
                    reference_document_id INTEGER
                );
                CREATE TABLE exam_bank_answer (
                    id INTEGER PRIMARY KEY, question_id INTEGER, label TEXT,
                    content TEXT, is_correct INTEGER, "order" INTEGER
                );
                INSERT INTO exam_bank_subject VALUES (1, 'ACC HAN', 'ACC HAN');
                INSERT INTO exam_bank_category VALUES (1, 'General', 1);
                INSERT INTO exam_bank_question VALUES (
                    1, 'ACC HAN-TEST-1', 'Which authority?', '', 'single', 1, 1,
                    '', '', '', 'approved', 0, NULL
                );
                INSERT INTO exam_bank_answer VALUES
                    (1, 1, 'A', 'Prime minister', 1, 1),
                    (2, 1, 'B', 'MOT', 0, 2);
                """
            )
            conn.close()

            call_command("sync_exam_bank_from_sqlite", source=str(source))

            question = Question.objects.get(code="ACC HAN-TEST-1")
            self.assertEqual(question.subject.code, "ACC HAN")
            self.assertEqual(question.status, Question.STATUS_APPROVED)
            self.assertEqual(question.answers.count(), 2)
            self.assertTrue(
                Answer.objects.filter(question=question, label="A", is_correct=True).exists()
            )
        finally:
            source.unlink(missing_ok=True)

    def test_sync_deletes_orphan_questions_not_in_source(self):
        subject = Subject.objects.create(code="SUP", name="SUP")
        category = Category.objects.create(subject=subject, name="General")
        Question.objects.create(
            code="SUP-OLD-1",
            content="Old question?",
            subject=subject,
            category=category,
            status=Question.STATUS_APPROVED,
        )

        with tempfile.NamedTemporaryFile(suffix=".sqlite3", delete=False) as tmp:
            source = Path(tmp.name)

        try:
            conn = sqlite3.connect(source)
            conn.executescript(
                """
                CREATE TABLE exam_bank_subject (
                    id INTEGER PRIMARY KEY, code TEXT, name TEXT
                );
                CREATE TABLE exam_bank_document (
                    id INTEGER PRIMARY KEY, code TEXT, title TEXT,
                    description TEXT, url TEXT
                );
                CREATE TABLE exam_bank_category (
                    id INTEGER PRIMARY KEY, name TEXT, subject_id INTEGER
                );
                CREATE TABLE exam_bank_question (
                    id INTEGER PRIMARY KEY, code TEXT, content TEXT,
                    explanation TEXT, question_type TEXT, subject_id INTEGER,
                    category_id INTEGER, difficulty TEXT, topic TEXT,
                    position_scope TEXT, status TEXT,
                    is_locked_for_official_exam INTEGER,
                    reference_document_id INTEGER
                );
                CREATE TABLE exam_bank_answer (
                    id INTEGER PRIMARY KEY, question_id INTEGER, label TEXT,
                    content TEXT, is_correct INTEGER, "order" INTEGER
                );
                INSERT INTO exam_bank_subject VALUES (1, 'SUP', 'SUP');
                INSERT INTO exam_bank_category VALUES (1, 'General', 1);
                INSERT INTO exam_bank_question VALUES (
                    1, 'SUP-NEW-1', 'New question?', '', 'single', 1, 1,
                    '', '', '', 'approved', 0, NULL
                );
                INSERT INTO exam_bank_answer VALUES
                    (1, 1, 'A', 'Yes', 1, 1),
                    (2, 1, 'B', 'No', 0, 2);
                """
            )
            conn.close()

            call_command("sync_exam_bank_from_sqlite", source=str(source))

            self.assertFalse(Question.objects.filter(code="SUP-OLD-1").exists())
            self.assertTrue(Question.objects.filter(code="SUP-NEW-1").exists())
            self.assertEqual(Question.objects.filter(subject__code="SUP").count(), 1)
        finally:
            source.unlink(missing_ok=True)
