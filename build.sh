#!/bin/sh

build_date=$(date "+%Y-%m-%d")
version=$(ls -1d pkg/mbbsemu-linux-x64-* | tail -1 | sed "s/pkg\/mbbsemu-linux-x64-//")

# Strip the newline off version - https://stackoverflow.com/questions/12524308/bash-strip-trailing-linebreak-from-output
version=$(printf %s "$version")

docker build \
  --build-arg BUILD_DATE="$build_date" \
  --build-arg VERSION="$version" \
  -t mbbsemu .

