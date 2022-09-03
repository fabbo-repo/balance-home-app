from django.contrib import admin
from balance.models import CoinType


@admin.register(CoinType)
class CoinTypeAdmin(admin.ModelAdmin):
    fields = (
        'simb',
        'name'
    )