import uuid
from django.contrib.auth.models import AbstractUser, UserManager
from django.db import models
from django.core.validators import MinValueValidator
from django.utils.translation import gettext_lazy as _
from coin.models import CoinType


class InvitationCode(models.Model):
    code = models.UUIDField(
        verbose_name=_("uuid code"),
        primary_key=True,
        default=uuid.uuid4,
        editable=False,
    )
    usage_left = models.PositiveIntegerField(
        verbose_name=_("usage left"), default=1)
    is_active = models.BooleanField(verbose_name=_("is active"), default=True)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = _("Invitation code")
        verbose_name_plural = _("Invitation codes")
        ordering = ["-usage_left"]

    def __str__(self) -> str:
        return str(self.code)


class BalanceUserManager(UserManager):
    def create_user(self, keycloak_id, **extra_fields):  # pylint: disable=arguments-differ
        if not keycloak_id:
            raise ValueError(_("A keycloak id must be provided")  # pylint: disable=used-before-assignment
                             )
        currency_type, _ = CoinType.objects.get_or_create(  # pylint: disable=no-member
            code="EUR"
        )
        User.objects.create(
            keycloak_id=keycloak_id,
            inv_code=InvitationCode.objects.create(  # pylint: disable=no-member
                usage_left=0,
                is_active=False
            ),
            is_staff=False,
            is_superuser=False,
            pref_currency_type=currency_type
        )

    def create_superuser(self, keycloak_id, **extra_fields):  # pylint: disable=arguments-differ
        if not keycloak_id:
            raise ValueError(_("A keycloak id must be provided")  # pylint: disable=used-before-assignment
                             )
        currency_type, _ = CoinType.objects.get_or_create(  # pylint: disable=no-member
            code="EUR"
        )
        User.objects.create(
            keycloak_id=keycloak_id,
            inv_code=InvitationCode.objects.create(  # pylint: disable=no-member
                usage_left=0,
                is_active=False
            ),
            is_staff=True,
            is_superuser=True,
            pref_currency_type=currency_type
        )


def _image_user_dir(instance, filename):
    # File will be uploaded to MEDIA_ROOT / user_<id>/<filename>
    return "user_{0}/{1}".format(instance.id, filename)


class User(AbstractUser):
    # Fields to ignore in db form default User model:
    first_name = None
    last_name = None
    password = None
    username = None
    email = None

    # Change default id to uuid will make
    # an enumeration attack more difficult
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    keycloak_id = models.TextField(
        verbose_name=_("keycloak id"),
        unique=True,
        editable=False
    )
    image = models.ImageField(
        verbose_name=_("profile image"),
        upload_to=_image_user_dir,
        default="users/default_user.jpg",
    )
    inv_code = models.ForeignKey(
        InvitationCode,
        on_delete=models.DO_NOTHING,
        verbose_name=_("invitation code"),
        blank=True,
        null=True,
    )
    balance = models.FloatField(verbose_name=_("current balance"), default=0.0)
    receive_email_balance = models.BooleanField(
        verbose_name=_("receive email about balance"), default=True
    )
    # Expected annual balance at the end of a year,
    # it is used to be subtracted with the gross balance of each year
    # and get the net balance
    expected_annual_balance = models.FloatField(
        verbose_name=_("expected annual balance"),
        validators=[MinValueValidator(0.0)],
        default=0.0,
    )
    # Expected monthly balance at the end of a month,
    # it is used to be subtracted with the gross balance of each month
    # and get the net balance
    expected_monthly_balance = models.FloatField(
        verbose_name=_("expected monthly balance"),
        validators=[MinValueValidator(0.0)],
        default=0.0,
    )
    # Date of the last password reset code sent
    date_pass_reset = models.DateTimeField(
        verbose_name=_("date of last password reset code sent"),
        blank=True,
        null=True
    )
    # Number of requests for password reset
    count_pass_reset = models.IntegerField(
        verbose_name=_("number of requests for password reset"), default=0
    )
    pref_currency_type = models.ForeignKey(
        CoinType,
        on_delete=models.DO_NOTHING,
        verbose_name=_("preferred currency type"),
        blank=True,
        null=True,
    )
    # Date of the last preferred currency type change.
    # It is stored because this action requires time and compute power
    date_currency_change = models.DateTimeField(
        verbose_name=_("date of last preferred currency type change"),
        blank=True,
        null=True,
    )

    objects = BalanceUserManager()
    USERNAME_FIELD = "keycloak_id"
    REQUIRED_FIELDS = []

    def __str__(self):
        return str(self.keycloak_id)