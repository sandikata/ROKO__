# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit distutils-r1 git-r3

DESCRIPTION="Get real direct links usable with tools like curl or wget for files stored in Yandex.Disk"
HOMEPAGE="https://github.com/wldhx/yadisk-direct"
LICENSE="GPL-3"

SRC_URI=""
EGIT_REPO_URI="https://github.com/wldhx/yadisk-direct"

if [[ ${PV} != *9999 ]]; then
	EGIT_COMMIT="${PV}"
	KEYWORDS="~amd64 ~x86"
fi

RESTRICT="mirror"
SLOT="0"
DEPEND=""
RDEPEND="${DEPEND}
	dev-python/requests"

pkg_postinst() {
	ewarn "While this code depends on an open Yandex's API, I heartily recommend you to not use it in anything resembling production environments"
	elog
	elog "Example: curl -L \$(yadisk-direct https://yadi.sk/i/LKkWupFjr5WzR) -o my_local_filename"
	elog "See documentation: https://github.com/wldhx/yadisk-direct#usage"
	elog
}
