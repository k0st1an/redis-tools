#!/bin/bash

REDIS_HOST="localhost"
REDIS_STR_PORT=7000
REDIS_NODES=32
UNIT="mb"
MEMORY_INFO=

usage() {
  echo "Usage: `basename $0` [-pnuh]"
  echo
  echo " -p <int>  start port of cluster (default: $REDIS_STR_PORT)"
  echo " -H <str>  redis host (default: $REDIS_HOST)"
  echo " -n <int>  total nodes (default: $REDIS_NODES)"
  echo " -u <int>  unit (default: $UNIT (support: b/kb/mb/gb))"
  echo " -h        print this message"
  echo
}

while getopts p:n:u:h option
do
  case "$option" in
    p ) REDIS_STR_PORT=$OPTARG;;
    H ) REDIS_HOST=$OPTARG;;
    n ) REDIS_NODES=$OPTARG;;
    u ) UNIT=$OPTARG;;
    h ) usage; exit;;
  esac
done

case "$UNIT" in
  b ) UNIT=0;;
  kb ) UNIT=1;;
  mb ) UNIT=2;;
  gb ) UNIT=3;;
  * ) echo "ERROR: unit (-u) not support. Exit." && UNIT="mb" && usage && exit 1;;
esac

[[ ! $REDIS_HOST ]] && echo "ERROR: redis host not defined (-H)" && usage && exit 1
[[ ! $REDIS_STR_PORT ]] && echo "ERROR: start port not defined (-p)" && usage && exit 1
[[ ! $REDIS_NODES ]] && echo "ERROR: count nodes not defined (-n)" && usage && exit 1

for (( i = 0; i < $REDIS_NODES; i++ )); do
  let "port_node=$REDIS_STR_PORT + $i"
  memory=`redis-cli -h $REDIS_HOST -p $port_node info memory | grep used_memory: | cut -d: -f2 | tr -d '\r'`

  let "used_memory = $used_memory + $memory"
done

let "total_used_memory = $used_memory / 1024**$UNIT"

echo $total_used_memory
