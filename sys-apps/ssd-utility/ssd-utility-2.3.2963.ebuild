# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
MY_PN="SSDUtility"
MY_P="${MY_PN}_${PV}"

inherit eutils gnome2-utils xdg-utils

DESCRIPTION="SSD Utility is complementary management software designed to help you maintain, monitor and tune your OCZ SSD"
HOMEPAGE="https://ocz.com/us/download/ssd-utility"
SRC_URI="https://fichiers.touslesdrivers.com/55230/${MY_P}_Linux.zip"
LICENSE="all-rights-reserved"
RESTRICT="mirror"
KEYWORDS="-* ~amd64 ~x86"
SLOT="0"
IUSE="+policykit"

DEPEND=""
RDEPEND="${DEPEND}
	policykit? ( sys-auth/polkit )
	app-arch/bzip2
	>=dev-libs/libbsd-0.8.6
	sys-libs/glibc:2.2
	sys-libs/zlib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libpng
	>=x11-libs/libX11-1.6.5
	>=x11-libs/libxcb-1.11
	x11-libs/libXrender
	x11-libs/libXext
	x11-libs/libXau
	x11-libs/libXdmcp
	dev-libs/expat"

S="${WORKDIR}"/${MY_PN}

QA_PRESTRIPPED="/opt/ssd-utility/SSDUtility"

src_unpack() {
	default
	unpack "${WORKDIR}"/${MY_P}.tar.gz || die
}

src_install() {
	local inst_dir="/opt/${PN}"

	exeinto "${inst_dir}"
	use amd64 && doexe linux64/SSDUtility
	use x86 && doexe linux32/SSDUtility

	insinto /usr/share/pixmaps/
	doins "${FILESDIR}"/ssd-utility.png

	if use policykit; then
		insinto /usr/share/polkit-1/actions/
		doins "${FILESDIR}"/org.ocz.pkexec.ssdutility.policy

		make_wrapper \
			"${PN}" \
			"pkexec \"${inst_dir}/SSDUtility\""
	else
		dosym ../../opt/${PN}/SSDUtility /usr/bin/${PN}
	fi

	make_desktop_entry \
		"/usr/bin/${PN}" \
		"OCZ SSD Utility" \
		"${PN}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}
