# Generated by Django 4.0.7 on 2022-10-09 12:41

import custom_auth.models
import django.contrib.auth.validators
import django.core.validators
from django.db import migrations, models
import django.db.models.deletion
import django.utils.timezone
import uuid


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('auth', '0012_alter_user_first_name_max_length'),
        ('coin', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='InvitationCode',
            fields=[
                ('code', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False, verbose_name='uuid code')),
                ('usage_left', models.PositiveIntegerField(default=1, verbose_name='usage left')),
                ('is_active', models.BooleanField(default=True, verbose_name='is active')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now_add=True)),
            ],
            options={
                'verbose_name': 'Invitation code',
                'verbose_name_plural': 'Invitation codes',
                'ordering': ['-usage_left'],
            },
        ),
        migrations.CreateModel(
            name='User',
            fields=[
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(blank=True, null=True, verbose_name='last login')),
                ('is_superuser', models.BooleanField(default=False, help_text='Designates that this user has all permissions without explicitly assigning them.', verbose_name='superuser status')),
                ('username', models.CharField(error_messages={'unique': 'A user with that username already exists.'}, help_text='Required. 150 characters or fewer. Letters, digits and @/./+/-/_ only.', max_length=150, unique=True, validators=[django.contrib.auth.validators.UnicodeUsernameValidator()], verbose_name='username')),
                ('is_staff', models.BooleanField(default=False, help_text='Designates whether the user can log into this admin site.', verbose_name='staff status')),
                ('is_active', models.BooleanField(default=True, help_text='Designates whether this user should be treated as active. Unselect this instead of deleting accounts.', verbose_name='active')),
                ('date_joined', models.DateTimeField(default=django.utils.timezone.now, verbose_name='date joined')),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('email', models.EmailField(max_length=254, unique=True, verbose_name='email address')),
                ('language', models.CharField(default='en', max_length=2, validators=[django.core.validators.MinLengthValidator(2)], verbose_name='language')),
                ('image', models.ImageField(default='users/default_user.jpg', upload_to=custom_auth.models._image_user_dir, verbose_name='profile image')),
                ('balance', models.FloatField(default=0.0, verbose_name='current balance')),
                ('receive_email_balance', models.BooleanField(default=True, verbose_name='receive email about balance')),
                ('expected_annual_balance', models.FloatField(default=0.0, validators=[django.core.validators.MinValueValidator(0.0)], verbose_name='expected annual balance')),
                ('expected_monthly_balance', models.FloatField(default=0.0, validators=[django.core.validators.MinValueValidator(0.0)], verbose_name='expected monthly balance')),
                ('verified', models.BooleanField(default=False, verbose_name='verified')),
                ('code_sent', models.CharField(blank=True, max_length=6, null=True, validators=[django.core.validators.MinLengthValidator(6)], verbose_name='last code sent')),
                ('date_code_sent', models.DateTimeField(blank=True, null=True, verbose_name='date of last code sent')),
                ('pass_reset', models.CharField(blank=True, max_length=6, null=True, validators=[django.core.validators.MinLengthValidator(6)], verbose_name='last password reset code sent')),
                ('date_pass_reset', models.DateTimeField(blank=True, null=True, verbose_name='date of last password reset code sent')),
                ('groups', models.ManyToManyField(blank=True, help_text='The groups this user belongs to. A user will get all permissions granted to each of their groups.', related_name='user_set', related_query_name='user', to='auth.group', verbose_name='groups')),
                ('inv_code', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='custom_auth.invitationcode', verbose_name='invitation code')),
                ('pref_coin_type', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='coin.cointype', verbose_name='preferred coin type')),
                ('user_permissions', models.ManyToManyField(blank=True, help_text='Specific permissions for this user.', related_name='user_set', related_query_name='user', to='auth.permission', verbose_name='user permissions')),
            ],
            options={
                'verbose_name': 'user',
                'verbose_name_plural': 'users',
                'abstract': False,
            },
            managers=[
                ('objects', custom_auth.models.BalanceUserManager()),
            ],
        ),
    ]
