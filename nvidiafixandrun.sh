#!/bin/bash
# Росен Александров
Directory=`$1 --info | grep "Target directory" | cut --delimiter=":" -f 2`
eval "$1 -x"
cd $Directory
sed -i  's/CFLAGS="$CFLAGS -I$SOURCES\/arch\/x86\/include"/CFLAGS="$CFLAGS -I$SOURCES\/arch\/x86\/include -I$SOURCES\/arch\/x86\/include\/generated"/' kernel/conftest.sh
shift 1
./nvidia-installer $*
cd ..
rm -rf $Directory

