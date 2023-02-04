from django.shortcuts import render


def not_found_view(request, exception=None):
    context = {"message": ""}
    return render(request, 'core/404.html', context, status=404)


def error_view(request, exception=None):
    context = {"message": ""}
    return render(request, 'core/500.html', context, status=500)


def permission_denied_view(request, exception=None):
    context = {"message": ""}
    return render(request, 'core/403.html', context, status=403)


def bad_request_view(request, exception=None):
    context = {"message": ""}
    return render(request, 'core/400.html', context, status=400)


def csrf_failure(request, reason=""):
    context = {"message": reason}
    return render(request, 'core/403.html', context, status=403)
