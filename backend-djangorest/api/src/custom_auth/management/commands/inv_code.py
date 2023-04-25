from django.core.management.base import BaseCommand
from custom_auth.models import InvitationCode


class Command(BaseCommand):
    """
    Will be executed with:
    ~~~
    python manage.py inv_code
    ~~~
    """

    help = "Run the inv_code function"

    def create_parser(self, prog_name, subcommand, **kwargs):
        parser = super().create_parser(prog_name, subcommand, **kwargs)
        self.add_base_argument(
            parser,
            "--usage",
            default=1,
            type=int,
            help=(
                "Usage for new invitation code. Default is 1."
            ),
        )
        return parser

    def handle(self, *args, **options):
        print(
            "Invitation Code: " +
            str(InvitationCode.objects.create(usage_left=options["usage"]).code) +
            "\nUsage: "+str(options["usage"])
        )
