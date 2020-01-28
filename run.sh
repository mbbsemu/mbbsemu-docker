#!/bin/sh

if [ -z $1 ]; then
  echo "Usage: run.sh [module_name]"
  exit 1
fi

./MBBSEmu -M "$1" -P "/bbsv6/$1"
