from django.db import models
from django.utils.translation import gettext_lazy as _


class FrontendVersion(models.Model):
    version = models.CharField(
        verbose_name = _('version'),
        max_length = 8, 
        primary_key = True
    )
    created = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = _('Frontend version')
        verbose_name_plural = _('Frontend versions')
        # Greater to lower date
        ordering = ['-created']
    
    def __str__(self) -> str:
        return str(self.version)