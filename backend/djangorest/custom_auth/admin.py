from django.contrib import admin
from custom_auth.models import InvitationCode, User
from django.contrib.auth.models import Group

# Remove Groups from admin
admin.site.unregister(Group)

@admin.register(InvitationCode)
class InvitationCodeAdmin(admin.ModelAdmin):
    list_display = (
        'code', 
        'usage_left',
        'is_active',
    )
    readonly_fields = ('created', 'updated')

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    fields = (
        'id',
        'username', 
        'email',
        'language',
        'image',
        'inv_code',
        'last_login', 
        'date_joined',
        ('is_superuser', 'is_staff',),
        ('verified', 'is_active', 'receive_email_balance',),
        'code_sent',
        'date_code_sent',
        'pass_reset', 
        'date_pass_reset',
        'count_pass_reset',
        ('balance', 'pref_coin_type',),
        ('expected_annual_balance', 'expected_monthly_balance',),
    )
    readonly_fields = (
        'id', 'last_login', 'date_joined', 'email', 
        'code_sent', 'date_code_sent', 'pass_reset', 
        'date_pass_reset', 'count_pass_reset', 'balance',
    )
    list_display = (
        'email', 
        'username',
        'last_login',
        'is_active',
        'verified',
        'code_sent',
        'date_code_sent',
    )
    list_filter = ('is_active',)
    search_fields = ('email', 'username',)
    ordering = ('last_login','date_code_sent',)