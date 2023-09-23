# API Contracts

This directory serves as a reference guide for developers working on the frontend and backend of balhom application. It ensures that both teams are aligned in terms of API integration, reducing miscommunication and enhancing productivity.


## Keyclaok

### Endpoints

* [Keycloak Token Endpoints](./endpoints/keycloak-token-endpoints.md)

### Requests

* [Keycloak Token Request](./requests/keycloak-token-request.md)

### Responses

* [Keycloak Token Response](./responses/keycloak-token-response.md)


## API

### Endpoints

* [User Endpoints](./endpoints/user-endpoints.md)

* [Balance Endpoints](./endpoints/balance-endpoints.md)

* [Verion Endpoints](./endpoints/version-endpoints.md)

### Requests

* [User Requests](./requests/user-requests.md)

* [Balance Requests](./requests/balance-requests.md)

### Responses

* [User Response](./responses/user-response.md)

* [Balance Response](./responses/balance-response.md)

* [Version Response](./responses/version-response.md)


## Error Codes

| CODE | DEFINITION                                                 | ENDPOINT                                                     |
| ---- | ---------------------------------------------------------- | ------------------------------------------------------------ |
| 1    | User not found                                             | /api/v2/user/send-verify-email , /api/v2/user/password-reset |
| 2    | Unverified email                                           | /api/v2/user/password-reset                                  |
| 3    | Cannot send verification mail                              | /api/v2/user/send-verify-email                               |
| 4    | Cannot send reset password mail                            | /api/v2/user/password-reset                                  |
| 5    | Password can only be reset 3 times a day                   | /api/v2/user/password-reset                                  |
| 6    | Email already used                                         | /api/v2/user [POST]                                          |
| 7    | Cannot create user                                         | /api/v2/user [POST]                                          |
| 8    | Cannot update user                                         | /api/v2/user [PUT]                                           |
| 9    | Cannot delete user                                         | /api/v2/user [DEL]                                           |
| 10   | Currency type has already been changed in the las 24 hours | /api/v2/user [PUT]                                           |
