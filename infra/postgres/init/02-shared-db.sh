#!/bin/sh
# First start of an empty volume: create qura_main with the client/crm schemas.
set -eu
psql -v ON_ERROR_STOP=1 -U postgres -d postgres -f /qura/shared-db.sql
