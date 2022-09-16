from django.core.mail import send_mail
from django.conf import settings
from celery import shared_task
from custom_auth import notifications

@shared_task
def send_email_code(code, email):   
    notifications.send_email_code(code, email)

@shared_task
def send_password_code(code, email):   
    notifications.send_password_code(code, email)