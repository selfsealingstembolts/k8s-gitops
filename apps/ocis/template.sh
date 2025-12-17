#!/bin/bash

NAME=''
IMAGE=''
TAG=''
PORT=''
NAMESPACE=''


# Set variables from flags
while getopts ":n:i:t:p:N:" flag; do
  case "$flag" in
    n)
      NAME="$OPTARG"
      ;;
    i)
      IMAGE="$OPTARG"
      ;;
    t)
      TAG="$OPTARG"
      ;;
    p)
      PORT="$OPTARG"
      ;;
    N)
      NAMESPACE="$OPTARG"
      ;;
    ?)
      echo "script usage: template.sh [-n name] [-i image] [-t tag] [-p port] [-N namespace]" >&2
      exit 1
      ;;
  esac
done


# Substitute values
sed -i "s/%NAME%/$NAME/g" base/*.yaml
sed -i "s/%NAME%/$NAME/g" clusters/*/*.yaml

sed -i "s/%IMAGE%/$IMAGE/g" base/*.yaml
sed -i "s/%IMAGE%/$IMAGE/g" clusters/*/*.yaml

sed -i "s/%TAG%/$TAG/g" base/*.yaml
sed -i "s/%TAG%/$TAG/g" clusters/*/*.yaml

sed -i "s/%PORT%/$PORT/g" base/*.yaml
sed -i "s/%PORT%/$PORT/g" clusters/*/*.yaml

sed -i "s/%NAMESPACE%/$NAMESPACE/g" base/*.yaml
sed -i "s/%NAMESPACE%/$NAMESPACE/g" clusters/*/*.yaml
