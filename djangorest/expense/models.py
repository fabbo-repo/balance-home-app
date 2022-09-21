from django.db import models
from balance.models import Balance
from django.utils.translation import gettext_lazy as _


class ExpenseType(models.Model):
    name = models.CharField(
        verbose_name = _('name'),
        max_length = 15,
        primary_key = True
    )
    image = models.ImageField(
        verbose_name = _('image'),
        upload_to = 'expense', 
        default = 'core/default_image.jpg'
    )

class Expense(Balance):
    exp_type = models.ForeignKey(
        ExpenseType,
        verbose_name = _('expense type'),
        on_delete = models.DO_NOTHING
    )

    class Meta(Balance.Meta):
        verbose_name = _('Expense')
        verbose_name_plural = _('Expenses')
    
    def __str__(self) -> str:
        return super().__str__()
