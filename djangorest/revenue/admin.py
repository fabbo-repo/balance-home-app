from django.contrib import admin
from revenue.models import Revenue, RevenueType


@admin.register(RevenueType)
class RevenueTypeAdmin(admin.ModelAdmin):
    fields = (
        'name',
        'images'
    )


@admin.register(Revenue)
class RevenueAdmin(admin.ModelAdmin):
    fields = (
        'name',
        'description',
        ('quantity', 'date',),
        ('coin_type', 'rev_type',),
        'owner',
        ('created', 'updated',),
    )
    readonly_fields = (
        'owner', 'created', 'updated',
    )
    list_display = (
        'name', 
        'quantity',
        'date',
        'owner',
    )
    search_fields = ('owner',)
    ordering = ('owner','date',)