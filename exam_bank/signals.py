from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import AuditLog, Question, QuestionVersion


@receiver(post_save, sender=Question)
def snapshot_question_version(sender, instance: Question, created, **kwargs):
    latest = instance.versions.order_by("-version_number").first()
    next_version = 1 if latest is None else latest.version_number + 1
    QuestionVersion.objects.create(
        question=instance,
        version_number=next_version,
        snapshot_content=instance.content,
        snapshot_explanation=instance.explanation,
        changed_by=instance.updated_by or instance.created_by,
        change_note="create" if created else "update",
    )
    AuditLog.objects.create(
        actor=instance.updated_by or instance.created_by,
        target_table="questions",
        target_id=str(instance.id),
        action="create" if created else "update",
        changes={
            "status": instance.status,
            "difficulty": instance.difficulty,
            "topic": instance.topic,
        },
    )
