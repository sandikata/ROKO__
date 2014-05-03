# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


EAPI=5
PYTHON_COMPAT=( python2_{6,7} )

inherit distutils-r1 gnome2-utils versionator

MAJOR_PV="$(get_version_component_range 1-2)"

DESCRIPTION="Manually and automatically control the desktop's idle state."
HOMEPAGE="https://launchpad.net/caffeine"
SRC_URI="${HOMEPAGE}/${MAJOR_PV}/${MAJOR_PV}/+download/${PN}_${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
LANGS="ar bg bs ca cs da de el en_GB eo es eu fi fr gl he hu it ja lt ms nl no pl pt_BR pt ro ru sk sv th tr uk vi xh zh_TW"
IUSE=""

for lang in ${LANGS}; do
	IUSE+=" linguas_${lang}"
done

DEPEND="dev-python/dbus-python
	dev-python/pygobject
	dev-libs/libappindicator
	x11-apps/xprop
	x11-apps/xvinfo"
RDEPEND="${DEPEND}"

DOCS="COPYING* ICONS.INFO README VERSION"

S="${WORKDIR}/${PN}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-fix-screensaver-path.patch
}

_clean_up_locales() {
	einfo "Cleaning up locales..."
	for lang in ${LANGS}; do
		use "linguas_${lang}" && {
			einfo "- keeping ${lang}"
			continue
		}
		rm -Rf "${ED}"/usr/share/locale/"${lang}" || die
	done
}

src_install() {
	distutils-r1_src_install

	_clean_up_locales
	# Show desktop entry everywhere
	sed -i "/^OnlyShowIn/d" "${ED}"/usr/share/applications/caffeine.desktop
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
