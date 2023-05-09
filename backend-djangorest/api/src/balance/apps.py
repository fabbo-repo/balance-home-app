from django.apps import AppConfig
import logging
import os


logger = logging.getLogger(__name__)


class BalanceConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "balance"

    def ready(self):
        from django.conf import settings

        try:
            # Schedule balance tasks
            from balance.schedule_setup import schedule_setup

            schedule_setup()

            # Create default Revenue Type models
            from revenue.models import RevenueType

            revenue_path = os.path.join(settings.MEDIA_ROOT, "revenue")
            if not os.path.exists(revenue_path):
                return
            for rev_icon in os.listdir(revenue_path):
                if rev_icon.endswith((".png", ".jpg", ".jpeg")) and "icon" in rev_icon:
                    RevenueType.objects.update_or_create(
                        name=rev_icon.split("_icon")[0], image="revenue/" + rev_icon
                    )

            # Create default Expense Type models
            from expense.models import ExpenseType

            expense_path = os.path.join(settings.MEDIA_ROOT, "expense")
            if not os.path.exists(expense_path):
                return
            for exp_icon in os.listdir(expense_path):
                if exp_icon.endswith((".png", ".jpg", ".jpeg")) and "icon" in exp_icon:
                    ExpenseType.objects.update_or_create(
                        name=exp_icon.split("_icon")[0], image="expense/" + exp_icon
                    )
        except Exception:
            pass
