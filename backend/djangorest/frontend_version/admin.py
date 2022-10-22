from django.contrib import admin
from frontend_version.models import FrontendVersion

@admin.register(FrontendVersion)
class FrontendVersionAdmin(admin.ModelAdmin):
    fields = [
        'version',
        'created'
    ]
    
    # This will disable delete functionality
    def has_delete_permission(self, request, obj=None):
        return False
    