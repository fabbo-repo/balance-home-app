from django.apps import AppConfig


class RevenueConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'revenue'

    def ready(self):
        import revenue.signals  # noqa
