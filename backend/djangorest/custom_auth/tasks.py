import logging
from celery import shared_task
from custom_auth import notifications
from custom_auth.models import User

logger = logging.getLogger(__name__)

@shared_task
def send_email_code(code, email, lang):
    notifications.send_email_code(code, email, lang)

@shared_task
def send_password_code(code, email, lang):   
    notifications.send_password_code(code, email, lang)

@shared_task
def remove_unverified_users():
    try:
        for user in User.objects.all():
            if not user.verified:
                user.delete()
    except Exception as e:
        logger.error("[DEL UNVERIFIED USER TASK] "+str(e))