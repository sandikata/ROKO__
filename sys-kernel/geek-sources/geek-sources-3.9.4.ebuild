# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="1"

KMV="$(echo $PV | cut -f 1-2 -d .)"
EXTRAVERSION="-calculate"

#user_aufs_ver="$KMV"
user_bfq_ver="3.9.0-v6r1"
user_bld_ver="${KMV}-rc4"
user_ck_ver="${KMV}-ck1"
#user_fedora_ver="f19"
#user_gentoo_ver="$KMV"
user_grsec_ver="${PV}"
#user_ice_ver="$KMV"
user_mageia_ver="current"
user_pf_ver="3.9.3-pf"
user_pax_ver="3.9.2-test6"
#user_suse_ver="stable"
user_uksm_ver="0.1.2.2"
user_uksm_name="uksm-${user_uksm_ver}-for-v${KMV}.ge.1"

SUPPORTED_USES="aufs bfq bld branding -build ck fedora gentoo grsec ice mageia pf pax suse symlink uksm zfs"

inherit geek-sources

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
