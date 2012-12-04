# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ETYPE="sources"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"

ck_ver="${KMV}-ck1"
reiser4_ver="3.6.4"
OVERRIDE_reiser4_src="mirror://sourceforge/project/reiser4/reiser4-for-linux-3.x/reiser4-for-${reiser4_ver}.patch.gz"
rt_ver="3.6.7-rt18"
vserver_ver="3.6.6-vs2.3.4.3.3-donotuse"

#SUPPORTED_FEATURES="aufs bfq bld branding ck deblob fedora genpatches grsecurity ice mageia reiser4 rt suse uksm vserver zfs"
SUPPORTED_FEATURES="aufs bfq branding -build ck debian deblob fedora genpatches grsecurity ice mageia reiser4 rt suse symlink uksm vserver zfs"

inherit kernel-geek

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
