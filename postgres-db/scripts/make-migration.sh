#!/bin/sh

set -e

# Keycloak
docker exec balhom-postgres pg_dump -U keycloak_user keycloakdb > keycloakdbexport.pgsql

# Balhom
docker exec balhom-postgres pg_dump -U balhom_api_user balhomdb > balhomdbexport.pgsql

# Currency
docker exec balhom-postgres pg_dump -U currency_api_user currencydb > currencydbexport.pgsql
