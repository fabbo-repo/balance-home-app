## Setup steps

1. Go to admin console and login.

2. Create a Realm named `balhom-realm`.

3. Create a Client with `balhom-api` id. Then in `Capability config`, `Client authentication` must be enabled and in `Authentication flow` section only `Service accounts roles` must be selected.

4. Create a Client with `balhom-client` id. Then in `Capability config`, `Client authentication` must be disabled and in `Authentication flow` section `Standard flow`, `Direct access grants` and `Service accounts roles` must be enabled.

5. Create `openid` client scope and add it to `balhom-client`.

6. Assign `manage-users` role (realm-management) in `Service accounts roles` tab to `balhom-api` client inside `Clients` section.