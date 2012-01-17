#! /bin/sh

# combine a set of quilt patches

# $1 : base dir (source tree)
# $2 : quilt dir (patches to apply)
# $3 : pre-patch to apply first (optional)

# e.g.:
# combine.sh /home/user/fedora/trunk/kernel/F-11/kernel-2.6.30/vanilla-2.6.30 \
#            /home/user/git/stable-queue/queue-2.6.30 \
#            /home/user/fedora/trunk/kernel/F-11/patch-2.6.30.5.bz2

if [ $# -lt 2 ] ; then
  exit 1
fi

TD="combine_temp.d"

cd $1 || exit 1
cd ..
[ -d $TD ] && rm -Rf $TD
mkdir $TD || exit 1
cd $TD

cp -al ../$(basename $1) work.d
cd work.d
[ "$3" ] && bzcat $3 | patch -p1 -s
ln -s $2 patches
[ -h patches ] || exit 1
quilt snapshot
quilt upgrade
quilt push -a -q
quilt diff --snapshot >../combined.patch
