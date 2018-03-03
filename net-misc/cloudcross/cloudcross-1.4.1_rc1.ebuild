# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 qmake-utils

DESCRIPTION="Multi-cloud client for OneDrive, Yandex disk, Google Drive, Dropbox and Mail.ru"
HOMEPAGE="http://cloudcross.mastersoft24.ru"
SRC_URI=""

EGIT_COMMIT="v1.4.1-rc1"
EGIT_REPO_URI="https://github.com/MasterSoft24/${PN}"
RDEPEND="
		dev-qt/qtcore:5
		net-misc/curl
		"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ppc ~ppc64 ~s390 ~sh ~x86"
IUSE=""

DEPEND="${RDEPEND}
		"

src_compile() {
	eqmake5 CloudCross.pro
}

src_install() {
	emake install INSTALL_ROOT="${D}"
}
