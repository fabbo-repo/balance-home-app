from rest_framework import viewsets
from revenue.models import Revenue, RevenueType
from revenue.api.serializers import (
    RevenueTypeSerializer,
    RevenuePostPutDelSerializer,
    RevenueListDetailSerializer
)
from core.permissions import IsCurrentVerifiedUser
from rest_framework.permissions import IsAuthenticated
from revenue.api.filters import RevenueFilterSet
from rest_framework import generics
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from rest_framework.views import APIView
from rest_framework import generics
from rest_framework.response import Response
from datetime import date
from django.db import transaction


class RevenueTypeRetrieveView(generics.RetrieveAPIView):
    queryset = RevenueType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = RevenueTypeSerializer

    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(RevenueTypeRetrieveView, self).get(request, *args, **kwargs)


class RevenueTypeListView(generics.ListAPIView):
    queryset = RevenueType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = RevenueTypeSerializer

    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(RevenueTypeListView, self).get(request, *args, **kwargs)


class RevenueView(viewsets.ModelViewSet):
    queryset = Revenue.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    filterset_class = RevenueFilterSet

    def get_queryset(self):
        """
        Filter objects by owner
        """
        if getattr(self, 'swagger_fake_view', False):
            return Revenue.objects.none()  # return empty queryset
        return Revenue.objects.filter(owner=self.request.user)

    def get_serializer_class(self):
        if self.request.method == 'GET':
            return RevenueListDetailSerializer
        return RevenuePostPutDelSerializer

    def perform_create(self, serializer):
        owner = self.request.user
        with transaction.atomic():
            # Inject owner data to the serializer
            serializer.save(owner=owner)

    def perform_update(self, serializer):
        with transaction.atomic():
            serializer.save()

    def perform_destroy(self, instance):
        with transaction.atomic():
            instance.delete()


class RevenueYearsRetrieveView(APIView):
    permission_classes = (IsCurrentVerifiedUser,)

    @method_decorator(cache_page(60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, format=None):
        """
        This view will be cached for 1 minute
        """
        revenues = list(Revenue.objects.all())
        if revenues:
            return Response(
                data={"years": list(set([
                    rev.date.year for rev in revenues
                ]))},
            )
        return Response(
            data={"years": [date.today().year]},
        )
