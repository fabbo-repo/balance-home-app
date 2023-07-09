from django.contrib import admin
from app_auth.models import InvitationCode, User
from django.contrib.auth.models import Group

# Remove Groups from admin
admin.site.unregister(Group)


@admin.register(InvitationCode)
class InvitationCodeAdmin(admin.ModelAdmin):
    list_display = (
        "code",
        "usage_left",
        "is_active",
    )
    readonly_fields = ("created", "updated")


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    fields = (
        "id",
        "image",
        "inv_code",
        "last_login",
        "date_joined",
        (
            "is_superuser",
            "is_staff",
        ),
        (
            "is_active",
            "receive_email_balance",
        ),
        "count_pass_reset",
        (
            "balance",
            "pref_currency_type",
        ),
        (
            "expected_annual_balance",
            "expected_monthly_balance",
        ),
    )
    readonly_fields = (
        "id",
        "last_login",
        "date_joined",
        "count_pass_reset",
        "balance",
    )
    list_display = (
        "last_login",
        "is_active",
    )
    list_filter = ("is_active",)
    ordering = ("last_login",)
