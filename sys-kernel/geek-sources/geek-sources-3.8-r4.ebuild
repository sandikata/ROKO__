# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ETYPE="sources"
DEBLOB_AVAILABLE="1"

#KMV="$(echo $PV | cut -f 1-2 -d .)"

#ck_ver="$KMV-ck1"
#imq_ver="$KMV"
#reiser4_ver="3.7.1"
#rt_ver="3.6.9-rt21"
#vserver_ver="3.7.2-vs2.3.5.5"

#SUPPORTED_FEATURES="aufs bfq branding -build ck debian deblob fedora genpatches grsecurity ice imq mageia pld reiser4 suse symlink uksm zen zfs vserver"
SUPPORTED_FEATURES="aufs branding fedora -build symlink mageia"

inherit geek-sources

KEYWORDS=""

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
