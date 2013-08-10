# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
DEBLOB_AVAILABLE="0"

KMV="$(echo $PV | cut -f 1-2 -d .)"
EXTRAVERSION="-calculate"
user_aufs_ver="3.x-rcN"
#user_aufs_ver="3.10"
user_bfq_ver="3.10.0-v6r2"
#user_bld_ver="3.10.0"
#user_bld_src="https://bld.googlecode.com/files/bld-${user_bld_ver}.patch"
#user_ck_ver="3.10-ck1"
#user_ck_src="http://ck.kolivas.org/patches/3.0/${KMV}/${user_ck_ver}/patch-${user_ck_ver}.lrz"
user_fedora_ver="master"
#user_gentoo_ver="$KMV"
#user_grsec_ver="${PV}"
#user_ice_ver="$KMV"
#user_lqx_ver="3.9.8-1"
#user_lqx_src="http://liquorix.net/sources/${user_lqx_ver}.patch.gz"
user_mageia_ver="releases/3.10.1/1.mga4"
#user_pax_ver="3.10.1-test2"
#user_pf_ver="3.10.0-pf"
#user_reiser4_ver="3.9.2"
user_suse_ver="master"
#user_suse_ver="stable"
#user_uksm_ver="0.1.2.2"
#user_uksm_name="uksm-${user_uksm_ver}-for-v${KMV}"
#user_zen_ver="3.10"

#SUPPORTED_USES="aufs bfq bld branding -build ck fedora gentoo grsec ice lqx mageia pax pf reiser4 suse symlink uksm zen zfs"
SUPPORTED_USES="aufs bfq branding -build fedora gentoo ice mageia suse symlink zfs"

inherit geek-sources

KEYWORDS="~amd64 ~x86"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"
