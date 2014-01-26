# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"
EXTRAVERSION="-calculate"
AUFS_VER="3.x-rcN"
BFQ_VER="3.12.0-v6r2"
#BLD_VER="3.11.0"
#BLD_SRC="https://bld.googlecode.com/files/BLD-${BLD_VER}.patch"
#CJKTTY_VER="3.11"
CK_VER="3.12-ck1"
CK_SRC="http://ck.kolivas.org/patches/3.0/${KMV}/${CK_VER}/patch-${CK_VER}.lrz"
FEDORA_VER="master"
##GENTOO_VER="$KMV"
#GRSEC_VER="${PV}"
##ICE_VER="$KMV"
#LQX_VER="3.11.2-1"
#LQX_SRC="http://liquorix.net/sources/${LQX_VER}.patch.gz"
MAGEIA_VER="releases/3.12.0/1.mga4"
OPTIMIZATION_VER="1"
#PAX_VER="3.11.1-test10"
##PF_VER="3.10.0-pf"
#REISER4_VER="3.11.1"
RT_VER="3.12.6-rt9"
SUSE_VER="master"
UKSM_VER="0.1.2.2"
UKSM_NAME="uksm-${UKSM_VER}-for-v3.12"
##ZEN_VER="3.10"

#SUPPORTED_USES="aufs bfq bld brand -build cjktty ck exfat fedora gentoo grsec ice lqx mageia optimization pax pf reiser4 -rt suse symlink uksm zen zfs"
SUPPORTED_USES="aufs bfq brand -build -deblob ck exfat fedora gentoo mageia optimization pf suse symlink uksm zen zfs rt"

inherit geek-sources

HOMEPAGE="https://github.com/init6/init_6/wiki/${PN}"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
