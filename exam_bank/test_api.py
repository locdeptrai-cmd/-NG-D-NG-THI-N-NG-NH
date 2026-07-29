from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase

from .models import (
    Answer,
    Category,
    Exam,
    ExamQuestion,
    PracticeAttempt,
    Question,
    Subject,
    SyncOperation,
    User,
)


class PwaApiTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="pwa-user",
            password="secret-pass",
        )
        self.subject = Subject.objects.create(code="ADC", name="Aerodrome Control")
        self.category = Category.objects.create(
            subject=self.subject,
            name="General",
        )
        self.question = Question.objects.create(
            code="ADC-PWA-001",
            content="Runway centreline colour?",
            explanation="Runway centreline markings are white.",
            subject=self.subject,
            category=self.category,
            status=Question.STATUS_APPROVED,
        )
        Answer.objects.create(
            question=self.question,
            label="A",
            content="White",
            is_correct=True,
        )
        Answer.objects.create(
            question=self.question,
            label="B",
            content="Blue",
            is_correct=False,
            order=2,
        )

    def login(self):
        response = self.client.post(
            reverse("api_login"),
            {"username": "pwa-user", "password": "secret-pass"},
            format="json",
        )
        self.assertEqual(response.status_code, 200)
        self.client.credentials(
            HTTP_AUTHORIZATION=f"Bearer {response.data['access']}"
        )
        return response

    def test_health_is_public_and_login_me_uses_jwt(self):
        health = self.client.get(reverse("api_health"))
        self.assertEqual(health.status_code, 200)
        self.assertEqual(health.data["status"], "ok")

        self.login()
        me = self.client.get(reverse("api_me"))
        self.assertEqual(me.status_code, 200)
        self.assertEqual(me.data["username"], "pwa-user")

    def test_practice_package_contains_solution_and_checksum(self):
        self.login()
        packages = self.client.get(reverse("api_question_packages"))
        self.assertEqual(packages.status_code, 200)
        package = packages.data[0]
        self.assertTrue(package["checksum"].startswith("sha256:"))

        download = self.client.get(
            reverse(
                "api_question_package_download",
                args=[package["package_id"]],
            )
        )
        self.assertEqual(download.status_code, 200)
        self.assertEqual(download.data["questions"][0]["correct_answer"], ["A"])
        self.assertIn("explanation", download.data["questions"][0])

    def test_sync_is_idempotent(self):
        self.login()
        now = timezone.now()
        body = {
            "client_id": "device-test",
            "operations": [
                {
                    "operation_id": "op-001",
                    "type": "submit_practice_attempt",
                    "payload": {
                        "local_attempt_id": "local-001",
                        "subject_id": self.subject.id,
                        "score": 100,
                        "total_questions": 1,
                        "correct_answers": 1,
                        "answers": [],
                        "started_at": now.isoformat(),
                        "completed_at": now.isoformat(),
                    },
                }
            ],
        }
        first = self.client.post(reverse("api_sync"), body, format="json")
        second = self.client.post(reverse("api_sync"), body, format="json")

        self.assertEqual(first.status_code, 200)
        self.assertFalse(first.data["results"][0]["duplicate"])
        self.assertTrue(second.data["results"][0]["duplicate"])
        self.assertEqual(PracticeAttempt.objects.count(), 1)
        self.assertEqual(SyncOperation.objects.count(), 1)

    def test_official_exam_does_not_expose_solutions(self):
        exam = Exam.objects.create(
            name="Official test",
            subject=self.subject,
            created_by=self.user,
        )
        ExamQuestion.objects.create(
            exam=exam,
            question=self.question,
            order=1,
        )
        self.login()
        response = self.client.post(
            reverse("api_exam_start"),
            {"exam_id": exam.id},
            format="json",
        )

        self.assertEqual(response.status_code, 201)
        question = response.data["questions"][0]
        self.assertNotIn("correct_answer", question)
        self.assertNotIn("explanation", question)
        self.assertNotIn("is_correct", question["answers"][0])
