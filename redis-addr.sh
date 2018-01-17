#!/bin/bash

REDIS_CLS_DIR="/var/lib/redis"
REDIS_STR_PORT=7000
REDIS_NODES=32
BACKUP="yes"
OLD_IP=
NEW_IP=

usage() {
  echo "Usage: `basename $0` [-dpnONrh]"
  echo
  echo "  -d <str>    directory claster (default: $REDIS_CLS_DIR)"
  echo "  -p <int>    start port of cluster (default: $REDIS_STR_PORT)"
  echo "  -n <int>    total nodes (default: $REDIS_NODES)"
  echo "  -O <str>    old IP of cluster"
  echo "  -N <str>    new IP of cluster"
  echo "  -r          not create backup are configs (default: false)"
  echo "  -h          print this message"
  echo
  echo "  Example:"
  echo "    ./redis-addr.sh -O 1.2.3.4 -N 1.2.3.5"
  echo
}

while getopts d:p:n:O:N:rh option
do
  case "$option" in
    d ) REDIS_CLS_DIR=$OPTARG;;
    p ) REDIS_STR_PORT=$OPTARG;;
    n ) REDIS_NODES=$OPTARG;;
    O ) OLD_IP=$OPTARG;;
    N ) NEW_IP=$OPTARG;;
    r ) BACKUP="no";;
    h ) usage; exit;;
    * ) echo "ERROR: unknown argument. Exit." && usage; exit;;
  esac
done

[[ ! $REDIS_STR_PORT ]] && echo "ERROR: start port not defined (-p)" && usage && exit 1
[[ ! $REDIS_NODES ]] && echo "ERROR: count nodes not defined (-n)" && usage && exit 1
[[ ! $OLD_IP ]] || [[ ! $NEW_IP ]] && echo "ERROR: IPs not defined (-O/-N). Exit." && usage && exit 1

for (( i = 0; i < $REDIS_NODES; i++ )); do
  let "port_node=$REDIS_STR_PORT + $i"
  echo "node $port_node"

  if [[ $BACKUP = "yes" ]]; then
    # Linux: 1515745858.840766875. MacOS: 1515745858.
    ext=`date +%s.%N`
    echo "  backup config $REDIS_CLS_DIR/$port_node/cluster.conf to $REDIS_CLS_DIR/$port_node/cluster.conf.$ext"
    cp $REDIS_CLS_DIR/$port_node/cluster.conf $REDIS_CLS_DIR/$port_node/cluster.conf.$ext
  fi

  echo "  update IP in config $REDIS_CLS_DIR/$port_node/cluster.conf"
  cat $REDIS_CLS_DIR/$port_node/cluster.conf | sed s/$OLD_IP/$NEW_IP/ > $REDIS_CLS_DIR/$port_node/cluster.conf.new
  mv $REDIS_CLS_DIR/$port_node/cluster.conf.new $REDIS_CLS_DIR/$port_node/cluster.conf
done
