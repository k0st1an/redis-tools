#!/bin/bash

INIT_DIR=/etc/init.d
STATE=
REDISPORT=

function usage() {
  printf "Usage: `basename $0` [-sSrpkh]\n"
  printf "\n"
  printf "  -s  start all/single node of cluster\n"
  printf "  -S  stop all/single node of cluster\n"
  printf "  -t  status all/single node of cluster\n"
  printf "  -r  restart all/single node of cluster\n"
  printf "  -p  specified port a Redis of cluster\n"
  printf "  -h  print this message\n"
  printf "\n"
}

while getopts sStrp:h option
do
  case "$option" in
    s) STATE="start";;
    S) STATE="stop";;
    t) STATE="status";;
    r) STATE="restart";;
    p) REDISPORT=$OPTARG;;
    h) usage; exit;;
  esac
done

[[ ! $STATE ]] && usage && exit 1

if [[ $REDISPORT ]]; then
  $INIT_DIR/redis_$REDISPORT $STATE
else
  for item in `ls $INIT_DIR/redis*`
  do
    # command => $REDISPORT
    eval $(cat $item | grep REDISPORT | head -n 1)
    printf "== port $REDISPORT ==\n"

    $INIT_DIR/redis_$REDISPORT $STATE
  done
fi
