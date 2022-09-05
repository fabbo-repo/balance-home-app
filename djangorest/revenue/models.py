from django.db import models
from balance.models import Balance


class RevenueType(models.Model):
    name = models.CharField(
        max_length=15,
        primary_key=True
    )
    image = models.ImageField(
        upload_to='revenue', 
        default='core/default_image.jpg'
    )

class Revenue(Balance):
    rev_type = models.ForeignKey(
        RevenueType,
        on_delete = models.DO_NOTHING
    )

    class Meta(Balance.Meta):
        verbose_name = 'Revenue'
        verbose_name_plural = 'Revenues'
    
    def __str__(self) -> str:
        return super().__str__()
