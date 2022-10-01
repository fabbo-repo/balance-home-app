from django.contrib import admin
from coin.models import CoinExchange, CoinType


@admin.register(CoinType)
class CoinTypeAdmin(admin.ModelAdmin):
    fields = [
        'code',
        'name'
    ]
    
    # This will help disbale add functionality
    def has_add_permission(self, request):
        return False

    # This will disable delete functionality
    def has_delete_permission(self, request, obj=None):
        return False
    

@admin.register(CoinExchange)
class CoinExchangeAdmin(admin.ModelAdmin):
    fields = [
        'exchange',
        'created'
    ]
    readonly_fields = [
        'created'
    ]
    
    # This will help disbale add functionality
    def has_add_permission(self, request):
        return False
    