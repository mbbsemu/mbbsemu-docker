#!/bin/bash

set -x
set -e

mkdir -p pkg/archive/mbbsemu
mv pkg/mbbsemu-* pkg/archive/mbbsemu

pushd .
cd pkg

wget -U "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)" $1
basename=`ls *.zip | sed s/\.zip$//`
unzip -d $basename *.zip
rm mbbsemu*.zip

popd

