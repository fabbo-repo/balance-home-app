#!/bin/sh

set -e

# Keycloak
docker cp ./keycloakdbexport.pgsql balhom-postgres:/keycloakdbexport.pgsql
docker exec balhom-postgres sh -c "cat /keycloakdbexport.pgsql | psql -U keycloak_user keycloakdb"

# Balhom
docker cp ./balhomdbexport.pgsql balhom-postgres:/balhomdbexport.pgsql
docker exec balhom-postgres sh -c "cat /balhomdbexport.pgsql | psql -U balhom_api_user balhomdb"

# Currency
docker cp ./currencydbexport.pgsql balhom-postgres:/currencydbexport.pgsql
docker exec balhom-postgres sh -c "cat /currencydbexport.pgsql | psql -U currency_api_user currencydb"