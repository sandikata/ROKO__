# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# modified from ebuild available in the touchfish-os overlay

EAPI=8
MULTILIB_COMPAT=(abi_x86_{32,64})
inherit multilib-minimal

_internal_name=GE-Proton${PV/./-}
DESCRIPTION="A fancy custom distribution of Valves Proton with various patches"
HOMEPAGE="https://github.com/GloriousEggroll/proton-ge-custom"
SRC_URI="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${_internal_name}/${_internal_name}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD LGPL zlib MIT MPL OFL Proton GPL MSPL"
SLOT="${PV}"
KEYWORDS="~amd64"
RESTRICT="mirror strip"

RDEPEND="
	media-libs/mesa[vulkan,${MULTILIB_USEDEP}]
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]"

QA_PREBUILT={*}
S="${WORKDIR}"

src_install() {
	dodir "/usr/share/steam/compatibilitytools.d/${_internal_name}"
	mv "${S}/${_internal_name}/compatibilitytool.vdf" "${D}/usr/share/steam/compatibilitytools.d/${_internal_name}" || die
	sed -i "s%\"install_path\" \".\"%\"install_path\" \"/opt/proton-ge-custom/${_internal_name}\"%" "${D}/usr/share/steam/compatibilitytools.d/${_internal_name}/compatibilitytool.vdf" || die

	dodir "/opt/proton-ge-custom"
	mv "${S}/${_internal_name}" "${D}/opt/proton-ge-custom" || die
}
