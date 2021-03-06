#!/bin/bash

[ $DEBUG ] && set -x

# read env set mongo config file
source /tmp/bin/set_config_file.sh

set -e

if [ "${1:0:1}" = '-' ]; then
	set -- mongod "$@"
fi

sleep ${PAUSE:-0}

# perpare data folders
for d in db configdb
do
  [ ! -d $DATADIR/$d ] && mkdir $DATADIR/$d && chown -R 200.200 $DATADIR/$d
done

# allow the container to be started with `--user`
if [ "$1" = 'mongod' -a "$(id -u)" = '0' ]; then
	chown -R 200.200 $DATADIR
	exec gosu 200 "$@"
fi

if [ "$1" = 'mongod' ]; then
	numa='numactl --interleave=all'
	if $numa true &> /dev/null; then
		set -- $numa "$@"
	fi
fi

exec "$@"
