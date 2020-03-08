#!/bin/sh

if [ -z $1 ]; then
  exec ./MBBSEmu -C "$CONFIG_PATH/modules.json"
else
  exec ./MBBSEmu -M "$1" -P "$MODULES_PATH/$1"
fi
