import json
import random
import string
from rest_framework.test import APIClient
from rest_framework.response import Response
from keycloak_client.django_client import get_keycloak_client


def get_random_text(max_len: int) -> str:
    letters = string.ascii_lowercase
    return "".join(random.choice(letters) for i in range(max_len))


def get(client: APIClient, url: str, content_type="application/json") -> Response:
    return client.get(
        url,
        content_type=content_type
    )


def post(client: APIClient, url: str, data: dict, content_type="application/json") -> Response:
    return client.post(
        url,
        data=json.dumps(
            data
        ),
        content_type=content_type
    )


def put(client: APIClient, url: str, data: dict, content_type="application/json") -> Response:
    return client.put(
        url,
        data=json.dumps(
            data
        ),
        content_type=content_type
    )


def patch(client: APIClient, url: str, data: dict, content_type="application/json") -> Response:
    return client.patch(
        url,
        data=json.dumps(
            data
        ),
        content_type=content_type
    )


def patch_image(client: APIClient, url: str, data: dict) -> Response:
    return client.patch(
        url,
        data=data,
    )


def delete(client: APIClient, url: str, content_type="application/json") -> Response:
    return client.delete(
        url,
        content_type=content_type
    )


def authenticate_user(client: APIClient):
    keycloak_client_mock = get_keycloak_client()
    client.credentials(
        HTTP_AUTHORIZATION="Bearer " +
        keycloak_client_mock.access_token
    )
