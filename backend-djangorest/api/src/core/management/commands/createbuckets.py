from django.core.management.base import BaseCommand
from django.conf import settings
import logging
from minio import Minio
import json

logger = logging.getLogger(__name__)


class Command(BaseCommand):
    """
    Will be executed with:
    ~~~
    python manage.py createbuckets
    ~~~
    """

    help = "Create static and media minio buckets"

    public_read_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {"AWS": "*"},
                "Action": ["s3:GetBucketLocation", "s3:ListBucket"],
                "Resource": "arn:aws:s3:::{}".format(
                    settings.MINIO_STATIC_BUCKET_NAME
                ),
            },
            {
                "Effect": "Allow",
                "Principal": {"AWS": "*"},
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::{}/*".format(
                    settings.MINIO_STATIC_BUCKET_NAME
                ),
            },
        ],
    }

    def handle(self, *args, **options):
        minio_client = Minio(
            endpoint=settings.MINIO_STORAGE_ENDPOINT,
            access_key=settings.MINIO_STORAGE_ACCESS_KEY,
            secret_key=settings.MINIO_STORAGE_SECRET_KEY,
            secure=settings.USE_HTTPS,
        )
        minio_client.make_bucket(settings.MINIO_STATIC_BUCKET_NAME)
        minio_client.set_bucket_policy(
            settings.MINIO_STATIC_BUCKET_NAME, json.dumps(self.public_read_policy)
        )
        minio_client.make_bucket(settings.MINIO_MEDIA_BUCKET_NAME)
        print("Buckets succesfully created")
