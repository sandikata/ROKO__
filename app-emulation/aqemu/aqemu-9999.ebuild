# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit git-2 cmake-utils

DESCRIPTION="Graphical interface for QEMU and KVM emulators. Using Qt4."
HOMEPAGE="http://sourceforge.net/projects/aqemu"
EGIT_REPO_URI="git://aqemu.git.sourceforge.net/gitroot/aqemu/aqemu"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="kvm vnc spice"

DEPEND="${RDEPEND}"

RDEPEND="!kvm? ( app-emulation/qemu )
	kvm? ( app-emulation/qemu-kvm[spice?] )
	vnc? ( net-libs/libvncserver )
	x11-libs/qt-gui:4
	x11-libs/qt-test:4
	x11-libs/qt-xmlpatterns:4"

DOCS="AUTHORS CHANGELOG README TODO"
REQUIRED_USE="spice? ( kvm )"

src_unpack() {
	git-2_src_unpack
}

src_configure() {

	local mycmakeargs=" -DCMAKE_VERBOSE_MAKEFILE=OFF"
	if use vnc; then
		mycmakeargs+=" -DWITHOUT_EMBEDDED_DISPLAY=OFF "
	else
		mycmakeargs+=" -DWITHOUT_EMBEDDED_DISPLAY=ON "
	fi

	cmake-utils_src_configure
}
