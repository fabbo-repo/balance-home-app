from django.contrib import admin
from expense.models import Expense, ExpenseType


@admin.register(ExpenseType)
class ExpenseTypeAdmin(admin.ModelAdmin):
    fields = (
        'name',
        'image'
    )


@admin.register(Expense)
class ExpenseAdmin(admin.ModelAdmin):
    fields = (
        'name',
        'description',
        ('real_quantity', 'converted_quantity', 'date',),
        ('coin_type', 'exp_type',),
        'owner',
        ('created', 'updated',),
    )
    readonly_fields = (
        'created', 'updated',
    )
    list_display = (
        'name', 
        'real_quantity',
        'converted_quantity',
        'date',
        'owner',
    )
    search_fields = ('owner',)
    ordering = ('owner','date',)