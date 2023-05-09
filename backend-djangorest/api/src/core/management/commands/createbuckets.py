from django.core.management.base import BaseCommand
from django.conf import settings
import logging
from minio import Minio

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    """
    Will be executed with:
    ~~~
    python manage.py createbuckets
    ~~~
    """

    help = "Create static and media minio buckets"

    def handle(self, *args, **options):
        minio_client = Minio(
            endpoint=settings.MINIO_STORAGE_ENDPOINT,
            access_key=settings.MINIO_STORAGE_ACCESS_KEY,
            secret_key=settings.MINIO_STORAGE_SECRET_KEY,
            secure=True,
        )
        minio_client.make_bucket(settings.MINIO_STATIC_BUCKET_NAME)
        minio_client.make_bucket(settings.MINIO_MEDIA_BUCKET_NAME)