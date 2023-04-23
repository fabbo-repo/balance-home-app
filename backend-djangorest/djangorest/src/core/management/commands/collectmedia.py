from django.core.management.base import BaseCommand
from django.conf import settings
import os
import logging
from minio import Minio
import mimetypes

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    """
    Will be executed with:
    ~~~
    python manage.py collectmedia
    ~~~
    """
    help = "Upload default stored media files to minio bucket"

    def handle(self, *args, **options):
        minio_client = Minio(
            endpoint=settings.MINIO_STORAGE_ENDPOINT,
            access_key=settings.MINIO_STORAGE_ACCESS_KEY,
            secret_key=settings.MINIO_STORAGE_SECRET_KEY,
            secure=True
        )
        for (dirpath, _, filenames) in os.walk(settings.MEDIA_ROOT):
            for file in filenames:
                if str(file).lower().endswith(('.png', '.jpg', '.jpeg')):
                    filepath = os.path.join(dirpath, file)
                    try:
                        with open(filepath, 'rb') as image_data:
                            file_stat = os.stat(filepath)
                            minio_client.put_object(
                                bucket_name=settings.MINIO_STORAGE_MEDIA_BUCKET_NAME,
                                object_name=file,
                                data=image_data,
                                length=file_stat.st_size,
                                content_type=mimetypes.guess_type(filepath)
                            )
                    except Exception as err:
                        logger.error(str(err))
