from django.contrib import admin
from coin.models import CoinType


@admin.register(CoinType)
class CoinTypeAdmin(admin.ModelAdmin):
    fields = [
        'code',
        'name',
        'exchange'
    ]