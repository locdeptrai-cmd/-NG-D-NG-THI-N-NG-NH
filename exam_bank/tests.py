from pathlib import Path
from unittest.mock import patch

from django.test import TestCase
from django.urls import reverse

from .importers import (
    _parse_rating_values,
    _read_csv_records,
    _read_xlsx_records,
    _resolve_subject_targets,
    _target_subject_codes,
    classify_question_category,
)
from .models import SUBJECT_GROUPS, Attempt, Category, Exam, ExamQuestion, Question, Subject, User


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
