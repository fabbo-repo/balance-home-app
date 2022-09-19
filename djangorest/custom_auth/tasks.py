from celery import shared_task
from custom_auth import notifications

@shared_task
def send_email_code(code, email, lang):  
    notifications.send_email_code(code, email, lang)

@shared_task
def send_password_code(code, email, lang):   
    notifications.send_password_code(code, email, lang)