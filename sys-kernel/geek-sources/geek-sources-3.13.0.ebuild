# Copyright 2009-2014 Andrey Ovcharov <sudormrfhalt@gmail.com>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"
EXTRAVERSION="-calculate"
AUFS_VER="3.x-rcN"
BFQ_VER="3.13.0-v6r2"
BLD_VER="3.13-rc1"
# CK_VER="3.12-ck2"
# GRSEC_VER="3.0-3.12.8-201401191015" # 01/19/14 10:28
# GRSEC_SRC="http://grsecurity.net/test/grsecurity-${GRSEC_VER}.patch"
# LQX_VER="3.12.8-1"
MAGEIA_VER="releases/3.12.8/1.mga4"
PAX_VER="3.13-test1"
PAX_SRC="http://www.grsecurity.net/~paxguy1/pax-linux-${PAX_VER}.patch"
REISER4_VER="3.12.6"
# RT_VER="3.12.6-rt9"
UKSM_VER="0.1.2.2"
UKSM_NAME="uksm-${UKSM_VER}-for-v3.12"

SUPPORTED_USES="aufs bfq bld brand -build -deblob exfat fedora gentoo mageia openwrt optimization pax pf reiser4 suse symlink uksm zen zfs"

inherit geek-sources

HOMEPAGE="https://github.com/init6/init_6/wiki/${PN}"
KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
