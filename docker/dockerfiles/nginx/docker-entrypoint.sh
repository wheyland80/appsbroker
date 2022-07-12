#!/bin/bash
set -e

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	set -- nginx -f "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'codedeploy' -a "$(id -u)" = '0' ]; then
	exec gosu nginx "$@"
fi

exec "$@"