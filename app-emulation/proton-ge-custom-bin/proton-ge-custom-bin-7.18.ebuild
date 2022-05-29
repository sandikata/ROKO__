# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A fancy custom distribution of Valves Proton with various patches"
HOMEPAGE="https://github.com/GloriousEggroll/proton-ge-custom"
SRC_URI="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton7-18/GE-Proton7-18.tar.gz -> ${P}.tar.gz"
_internal_name=GE-Proton7-18

LICENSE=('BSD' 'LGPL' 'zlib' 'MIT' 'MPL' 'OFL' 'Proton')
SLOT="${PV}"
KEYWORDS="~amd64"
RESTRICT="mirror strip"

RDEPEND="
	media-libs/mesa[vulkan,abi_x86_32]
	media-libs/vulkan-loader[abi_x86_32]"

QA_PREBUILT="*"
S="${WORKDIR}"
PATCHES=("${FILESDIR}/proton-ge-custom-bin-7.18-create-dosdevices.patch")

pkg_pretend() {
	einfo "I choose to not depend on many other packages to simplify the packing process, and this package indeed have a lot of bundled libraries. According to the document of upstream, it is enough to do so."
	einfo "However, practically, it is not enough to run some games, mostly because abi_x86_32 is not enabled for many media libraries. You could pull-in them all by emerge app-emulation/proton-ge-custom-meta."
}

src_install() {
	dodir "/usr/share/steam/compatibilitytools.d/${_internal_name}"
	mv "${S}/${_internal_name}/compatibilitytool.vdf" "${D}/usr/share/steam/compatibilitytools.d/${_internal_name}" || die
	sed -i "s%\"install_path\" \".\"%\"install_path\" \"/opt/proton-ge-custom/${_internal_name}\"%" "${D}/usr/share/steam/compatibilitytools.d/${_internal_name}/compatibilitytool.vdf" || die

	dodir "/opt/proton-ge-custom"
	mv "${S}/${_internal_name}" "${D}/opt/proton-ge-custom" || die
}
