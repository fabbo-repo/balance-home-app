from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.conf import settings
from django.utils.translation import get_language


def send_email_code(code, email, lang):
    subject = render_to_string(
        "auth/notifications/{}/email_code_subject.txt".format(lang)
    )
    body = render_to_string(
        "auth/notifications/{}/email_code_body.txt".format(lang),
        {"code": code},
    )
    send_mail(
        subject,
        body,
        settings.EMAIL_HOST_USER,
        [email],
        fail_silently=False
    )

def send_password_code(code, email, lang):
    subject = render_to_string(
        "auth/notifications/{}/password_code_subject.txt".format(lang)
    )
    body = render_to_string(
        "auth/notifications/{}/password_code_body.txt".format(lang),
        {"code": code},
    )
    send_mail(
        subject,
        body,
        settings.EMAIL_HOST_USER,
        [email],
        fail_silently=False
    )