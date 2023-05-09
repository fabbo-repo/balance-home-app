from storages.backends.s3boto3 import S3Boto3Storage
from django.conf import settings


class MediaStorage(S3Boto3Storage):
    bucket_name = settings.APP_MINIO_MEDIA_BUCKET_NAME


class StaticStorage(S3Boto3Storage):
    bucket_name = settings.APP_MINIO_STATIC_BUCKET_NAME
