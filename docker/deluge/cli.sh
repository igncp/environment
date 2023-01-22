#!/usr/bin/env bash

set -e

# Examples:
# - bash cli.sh rm --confirm TOKEN_ID
# - bash cli.sh rm --confirm --remove_data TOKEN_ID
# - bash cli.sh add 'TOKEN_URL'

docker compose exec deluge deluge-console -c /config $@
