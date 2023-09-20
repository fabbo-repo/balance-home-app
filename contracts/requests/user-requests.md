# User Requests

## User Creation Request

| name                     | type   | validations                           | comments |
| ------------------------ | ------ | ------------------------------------- | -------- |
| username                 | String | max-size: 15, regex: "^[A-Za-z0-9]+$" |          |
| email                    | String | format: email                         |          |
| locale                   | String | max-size: 5                           |          |
| inv_code                 | uuid   |                                       |          |
| password                 | String | format: password                      |          |
| expected_annual_balance  | double | min: 0                                | Optional |
| expected_monthly_balance | double | min: 0                                | Optional |
| pref_currency_type       | String | max-size: 3, format: currency_type    |          |

## User Update Request

| name                     | type          | validations                           | comments |
| ------------------------ | ------------- | ------------------------------------- | -------- |
| username                 | String        | max-size: 15, regex: "^[A-Za-z0-9]+$" |          |
| locale                   | String        | max-size: 5                           |          |
| receive_email_balance    | boolean       |                                       |          |
| balance                  | double        |                                       |          |
| expected_annual_balance  | double        | min: 0                                |          |
| expected_monthly_balance | double        | min: 0                                |          |
| pref_currency_type       | String        | max-size: 3, format: currency_type    |          |
| image                    | MultiPartFile |                                       |          |

## Email Request

| name  | type   | validations   | comments |
| ----- | ------ | ------------- | -------- |
| email | String | format: email |          |

## Change Password Request

| name         | type   | validations      | comments |
| ------------ | ------ | ---------------- | -------- |
| old_password | String | not-blank        |          |
| new_password | String | format: password |          |
