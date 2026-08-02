from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from . import api_views


urlpatterns = [
    path("health/", api_views.HealthAPIView.as_view(), name="api_health"),
    path("auth/login/", TokenObtainPairView.as_view(), name="api_login"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="api_refresh"),
    path("auth/me/", api_views.MeAPIView.as_view(), name="api_me"),
    path("subjects/", api_views.SubjectListAPIView.as_view(), name="api_subjects"),
    path("categories/", api_views.CategoryListAPIView.as_view(), name="api_categories"),
    path(
        "question-packages/",
        api_views.QuestionPackageListAPIView.as_view(),
        name="api_question_packages",
    ),
    path(
        "question-packages/<str:package_id>/",
        api_views.QuestionPackageDetailAPIView.as_view(),
        name="api_question_package_detail",
    ),
    path(
        "question-packages/<str:package_id>/download/",
        api_views.QuestionPackageDownloadAPIView.as_view(),
        name="api_question_package_download",
    ),
    path("practice/start/", api_views.PracticeStartAPIView.as_view(), name="api_practice_start"),
    path("practice/submit/", api_views.PracticeSubmitAPIView.as_view(), name="api_practice_submit"),
    path("exams/start/", api_views.ExamStartAPIView.as_view(), name="api_exam_start"),
    path(
        "exams/<int:attempt_id>/",
        api_views.ExamAttemptAPIView.as_view(),
        name="api_exam_attempt",
    ),
    path(
        "exams/<int:attempt_id>/autosave/",
        api_views.ExamAutosaveAPIView.as_view(),
        name="api_exam_autosave",
    ),
    path(
        "exams/<int:attempt_id>/submit/",
        api_views.ExamSubmitAPIView.as_view(),
        name="api_exam_submit",
    ),
    path("results/", api_views.ResultListAPIView.as_view(), name="api_results"),
    path(
        "results/<int:pk>/",
        api_views.ResultDetailAPIView.as_view(),
        name="api_result_detail",
    ),
    path("sync/", api_views.SyncAPIView.as_view(), name="api_sync"),
    path(
        "sync/changes/",
        api_views.SyncChangesAPIView.as_view(),
        name="api_sync_changes",
    ),
]
