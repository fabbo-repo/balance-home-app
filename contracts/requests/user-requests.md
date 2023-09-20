# User Requests

| name          | type   | validations | comments |
| ------------- | ------ | ----------- | -------- |
| grant_type    | String |             |          |
| client_id     | String |             |          |
| refresh_token | String |             |          |
| username      | String |             |          |
| password      | String |             |          |

## Email Request

| name  | type   | validations   | comments |
| ----- | ------ | ------------- | -------- |
| email | String | format: email |          |

## Change Password Request

| name         | type   | validations      | comments |
| ------------ | ------ | ---------------- | -------- |
| old_password | String | not-blank        |          |
| new_password | String | format: password |          |
