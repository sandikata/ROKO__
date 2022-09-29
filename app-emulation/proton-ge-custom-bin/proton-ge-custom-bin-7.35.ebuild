# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_internal_name=GE-Proton${PV//./-}
DESCRIPTION="A fancy custom distribution of Valves Proton with various patches"
HOMEPAGE="https://github.com/GloriousEggroll/proton-ge-custom"
SRC_URI="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${_internal_name}/${_internal_name}.tar.gz -> ${P}.tar.gz"

LICENSE=('BSD' 'LGPL' 'zlib' 'MIT' 'MPL' 'OFL' 'Proton')
SLOT="${PV}"
KEYWORDS="~amd64"
RESTRICT="mirror strip"

RDEPEND="
	media-libs/mesa[vulkan,abi_x86_32]
	media-libs/vulkan-loader[abi_x86_32]"

QA_PREBUILT="*"
S="${WORKDIR}"

pkg_pretend() {
	einfo "To actually run some games, you may additionally need a bunch of 32bit libraries."
	einfo "Merge app-emulation/proton-ge-custom-meta to pull them in."
	einfo ""
	einfo "Some games will only run with old versions of proton-ge. You should try them by your self."
	einfo "As my experience, you could try the following versions first: the lastest, 7.24, 6.21."
}

src_install() {
	dodir "/usr/share/steam/compatibilitytools.d/${_internal_name}"
	mv "${S}/${_internal_name}/compatibilitytool.vdf" "${D}/usr/share/steam/compatibilitytools.d/${_internal_name}" || die
	sed -i "s%\"install_path\" \".\"%\"install_path\" \"/opt/proton-ge-custom/${_internal_name}\"%" "${D}/usr/share/steam/compatibilitytools.d/${_internal_name}/compatibilitytool.vdf" || die

	dodir "/opt/proton-ge-custom"
	mv "${S}/${_internal_name}" "${D}/opt/proton-ge-custom" || die
}
