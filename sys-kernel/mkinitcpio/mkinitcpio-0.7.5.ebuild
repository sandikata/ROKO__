# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Modular initramfs image creation utility"
HOMEPAGE="http://www.archlinux.org/"
SRC_URI="ftp://ftp.archlinux.org/other/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="dmraid crypt lvm2 mdadm v86d lzma bzip2 nfs"

RDEPEND="
	>=sys-apps/busybox-1.16.1[static]
	sys-apps/module-init-tools
	>=sys-apps/util-linux-2.17
	sys-kernel/gen-init-cpio
	sys-apps/coreutils
	app-shells/bash
	sys-apps/findutils
	sys-apps/sed
	sys-apps/grep
	>=sys-fs/udev-150
	sys-apps/file
	app-arch/gzip
	sys-apps/which
	lzma? ( app-arch/xz-utils )
	bzip2? ( app-arch/bzip2 )
	nfs? ( sys-apps/mkinitcpio-nfs-utils )
	dmraid? ( sys-fs/dmraid[static] )
	crypt? ( sys-fs/cryptsetup[static] )
	lvm2? ( sys-fs/lvm2 )
	mdadm? ( sys-fs/mdadm[static] )
	v86d? ( sys-apps/v86d )
	"
DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die

	dodir /lib/initcpio/{hooks,install} /etc/modprobe.d
	cp /bin/busybox.static "${D}"/lib/initcpio/busybox || die
	cp "${FILESDIR}"/modprobe.d.usb-load-ehci-first \
	    "${D}"/etc/modprobe.d/usb-load-ehci-first.conf || die

	HOOKS="${D}/lib/initcpio/hooks"
	I_HOOKS="${D}/lib/initcpio/install"

	if use dmraid ; then
		cp "${FILESDIR}"/dmraid_hook "${HOOKS}"/dmraid || die
		cp "${FILESDIR}"/dmraid_install "${I_HOOKS}"/dmraid || die
	fi

	if use crypt ; then
		cp "${FILESDIR}"/encrypt_hook "${HOOKS}"/encrypt || die
		cp "${FILESDIR}"/encrypt_install "${I_HOOKS}"/encrypt || die
	fi

	if use lvm2 ; then
		cp "${FILESDIR}"/lvm2_hook "${HOOKS}"/lvm2 || die
		cp "${FILESDIR}"/lvm2_install "${I_HOOKS}"/lvm2 || die
	fi

	if use mdadm ; then
		cp "${FILESDIR}"/mdadm_hook "${HOOKS}"/mdadm || die
		ln -s "${HOOKS}"/mdadm "${HOOKS}"/raid || die
		cp "${FILESDIR}"/mdadm_install "${I_HOOKS}"/mdadm || die
	fi

	if use v86d ; then
		cp "${FILESDIR}"/v86d_hook "${HOOKS}"/v86d || die
		cp "${FILESDIR}"/v86d_install "${I_HOOKS}"/v86d || die
	fi
}
