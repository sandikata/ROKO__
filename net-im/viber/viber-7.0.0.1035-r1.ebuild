# Copyright 2010-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit eutils unpacker

DESCRIPTION="Free calls, text and picture sharing with anyone, anywhere!"
HOMEPAGE="http://www.viber.com"
SRC_URI="
	amd64? ( http://download.cdn.viber.com/cdn/desktop/Linux/viber.deb -> ${P}.deb )
"

IUSE="+apulse"
SLOT="0"
KEYWORDS="amd64"

QA_PREBUILT="*"

RESTRICT="mirror bindist strip"
RDEPEND="apulse? ( >=media-sound/apulse-0.1.12_p20180803 )
	!apulse? ( media-sound/pulseaudio )"

S="${WORKDIR}"

src_unpack() {
	unpack_deb ${A}
}

src_install(){
	doins -r opt usr
	mv ${ED}/opt/${PN}/Viber ${ED}/opt/${PN}/${PN}-bin
	insinto opt/${PN}
	doins "${FILESDIR}/${PN}"
	fowners root:audio /opt/${PN}/${PN} /opt/${PN}/${PN}-bin
	fperms 755 /opt/${PN}/${PN} /opt/${PN}/${PN}-bin
	sed -i -e '/^Exec/s/Viber/viber/' ${ED}/usr/share/applications/viber.desktop
	fperms 755 /opt/${PN}/QtWebEngineProcess
}
