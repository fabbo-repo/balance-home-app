# Keyclaok Endpints

## Keyclaok Access

| Path                                                | Method | Res Status | Res Body                | Res Cookie | Req Param | Req Body               | Comments      |
| --------------------------------------------------- | ------ | ---------- | ----------------------- | ---------- | --------- | ---------------------- | ------------- |
| /realms/balhom-realm/protocol/openid-connect/token  | POST   | 200        | keycloak-token-response | -          | -         | keycloak-token-request | Access or Refresh Token  |
| /realms/balhom-realm/protocol/openid-connect/logout | POST   | 204        | -                       | -          | -         | keycloak-token-request | Logout        |

### Headers:

#### Access

* Accept-Encoding: application/json
* Content-Type: application/x-www-form-urlencoded

#### Refresh

* Accept-Encoding: application/json
* Content-Type: application/x-www-form-urlencoded

#### Logout

* Accept-Encoding: application/json
* Content-Type: application/x-www-form-urlencoded
* Authorization: Bearer <resfresh_token>