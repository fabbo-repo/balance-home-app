from django.shortcuts import render

def not_found_view(request, exception=None):
    context = {"message": ""}
    return render(request, 'core/404.html', context)

def error_view(request, exception=None):
    context = {"message": ""}
    return render(request, 'core/500.html', context)

def permission_denied_view(request, exception=None):
    context = {"message": ""}
    return render(request, 'core/403.html', context)

def bad_request_view(request, exception=None):
    context = {"message": ""}
    return render(request, 'core/400.html', context)

def csrf_failure(request, reason=""):
    context = {"message": reason}
    return render(request, 'core/403.html', context)