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
        'image',
        'inv_code',
        ('last_login', 'date_joined'),
        ('is_superuser', 'is_staff',),
        ('verified', 'is_active',),
        ('code_sent', 'date_code_sent',),
        ('pass_reset', 'date_pass_reset',),
        ('annual_balance', 'monthly_balance')
    )
    readonly_fields = (
        'id', 'last_login', 'date_joined', 
        'code_sent', 'date_code_sent'
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