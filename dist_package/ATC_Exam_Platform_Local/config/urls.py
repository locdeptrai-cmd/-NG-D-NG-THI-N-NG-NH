from django.contrib import admin
from django.urls import path
from exam_bank import views

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", views.home, name="home"),
    path("login/", views.login_view, name="login"),
    path("logout/", views.logout_view, name="logout"),
    path("management/", views.management_dashboard, name="management_dashboard"),
    path("start/", views.start_exam, name="start_exam"),
    path("attempt/<int:attempt_id>/", views.take_exam, name="take_exam"),
    path("attempt/<int:attempt_id>/submit/", views.submit_exam, name="submit_exam"),
    path("attempt/<int:attempt_id>/result/", views.exam_result, name="exam_result"),
]
