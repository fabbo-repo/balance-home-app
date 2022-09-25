from django.db import models
from balance.models import Balance
from django.utils.translation import gettext_lazy as _


class RevenueType(models.Model):
    name = models.CharField(
        verbose_name = _('name'),
        max_length = 15,
        primary_key = True
    )
    image = models.ImageField(
        verbose_name = _('image'),
        upload_to = 'revenue', 
        default = 'core/default_image.jpg'
    )

    class Meta:
        verbose_name = _('Revenue type')
        verbose_name_plural = _('Revenue types')
        ordering = ['name']
    
    def __str__(self) -> str:
        return self.name

class Revenue(Balance):
    rev_type = models.ForeignKey(
        RevenueType,
        verbose_name = _('revenue type'),
        on_delete = models.DO_NOTHING
    )

    class Meta(Balance.Meta):
        verbose_name = _('Revenue')
        verbose_name_plural = _('Revenues')
    
    def __str__(self) -> str:
        return super().__str__()
