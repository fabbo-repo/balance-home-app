from django.core.mail import send_mail
from django.conf import settings
from celery import shared_task

@shared_task
def send_email_code(code, email):   
    send_mail(
        'Email verification',
        "Code generated for email verification: "+str(code),
        settings.EMAIL_HOST_USER,
        [email],
        fail_silently=False
    )

@shared_task
def send_password_code(code, email):   
    send_mail(
        'Change password',
        "Code generated to change password: "+str(code),
        settings.EMAIL_HOST_USER,
        [email],
        fail_silently=False
    )