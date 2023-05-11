import logging

logger = logging.getLogger(__name__)


class HeadersLoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        logger.info(request.headers)
        response = self.get_response(request)
        logger.info(response.headers)
        return response
