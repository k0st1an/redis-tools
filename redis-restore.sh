#!/bin/bash

INIT_DIR=/etc/init.d
CLUSTER_DIR="/var/lib/redis"
COPY_CONF="no"
REDIS_ARCH=
OLD_IP=
NEW_IP=

function usage() {
  printf "Usage: `basename $0`\n"
  printf "\n"
  printf "  -a  path to archive witch backup are RDB files\n"
  printf "  -c  restore config\n"
  printf "  -o  old IP of cluster\n"
  printf "  -n  new IP of cluster\n"
  printf "  -h  print this message\n"
  printf "\n"
}

while getopts a:co:n:sh option
do
  case "$option" in
    a) REDIS_ARCH=$OPTARG;;
    c) COPY_CONF="yes"
    o) OLD_IP=$OPTARG;;
    n) NEW_IP=$OPTARG;;
    h) usage; exit 1;;
  esac
done

[[ ! $REDIS_ARCH ]] && usage && exit 1

TMP_DIR="`mktemp -d`"
tar zxf $REDIS_ARCH -C $TMP_DIR

for item in `ls $INIT_DIR/redis*`
do
  # command => $REDISPORT
  eval $(cat $item | grep REDISPORT | head -n 1)
  printf "== port $REDISPORT ==\n"

  mv $TMP_DIR/redis/$REDISPORT/dump.rdb /var/lib/redis/$REDISPORT/

  if [[ $OLD_IP ]] && [[ $NEW_IP ]]; then
    cat $TMP_DIR/redis/$REDISPORT/cluster.conf | sed s/$OLD_IP/$NEW_IP/ > /var/lib/redis/$REDISPORT/cluster.conf
  else
    if [[ "$COPY_CONF" = "yes" ]]; then
      cp $TMP_DIR/redis/$REDISPORT/cluster.conf /var/lib/redis/$REDISPORT/cluster.conf
    fi
  fi
done

rm -fr $TMP_DIR
