# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ETYPE="sources"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"

bfq_ver="v3r4"
bld_ver="${KMV}-rc4"
ck_ver="${KMV}-ck3"
imq_ver="3.3"
#rt_ver="${PV}-rt18"
rt_ver="3.4.18-rt29"
vserver_ver="3.4.18-vs2.3.3.8"

SUPPORTED_FEATURES="aufs bfq bld branding -build ck deblob fedora genpatches grsecurity ice imq mageia pardus -pld rt suse symlink uksm vserver"

inherit kernel-geek

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
