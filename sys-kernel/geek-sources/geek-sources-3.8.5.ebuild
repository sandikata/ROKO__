# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"
# Skip update to to latest upstream ?
SKIP_UPDATE="0" # default no

KMV="$(echo $PV | cut -f 1-2 -d .)"

ck_ver="$KMV-ck1"
#imq_ver="$KMV"
lqx_ver="3.8.5-1"
pax_ver="3.8.5-test13"
pf_ver="3.8.1-pf"
#reiser4_ver="3.7.1"
rt_ver="3.8.4-rt2"
#vserver_ver="3.7.7-vs2.3.5.6"

SUPPORTED_USES="aufs bfq branding build ck debian deblob fedora genpatches grsecurity ice lqx mageia pf pax rt suse symlink uksm zen zfs"

inherit geek-sources

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
