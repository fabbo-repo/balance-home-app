from rest_framework import serializers
from frontend_version.models import FrontendVersion


class FrontendVersionSerializer(serializers.ModelSerializer):
    class Meta:
        model = FrontendVersion
        fields = [
            'version'
        ]