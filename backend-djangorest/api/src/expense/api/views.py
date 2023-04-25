from rest_framework import viewsets
from balance.utils import (
    check_dates_and_update_date_balances, 
    update_or_create_annual_balance, 
    update_or_create_monthly_balance
)
from expense.models import Expense, ExpenseType
from expense.api.serializers import (
    ExpenseTypeSerializer,
    ExpensePostPutDelSerializer,
    ExpenseListDetailSerializer
)
from core.permissions import IsCurrentVerifiedUser
from rest_framework.permissions import IsAuthenticated
from expense.api.filters import ExpenseFilterSet
from rest_framework import generics
from coin.currency_converter_integration import convert_or_fetch
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from django.views.decorators.vary import vary_on_headers
from rest_framework.views import APIView
from rest_framework import generics
from rest_framework.response import Response
from datetime import date
from django.db import transaction


class ExpenseTypeRetrieveView(generics.RetrieveAPIView):
    queryset = ExpenseType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = ExpenseTypeSerializer
    
    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(ExpenseTypeRetrieveView, self).get(request, *args, **kwargs)

class ExpenseTypeListView(generics.ListAPIView):
    queryset = ExpenseType.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = ExpenseTypeSerializer
    
    @method_decorator(cache_page(12 * 60 * 60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, *args, **kwargs):
        """
        This view will be cached for 12 hours
        """
        return super(ExpenseTypeListView, self).get(request, *args, **kwargs)


class ExpenseView(viewsets.ModelViewSet):
    queryset = Expense.objects.all()
    permission_classes = (IsCurrentVerifiedUser,)
    filterset_class = ExpenseFilterSet

    def get_queryset(self):
        """
        Filter objects by owner
        """
        if getattr(self, 'swagger_fake_view', False):
            return Expense.objects.none()  # return empty queryset
        return Expense.objects.filter(owner=self.request.user)
    
    def get_serializer_class(self):
        if self.request.method == 'GET':
            return ExpenseListDetailSerializer
        return ExpensePostPutDelSerializer

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

class EspenseYearsRetrieveView(APIView):
    permission_classes = (IsCurrentVerifiedUser,)
    
    @method_decorator(cache_page(60))
    @method_decorator(vary_on_headers("Authorization"))
    def get(self, request, format=None):
        """
        This view will be cached for 1 minute
        """
        expenses = list(Expense.objects.all())
        if expenses:
            return Response(
                data={"years": list(set([
                    exp.date.year for exp in expenses
                ]))},
            )
        return Response(
            data={"years": [date.today().year]},
        )
