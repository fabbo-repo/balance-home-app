from rest_framework.test import APIClient
import json
from django.urls import reverse


def get(client: APIClient, url: str, content_type="application/json"):
    return client.get(
        url,
        content_type=content_type
    )


def post(client: APIClient, url: str, data: dict, content_type="application/json"):
    return client.post(
        url,
        data=json.dumps(
            data
        ),
        content_type=content_type
    )


def put(client: APIClient, url: str, data: dict, content_type="application/json"):
    return client.put(
        url,
        data=json.dumps(
            data
        ),
        content_type=content_type
    )


def patch(client: APIClient, url: str, data: dict, content_type="application/json"):
    return client.patch(
        url,
        data=json.dumps(
            data
        ),
        content_type=content_type
    )


def patch_image(client: APIClient, url: str, data: dict):
    return client.patch(
        url,
        data=data,
    )


def delete(client: APIClient, url: str, content_type="application/json"):
    return client.delete(
        url,
        content_type=content_type
    )


def authenticate_user(client: APIClient, credentials: dict):
    jwt_obtain_url = reverse('jwt_obtain_pair')
    # Get jwt token
    response = post(client, jwt_obtain_url, credentials)
    try:
        jwt = response.data['access']
        client.credentials(HTTP_AUTHORIZATION='Bearer ' + str(jwt))
    except:
        pass
    return response


def get_access_token(client: APIClient, credentials: dict):
    jwt_obtain_url = reverse('jwt_obtain_pair')
    return post(client, jwt_obtain_url, credentials).data['access']


def get_refresh_token(client: APIClient, credentials: dict):
    jwt_obtain_url = reverse('jwt_obtain_pair')
    return post(client, jwt_obtain_url, credentials).data['refresh']


def access_token(client: APIClient, credentials: dict):
    jwt_obtain_url = reverse('jwt_obtain_pair')
    return post(client, jwt_obtain_url, credentials)


def refresh_token(client: APIClient, token: str):
    jwt_refresh_url = reverse('jwt_refresh')
    return post(client, jwt_refresh_url, {'refresh': token})
