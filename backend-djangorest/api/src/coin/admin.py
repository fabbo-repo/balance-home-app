from django.contrib import admin
from coin.models import CurrencyExchange, CoinType


@admin.register(CoinType)
class CoinTypeAdmin(admin.ModelAdmin):
    fields = [
        "code"
    ]
    
    # This will help disbale add functionality
    def has_add_permission(self, request):
        return False

    # This will disable delete functionality
    def has_delete_permission(self, request, obj=None):
        return False
    

@admin.register(CurrencyExchange)
class CoinExchangeAdmin(admin.ModelAdmin):
    fields = [
        "exchange_data",
        "created"
    ]
    readonly_fields = [
        "created"
    ]
    
    # This will help disbale add functionality
    def has_add_permission(self, request):
        return False
    