#!/bin/bash

set -e

###############################
echo TESTING
cd backend/djangorest/src/
pip install -r requirements.txt
python manage.py test
cd -
