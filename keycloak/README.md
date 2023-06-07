## Setup steps

1. Go to admin console and login.

2. Create a Realm named `balhom-realm`.

3. Create a Client with `balhom-api` id. Then in `Capability config`, `Client authentication` must be enabled and in `Authentication flow` section `Standard flow`, `Direct access grants` and `Service accounts roles` must be enabled.

4. Create a Client with `balhom-client` id. Then in `Capability config`, `Client authentication` must be disabled and in `Authentication flow` section only `Direct access grants` must be enabled.

5. Create `openid` client scope and add it to `balhom-client`.

6. Assign `manage-users` role (realm-management) in `Service accounts roles` tab to `balhom-api` client inside `Clients` section.

7. In `Login` tab inside `Realm settings` section enable `Email as username`, `Login with email` and `Verify email`.

7. In `Email` tab inside `Realm settings` section setup email settings.
