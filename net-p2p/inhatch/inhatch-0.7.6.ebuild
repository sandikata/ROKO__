# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils

DESCRIPTION="inhatch plugin for firefox web browser"
HOMEPAGE="http://inhatch.com/"
SRC_URI="ftp://calculate.linuxmaniac.net/pub/inhatch/inhatch-0.7.6-amd64.tar.xz"

LICENSE=""
SLOT="stable"
KEYWORDS="amd64"
IUSE=""

DEPEND=">=www-client/firefox-4.0 !!<=www-client/firefox-4.0"
RDEPEND="${DEPEND}"

src_unpack() {
unpack $A || die
}

src_install() {
cd "${WORKDIR}"
cp -R * "${D}/" || die "install failed"

elog "За да използвате приставката трябва да стартирате firefox и да отидете на
адрес http://inhatch.com/"
elog "Ако не се отварят телевизиите изпълнете следните операции: 1. 'mkdir
~/.mozilla/plugins' 2. 'cp /usr/lib64/nsbrowser/plugins/libinhatch.so
~/.mozilla/plugins' 3. 'sudo chown -R user:group ~/.mozilla/plugins'"
echo
}
