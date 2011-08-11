# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit mono eutils

MY_PN=gsysinfo
DESCRIPTION="A simple program to display computer and system information"
HOMEPAGE="http://sysinfo.r8.org"
SRC_URI="mirror://sourceforge/${MY_PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug nvidia"

MONODEPS=">=dev-lang/mono-1.1.17
	 >=dev-dotnet/gtk-sharp-2.8
	 >=dev-dotnet/glade-sharp-2.8
	 >=dev-dotnet/gconf-sharp-2.8"

RDEPEND="${MONODEPS}
	 sys-apps/pciutils
	 nvidia?
	 (
	 	x11-drivers/nvidia-drivers
	 	media-video/nvidia-settings
	 )"

DEPEND="${MONODEPS}
	dev-util/pkgconfig"

src_compile() {
	econf $(use_enable debug ) || die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc NEWS README
}
