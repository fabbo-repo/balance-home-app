from django.contrib import admin
from balance.models import CoinType, AnnualBalance, MonthlyBalance


@admin.register(CoinType)
class CoinTypeAdmin(admin.ModelAdmin):
    fields = (
        'simb',
        'name'
    )


@admin.register(AnnualBalance)
class AnnualBalanceAdmin(admin.ModelAdmin):
    fields = (
        'id',
        'year',
        'quantity',
        'coin_type',
        'owner',
        'created',
        'updated'
    )
    readonly_fields = (
        'id',
        'created',
        'updated'
    )


@admin.register(MonthlyBalance)
class MonthlyBalanceAdmin(admin.ModelAdmin):
    fields = (
        'id',
        ('month', 'year',),
        'quantity',
        'coin_type',
        'owner',
        'created',
        'updated'
    )
    readonly_fields = (
        'id',
        'created',
        'updated'
    )