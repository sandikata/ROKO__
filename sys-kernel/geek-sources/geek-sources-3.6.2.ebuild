# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ETYPE="sources"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"

rt_ver="${PV}-rt1"
vserver_ver="3.6-vs2.3.4.3-noxfs-nocow"
#vserver_ver="3.6-vs2.3.4.3-noxfs"

#SUPPORTED_FEATURES="aufs bfq bld branding ck deblob fbcondecor fedora grsecurity ice mageia reiser4 rt suse uksm vserver zfs"
#SUPPORTED_FEATURES="aufs bfq branding deblob fbcondecor fedora grsecurity ice mageia rt suse vserver"
SUPPORTED_FEATURES="aufs bfq branding deblob fedora mageia suse"

inherit kernel-geek

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"