from django.apps import AppConfig


class CoinConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "coin"

    def ready(self):
        from django.conf import settings
        try:
            # Schedule coin tasks
            from coin.schedule_setup import schedule_setup
            schedule_setup()

            # Create Coin models
            from coin.currency_converter_integration import update_exchange_data
            from coin.models import CoinType
            for coin_type_code in settings.COIN_TYPE_CODES:
                CoinType.objects.update_or_create(
                    code=coin_type_code
                )
            update_exchange_data()
        except Exception:
            pass
