from django.contrib import admin
from revenue.models import Revenue, RevenueType


@admin.register(RevenueType)
class RevenueTypeAdmin(admin.ModelAdmin):
    fields = (
        'name',
        'image'
    )


@admin.register(Revenue)
class RevenueAdmin(admin.ModelAdmin):
    fields = (
        'name',
        'description',
        ('real_quantity', 'converted_quantity', 'date',),
        ('coin_type', 'rev_type',),
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