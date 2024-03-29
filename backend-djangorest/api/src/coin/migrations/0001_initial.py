# Generated by Django 4.0.8 on 2023-01-09 09:16

from django.db import migrations, models
import uuid


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='CoinExchange',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False, verbose_name='uuid')),
                ('exchange_data', models.TextField(default='{}', verbose_name='data exhange dictionary')),
                ('created', models.DateTimeField(auto_now_add=True)),
            ],
            options={
                'verbose_name': 'Coin exchange',
                'verbose_name_plural': 'Coin exchanges',
                'ordering': ['-created'],
            },
        ),
        migrations.CreateModel(
            name='CoinType',
            fields=[
                ('code', models.CharField(max_length=4, primary_key=True, serialize=False, verbose_name='code')),
            ],
            options={
                'verbose_name': 'Coin type',
                'verbose_name_plural': 'Coin types',
                'ordering': ['code'],
            },
        ),
    ]
