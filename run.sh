#!/bin/sh

if [ -z $1 ]; then
  exec ./MBBSEmu -C "$EMULATOR_PATH/appsettings.json"
else
  exec ./MBBSEmu -M "$1" -P "$MODULES_PATH/$1"
fi
