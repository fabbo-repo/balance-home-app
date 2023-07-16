from django.shortcuts import render, redirect
from django.contrib.staticfiles.storage import staticfiles_storage
from rest_framework import status


def not_found_view(request, exception=None):  # pylint: disable=unused-argument
    context = {"message": ""}
    return render(request, "core/404.html", context, status=status.HTTP_404_NOT_FOUND)


def error_view(request, exception=None):  # pylint: disable=unused-argument
    context = {"message": ""}
    return render(request, "core/500.html", context, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


def permission_denied_view(request, exception=None):  # pylint: disable=unused-argument
    context = {"message": ""}
    return render(request, "core/403.html", context, status=status.HTTP_403_FORBIDDEN)


def bad_request_view(request, exception=None):  # pylint: disable=unused-argument
    context = {"message": ""}
    return render(request, "core/400.html", context, status=status.HTTP_400_BAD_REQUEST)


def csrf_failure(request, reason=""):  # pylint: disable=unused-argument
    return render(request, "core/403.html", status=status.HTTP_403_FORBIDDEN)


def favicon_view(request):  # pylint: disable=unused-argument
    return redirect(to=staticfiles_storage.url("favicon.ico"))
