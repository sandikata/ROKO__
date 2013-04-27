# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="0"

KMV="$(echo $PV | cut -f 1-2 -d .)"

#ck_ver="$KMV-ck1"
#imq_ver="$KMV"
#reiser4_ver="3.7.1"
#rt_ver="3.6.9-rt21"
#vserver_ver="3.7.7-vs2.3.5.6"

SUPPORTED_USES="bfq branding -build fedora genpatches mageia suse symlink zfs"

inherit geek-sources

#KEYWORDS="~amd64 ~x86"
KEYWORDS=""

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
