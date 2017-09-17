#!/bin/bash

REDIS_CLI=`which redis-cli`
INIT_DIR=/etc/init.d
CLUSTER_DIR="/var/lib/redis"
BACKUP_DIR="/var/opt/redis"
ARCHIVE_NAME="redis-cluster-`date -u '+%Y-%m-%d-%H-%M-%S'`.tar"

[[ ! $REDIS_CLI ]] && printf "ERR: redis-cli not found" && exit 1
[[ ! -e $BACKUP_DB ]] && mkdir -p $BACKUP_DIR && chmod 0700 $BACKUP_DIR

cd `dirname $CLUSTER_DIR`

for item in `ls $INIT_DIR/redis*`
do
  # command => $REDISPORT
  eval $(cat $item | grep REDISPORT | head -n 1)
  redis-cli -p $REDISPORT save > /dev/null      # TODO: check status

  if [[ -e $ARCHIVE_NAME ]]; then
    tar rf $ARCHIVE_NAME redis/$REDISPORT/dump.rdb
    tar rf $ARCHIVE_NAME redis/$REDISPORT/cluster.conf
  else
    tar cf $ARCHIVE_NAME redis/$REDISPORT/dump.rdb
    tar rf $ARCHIVE_NAME redis/$REDISPORT/cluster.conf
  fi
done

gzip -9 $ARCHIVE_NAME
mv $ARCHIVE_NAME.gz $BACKUP_DIR
