#!/bin/sh

if [ -z $1 ]; then
  exec /bin/bash
else
  exec ./MBBSEmu -M "$1" -P "$MODULES_PATH/$1"
fi
