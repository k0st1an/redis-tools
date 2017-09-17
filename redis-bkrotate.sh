#!/bin/bash

[[ `whoami` != "root" ]] && printf "ERR: run script as root\n" && exit 1

BACKUP_DIR="/var/opt/redis"
OLD_BACKUPS="+7"

function usage() {
  printf "Usage: `basename $0` [-odh]\n"
  printf "\n"
  printf "  -o  how old backups to delete (default: $OLD_BACKUPS)\n"
  printf "  -d  directory where stored backups (default: $BACKUP_DIR)\n"
  printf "  -h  print this message\n"
  printf "\n"
}

while getopts o:d:h option
do
  case "$option" in
    o) OLD_BACKUPS=$OPTARG;;
    d) BACKUP_DIR=$OPTARG;;
    h) usage; exit;;
  esac
done

cd $BACKUP_DIR
find ./ -type f -name redis-cluster* -delete
