#!/bin/sh

VER=$(fedpkg verrel)
ver=$(echo $VER | sed -e 's/-/ /g' | awk '{print $2}')
rev=$(echo $VER | sed -e 's/-/ /g' | awk '{print $3}')

if [ -d logs ]; then
  DIR=logs/
else
  DIR=./
fi

wget -O $DIR/build-$VER-i686.log http://kojipkgs.fedoraproject.org/packages/kernel/$ver/$rev/data/logs/i686/build.log
wget -O $DIR/build-$VER-x86-64.log http://kojipkgs.fedoraproject.org/packages/kernel/$ver/$rev/data/logs/x86_64/build.log
wget -O $DIR/build-$VER-noarch.log http://kojipkgs.fedoraproject.org/packages/kernel/$ver/$rev/data/logs/noarch/build.log

