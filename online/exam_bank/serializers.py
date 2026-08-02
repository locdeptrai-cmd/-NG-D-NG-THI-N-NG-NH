from rest_framework import serializers

from .models import Category, PracticeAttempt, Subject, User


class UserSerializer(serializers.ModelSerializer):
    role = serializers.CharField(source="role.code", allow_null=True)

    class Meta:
        model = User
        fields = (
            "id",
            "username",
            "first_name",
            "last_name",
            "email",
            "role",
            "is_staff",
        )


class SubjectSerializer(serializers.ModelSerializer):
    question_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = Subject
        fields = ("id", "code", "name", "question_count")


class CategorySerializer(serializers.ModelSerializer):
    subject_code = serializers.CharField(source="subject.code", read_only=True)

    class Meta:
        model = Category
        fields = ("id", "name", "subject", "subject_code")


class PracticeAttemptInputSerializer(serializers.Serializer):
    local_attempt_id = serializers.CharField(max_length=100)
    client_id = serializers.CharField(max_length=100, required=False, allow_blank=True)
    subject_id = serializers.IntegerField(min_value=1)
    score = serializers.DecimalField(max_digits=5, decimal_places=2, min_value=0, max_value=100)
    total_questions = serializers.IntegerField(min_value=1, max_value=500)
    correct_answers = serializers.IntegerField(min_value=0)
    answers = serializers.ListField(child=serializers.DictField(), required=False)
    started_at = serializers.DateTimeField()
    completed_at = serializers.DateTimeField()

    def validate(self, attrs):
        if attrs["completed_at"] < attrs["started_at"]:
            raise serializers.ValidationError(
                {"completed_at": "Thời điểm hoàn thành phải sau thời điểm bắt đầu."}
            )
        if attrs["correct_answers"] > attrs["total_questions"]:
            raise serializers.ValidationError(
                {"correct_answers": "Số câu đúng không được lớn hơn tổng số câu."}
            )
        return attrs


class PracticeAttemptSerializer(serializers.ModelSerializer):
    subject_code = serializers.CharField(source="subject.code", read_only=True)

    class Meta:
        model = PracticeAttempt
        fields = (
            "id",
            "local_attempt_id",
            "client_id",
            "subject",
            "subject_code",
            "started_at",
            "completed_at",
            "score",
            "total_questions",
            "correct_answers",
            "answers",
            "created_at",
        )
