import logging
from django.apps import AppConfig


logger = logging.getLogger(__name__)


class AuthConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "app_auth"

    def ready(self):
        # Schedule users tasks
        from app_auth.schedule_setup import schedule_setup  # pylint: disable=import-outside-toplevel
        schedule_setup()

        # Initiate Invitation Code
        from app_auth.models import InvitationCode  # pylint: disable=import-outside-toplevel
        if not InvitationCode.objects.all():  # pylint: disable=no-member
            logger.info(
                "Invitation Code: %s",
                str(InvitationCode.objects.create(  # pylint: disable=no-member
                ).code)
            )
