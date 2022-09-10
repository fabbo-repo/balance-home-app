import uuid
from django.contrib.auth.models import AbstractUser, UserManager
from django.db import models
from django.utils.translation import gettext_lazy as _
from django.core.validators import MinValueValidator, MinLengthValidator
from django.core.exceptions import ValidationError


class InvitationCode(models.Model):
    code = models.UUIDField(
        primary_key=True, 
        default=uuid.uuid4,
        editable=False
    )
    usage_left = models.PositiveIntegerField(default=1)
    is_active = models.BooleanField(default=True)
    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'InvitationCode'
        verbose_name_plural = 'InvitationCodes'
    
    def __str__(self) -> str:
        return str(self.code)


class BalanceUserManager(UserManager):

    def create_user(self, username, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        if not email:
            raise ValueError(_("The given email must be set."))
        if not username:
            raise ValueError(_("The given username must be set."))
        return self._create_user(username, email, password, **extra_fields)

    def create_superuser(self, username, email, password, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError(_("Superuser must have is_staff=True."))
        if extra_fields.get("is_superuser") is not True:
            raise ValueError(_("Superuser must have is_superuser=True."))

        if not email:
            raise ValueError(_("The given email must be set."))
        if not username:
            raise ValueError(_("The given username must be set."))
        return self._create_user(username, email, password, **extra_fields)


def _image_user_dir(instance, filename):
    # File will be uploaded to MEDIA_ROOT / user_<id>/<filename>
    return 'user_{0}/{1}'.format(instance.id, filename)

class User(AbstractUser):
    # Fields to iggnore in db form default User model:
    first_name = None
    last_name = None

    # Change default id to uuid will make 
    # an enumeration attack more difficult
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(
        _("email address"),
        unique=True,
    )
    # Profile image
    image = models.ImageField(
        upload_to=_image_user_dir, 
        default='users/default_user.jpg'
    )
    inv_code = models.ForeignKey(
        InvitationCode, on_delete=models.DO_NOTHING,
        blank=True,
        null=True
    )
    balance = models.FloatField(default=0.0)
    receive_email_balance = models.BooleanField(
        default=True
    )
    # Expected annual balance at the end of a year, 
    # it is used to be subtracted with the gross balance of each year
    # and get the net balance
    expected_annual_balance = models.FloatField(
        validators=[MinValueValidator(0.0)],
        default=0.0
    )
    last_annual_balance = models.FloatField(default=0.0)
    # Expected monthly balance at the end of a month, 
    # it is used to be subtracted with the gross balance of each month
    # and get the net balance
    expected_monthly_balance = models.FloatField(
        validators=[MinValueValidator(0.0)],
        default=0.0
    )
    last_monthly_balance = models.FloatField(default=0.0)
    # Field corresponding to email verification
    verified = models.BooleanField(
        default=False
    )
    # Last code sent for email verification, 
    # length is 6 characters 
    code_sent = models.CharField(
        validators=[MinLengthValidator(6)],
        max_length=6,
        blank=True,
        null=True
    )
    # Date of the last email verification code sent
    date_code_sent = models.DateTimeField(
        blank=True,
        null=True
    )
    # Last code sent for password reset, 
    # length is 6 characters 
    pass_reset = models.CharField(
        validators=[MinLengthValidator(6)],
        max_length=6,
        blank=True,
        null=True
    )
    # Date of the last password reset code sent
    date_pass_reset = models.DateTimeField(
        blank=True,
        null=True
    )

    objects = BalanceUserManager()
    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = [ "username" ]
    
    def __str__(self):
        return self.email

    def clean(self):
        if self.username == self.password or self.email == self.password:
            raise ValidationError(
                {'password': "Password field can not match another attribute."})
