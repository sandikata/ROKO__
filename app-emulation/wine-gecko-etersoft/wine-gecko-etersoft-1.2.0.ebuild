# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# : $
inherit rpm
MY_R=eter1gentoo
MY_ARCH=x86_64
DESCRIPTION="Wine Gecko etersoft разработка."
HOMEPAGE=http://wiki.winehq.org/Gecko

#BASE_URI=ftp://updates.etersoft.ru/pub/Etersoft/Wine-public/1.3.16/Gentoo/2009
BASE_URI=ftp://updates.etersoft.ru/pub/Etersoft/Wine-public/1.3.27/sources/Gentoo/2009
SRC_URI="$BASE_URI/wine-gecko-1.2.0-eter1gentoo.src.rpm "
LICENSE=MPL
SLOT="0"
KEYWORDS="-* amd64"

src_unpack() {
	rpm_src_unpack ${A}
}

src_install() {
cp -pR * "${D}"
}
