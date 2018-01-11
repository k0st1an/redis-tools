#!/bin/bash

REDIS_HOST="localhost"
REDIS_STR_PORT=7000
REDIS_NODES=32
CMD=

usage() {
  echo "Usage: `basename $0` [-cpnh]"
  echo
  echo " -c <cmd>  command"
  echo " -p <int>  start port of cluster (default: $REDIS_STR_PORT)"
  echo " -H <str>  redis host (default: $REDIS_HOST)"
  echo " -n <int>  total nodes (default: $REDIS_NODES)"
  echo " -h        print this message"
  echo
  echo "Example:"
  echo "  ./redis-cmd.sh -c 'config set save \"900 1 300 10 60 10000\"'"
  echo "  ./redis-cmd.sh -p 7011 -n 1 -c 'config set save \"900 1 300 10 60 10000\"'"
  echo
}

while getopts p:H:n:c:h option
do
  case $option in
    p ) REDIS_STR_PORT=$OPTARG;;
    H ) REDIS_HOST=$OPTARG;;
    n ) REDIS_NODES=$OPTARG;;
    c ) CMD=$OPTARG;;
    h ) usage; exit;;
  esac
done

[[ ! $REDIS_HOST ]] && echo "ERROR: redis host not defined (-H)" && usage && exit 1
[[ ! $REDIS_STR_PORT ]] && echo "ERROR: start port not defined (-p)" && usage && exit 1
[[ ! $REDIS_NODES ]] && echo "ERROR: count nodes not defined (-n)" && usage && exit 1

for (( i = 0; i < $REDIS_NODES; i++ )); do
  let "port_node=$REDIS_STR_PORT + $i"

  bash -c "redis-cli -h $REDIS_HOST -p $port_node $CMD"
done
