# User Endpints

| Path                           | Method | Res Status | Res Body      | Res Cookie | Req Param | Req Body      | Comments                          |
| ------------------------------ | ------ | ---------- | ------------- | ---------- | --------- | ------------- | --------------------------------- |
| /api/v2/user                   | POST   | 201        | user-response | -          | -         | user-request  |                                   |
| /api/v2/user/profile           | GET    | 200        | user-response | -          | -         | -             | Get current authenticated user    |
| /api/v2/user/profile           | PATCH  | 204        | -             | -          | -         | user-request  |                                   |
| /api/v2/user/profile           | DEL    | 204        | -             | -          | -         | -             | Delete current authenticated user |
| /api/v2/user/send-verify-email | POST   | 204        | -             | -          | -         | email-request | Send email verification mail      |
| /api/v2/user/password-reset    | POST   | 204        | -             | -          | -         | email-request | Send mail to reset user password  |
