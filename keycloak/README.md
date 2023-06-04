1- Create a Realm named "balhom-realm"
2- Create a Client with id "balhom-api". "Client authentication" must be ON and no "Authentication flow"
3- Create a Client with id "balhom-client". "Client authentication" must be OFF and in "Authentication flow" section "Standard flow", "Direct access grants" and "Service accounts roles" must be enabled 
4- Create "openid" client scope and add it to "balhom-client"
5- Assign "manage-users" role in "User registration" tab inside "Realm settings"