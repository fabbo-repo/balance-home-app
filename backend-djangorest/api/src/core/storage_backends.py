from storages.backends.s3boto3 import S3Boto3Storage
from django.conf import settings


class MinioStaticStorage(S3Boto3Storage):
    #location = "static"
    default_acl = "public-read"
    bucket_name = settings.MINIO_STATIC_BUCKET_NAME


class MinioMediaStorage(S3Boto3Storage):
    #location = "media"
    default_acl = "private"
    bucket_name = settings.MINIO_MEDIA_BUCKET_NAME
