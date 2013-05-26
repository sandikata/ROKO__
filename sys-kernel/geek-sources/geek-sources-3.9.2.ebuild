# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="0"

KMV="$(echo $PV | cut -f 1-2 -d .)"

bld_ver="$KMV-rc4"
ck_ver="$KMV-ck1"
#imq_ver="$KMV"
#lqx_ver="3.8.13-1"
#pax_ver="3.8.11-test23"
pf_ver="3.9.1-pf"
#reiser4_ver="3.8.5"
#rt_ver="3.8.11-rt8"
#vserver_ver="3.7.7-vs2.3.5.6"

SUPPORTED_USES="aufs bfq bld branding -build ck debian fedora genpatches ice mageia pf suse symlink uksm zfs"

inherit geek-sources

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
