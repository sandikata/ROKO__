# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


EAPI="4"

PYTHON_DEPEND="2"

inherit distutils

DESCRIPTION="Caffeine a small Python / GTK application to disable the screen saver during the selected applications."
HOMEPAGE="https://launchpad.net/caffeine"
SRC_URI="https://launchpad.net/~caffeine-developers/+archive/ppa/+files/caffeine_2.4.1%2B464~quantal1.tar.gz
         https://github.com/downloads/zaharchuktv/files/caffeine_2.4.1+464~quantal1.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
DEPEND="dev-python/python-xlib
    dev-libs/libappindicator
    dev-python/pyxdg
    dev-python/py-notify
    dev-python/kaa-metadata"
RDEPEND="${DEPEND}"

src_unpack() {

unpack ${A}
mv ${WORKDIR}/recipe-2.4.1+{revno} ${WORKDIR}/caffeine-2.4.1

}

pkg_postinst() {

cp ${FILESDIR}/caffeine-preferences.desktop /usr/share/applications
rm /usr/share/applications/caffeine.desktop
cp ${FILESDIR}/caffeine.desktop /usr/share/applications
cp ${FILESDIR}/caffeine.sh /usr/bin
glib-compile-schemas /usr/share/glib-2.0/schemas


}