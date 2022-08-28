from django.contrib import admin
from custom_auth.models import User
from django.contrib.auth.models import Group

# Remove Groups from admin
admin.site.unregister(Group)

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    fields = (
        'username', 
        'email',
        'image',
        ('last_login', 'date_joined'),
        ('is_superuser', 'is_staff',),
        ('verified', 'is_active',),
        ('code_sent', 'date_code_sent',),
        ('annual_balance', 'monthly_balance')
    )
    list_display = (
        'email', 
        'username',
        'last_login',
        'is_active',
        'code_sent',
        'date_code_sent',
    )
    list_filter = ('is_active',)
    search_fields = ('email', 'username',)
    ordering = ('last_login','date_code_sent',)