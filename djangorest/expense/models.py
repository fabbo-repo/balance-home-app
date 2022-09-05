from django.db import models
from balance.models import Balance


class ExpenseType(models.Model):
    name = models.CharField(
        max_length=15,
        primary_key=True
    )
    image = models.ImageField(
        upload_to='expense', 
        default='core/default_image.jpg'
    )

class Expense(Balance):
    exp_type = models.ForeignKey(
        ExpenseType,
        on_delete = models.DO_NOTHING
    )

    class Meta(Balance.Meta):
        verbose_name = 'Expense'
        verbose_name_plural = 'Expenses'
    
    def __str__(self) -> str:
        return super().__str__()
