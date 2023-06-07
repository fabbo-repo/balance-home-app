from django.apps import AppConfig
import logging


logger = logging.getLogger(__name__)


class AuthConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'custom_auth'

    def ready(self):
        try:
            # Schedule users tasks
            from custom_auth.schedule_setup import schedule_setup
            schedule_setup()

            # Initiate Invitation Code
            from custom_auth.models import InvitationCode
            if not len(InvitationCode.objects.all()):
                logger.info(
                    "Invitation Code: " +
                    str(InvitationCode.objects.create().code)
                )
        except Exception:
            pass
