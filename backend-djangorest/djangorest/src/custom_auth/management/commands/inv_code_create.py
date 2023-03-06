from django.core.management.base import BaseCommand
from custom_auth.models import InvitationCode


class Command(BaseCommand):
    """
    Will be executed with:
    ~~~
    python manage.py inv_code_create
    ~~~
    """

    help = "Run the inv_code_create function"

    def create_parser(self, prog_name, subcommand, **kwargs):
        parser = super().create_parser(prog_name, subcommand, **kwargs)
        self.add_base_argument(
            parser,
            "--init",
            action="store_true",
            help="Create an invitation code with 1 usage (usage arg is ignored). "
            "It will only be created when there is no other invitation code stored.",
        )
        self.add_base_argument(
            parser,
            "--usage",
            default=1,
            type=int,
            help=(
                "Usage for new invitation code creation. Default is 1."
            ),
        )
        return parser

    def init_inv_code(self):
        if not len(InvitationCode.objects.all()):
            print(
                "Invitation Code: " +
                str(InvitationCode.objects.create().code)
            )

    def handle(self, *args, **options):
        if options["init"]:
            self.init_inv_code()
        else:
            print(
                "Invitation Code: " +
                str(InvitationCode.objects.create(usage_left=options["usage"]).code) +
                "\nUsage: "+str(options["usage"])
            )
