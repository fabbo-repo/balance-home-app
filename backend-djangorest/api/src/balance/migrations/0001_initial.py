# Generated by Django 4.0.8 on 2023-01-09 09:16

import django.core.validators
from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('coin', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='AnnualBalance',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('gross_quantity', models.FloatField(default=0, verbose_name='gross quantity')),
                ('expected_quantity', models.FloatField(default=0, verbose_name='expected quantity')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now_add=True)),
                ('year', models.PositiveIntegerField(validators=[django.core.validators.MinValueValidator(1), django.core.validators.MaxValueValidator(5000)], verbose_name='year')),
            ],
            options={
                'verbose_name': 'Annual balance',
                'verbose_name_plural': 'Annual balances',
                'ordering': ['-created'],
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='MonthlyBalance',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('gross_quantity', models.FloatField(default=0, verbose_name='gross quantity')),
                ('expected_quantity', models.FloatField(default=0, verbose_name='expected quantity')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now_add=True)),
                ('year', models.PositiveIntegerField(validators=[django.core.validators.MinValueValidator(1), django.core.validators.MaxValueValidator(5000)], verbose_name='year')),
                ('month', models.PositiveIntegerField(validators=[django.core.validators.MinValueValidator(1), django.core.validators.MaxValueValidator(12)], verbose_name='month')),
                ('coin_type', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.DO_NOTHING, to='coin.cointype', verbose_name='coin type')),
            ],
            options={
                'verbose_name': 'Monthly balance',
                'verbose_name_plural': 'Monthly balances',
                'ordering': ['-created'],
                'abstract': False,
            },
        ),
    ]
