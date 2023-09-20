# Keycloak Token Request

| name          | type   | comments                                     |
| ------------- | ------ | -------------------------------------------- |
| grant_type    | String | Values: password or refresh_token            |
| client_id     | String |                                              |
| refresh_token | String | Optional, used with refresh_token grant_type |
| username      | String | Optional, used with password grant_type      |
| password      | String | Optional, used with password grant_type      |
