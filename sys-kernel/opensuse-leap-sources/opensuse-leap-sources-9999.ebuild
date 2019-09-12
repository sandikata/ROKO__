# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit git-r3 kernel-2
DESCRIPTION="OpenSUSE Leap Kernel Sources"
HOMEPAGE="https://www.opensuse.org/"
EGIT_REPO_URI="https://github.com/openSUSE/kernel"
EGIT_BRANCH="stable"

LICENSE=""
SLOT="5.2.13"
KEYWORDS="~amd64"
IUSE=""

DEPEND="sys-devel/bc"
RDEPEND="${DEPEND}"
BDEPEND=""

pkg_postinst() {
	kernel-2_pkg_postinst
        einfo "For more info on this patchset, and how to report problems, see:"
        einfo "${HOMEPAGE}"
}

pkg_setup(){
	ewarn
        ewarn "${PN} is *not* supported by the Gentoo Kernel Project in any way."
        ewarn "If you need support, please contact the Liquorix developers directly."
        ewarn "Do *not* open bugs in Gentoo's bugzilla unless you have issues with"
        ewarn "the ebuilds. Thank you."
        ewarn
        kernel-2_pkg_setup
}

pkg_postrm() {
	kernel-2_pkg_postrm
}

