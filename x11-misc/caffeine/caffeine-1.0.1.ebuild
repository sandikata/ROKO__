# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


EAPI="4"

PYTHON_DEPEND="2"

inherit distutils

DESCRIPTION="Caffeine a small Python / GTK application to disable the screen saver during the selected applications."
HOMEPAGE="https://launchpad.net/caffeine"
SRC_URI="https://launchpad.net/~caffeine-developers/+archive/ppa/+files/caffeine_1.0.1-0ubuntu0~ppa16~jaunty.tar.gz
         https://github.com/downloads/zaharchuktv/files/caffeine_1.0.1-0ubuntu0~ppa16~jaunty.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
DEPEND="dev-python/python-xlib"
RDEPEND="${DEPEND}"

pkg_postinst() {

cp ${FILESDIR}/caffeine-preferences.desktop /usr/share/applications

}