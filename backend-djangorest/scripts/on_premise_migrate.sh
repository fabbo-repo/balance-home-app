#!/bin/bash

set -e

###############################
docker exec -it balhom-api-djangorest python migrate
docker exec -it balhom-api-djangorest python collectstatic --no-input
docker exec -it balhom-api-djangorest python collectmedia