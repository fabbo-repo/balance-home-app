from django.contrib import admin
from balance.models import AnnualBalance, MonthlyBalance



@admin.register(AnnualBalance)
class AnnualBalanceAdmin(admin.ModelAdmin):
    fields = (
        'id',
        'year',
        ('gross_quantity', 'expected_quantity',),
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
        ('gross_quantity', 'expected_quantity',),
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