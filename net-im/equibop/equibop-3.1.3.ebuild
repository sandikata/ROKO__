EAPI=8

inherit desktop

DESCRIPTION="Equibop is a fork of Vesktop."
HOMEPAGE="https://github.com/Equicord/Equibop"
SRC_URI="https://github.com/Equicord/Equibop/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT=network-sandbox

BDEPEND="net-libs/nodejs[npm]"

S="${WORKDIR}/Equibop-${PV}"

src_compile() {
	npm run build
}

src_install() {
	insinto /opt/equibop
	doins -r dist/linux-unpacked
	newicon static/icon.png equibop.png

	fperms +x /opt/equibop/linux-unpacked/equibop

	make_desktop_entry /opt/equibop/linux-unpacked/equibop Equibop
	dosym /opt/equibop/linux-unpacked/equibop /usr/bin/equibop
}
