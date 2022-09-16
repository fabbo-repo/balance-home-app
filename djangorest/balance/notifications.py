from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.conf import settings

MONTHS={
    1: "January", 2: "February", 3: "March", 4: "April", 5:"May", 
    6: "June", 7: "July", 8: "August", 9: "September", 
    10: "October", 11: "November", 12: "December"
}

def send_monthly_balance(email, month, year, 
    monthly_balance, expected_monthly_balance, montly_result):
    
    subject = render_to_string(
        "balance/notifications/monthly_balance_subject.txt"
    )
    body = render_to_string(
        "balance/notifications/monthly_balance_body.txt",
        {
            "month": MONTHS[month],
            "year": str(year),
            "monthly_balance": str(monthly_balance),
            "expected_monthly_balance": str(expected_monthly_balance),
            "montly_result": str(montly_result)
        },
    )
    send_mail(
        subject,
        body,
        settings.EMAIL_HOST_USER,
        [email],
        fail_silently=False
    )


def send_annual_balance(email, year, 
    annual_balance, expected_annual_balance, annual_result):
    
    subject = render_to_string(
        "balance/notifications/annual_balance_subject.txt"
    )
    body = render_to_string(
        "balance/notifications/annual_balance_body.txt",
        {
            "year": str(year),
            "annual_balance": str(annual_balance),
            "expected_annual_balance": str(expected_annual_balance),
            "annual_result": str(annual_result)
        },
    )
    send_mail(
        subject,
        body,
        settings.EMAIL_HOST_USER,
        [email],
        fail_silently=False
    )