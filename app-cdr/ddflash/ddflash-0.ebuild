# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Конзолен интерфейс с прогрес индикатор към програма "dd" за записване на boot live flash "
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="sys-apps/pv
		sys-apps/coreutils"
RDEPEND="${DEPEND}"

src_install() {
	cd "${FILESDIR}"
	dobin ddflash-final
}
