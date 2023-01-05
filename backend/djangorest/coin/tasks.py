from celery import shared_task
from coin.currency_converter_integration import update_exchange_data


@shared_task
def periodic_update_exchange_data():
    update_exchange_data()