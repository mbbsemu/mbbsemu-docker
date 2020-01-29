#!/bin/sh

if [ -z $1 ]; then
  exec /bin/bash
else
  exec ./MBBSEmu -M "$1" -P "/bbsv6/$1"
fi
