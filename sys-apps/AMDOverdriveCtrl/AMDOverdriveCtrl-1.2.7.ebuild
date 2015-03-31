# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils
MY_PN="amdovdrvctrl"
PN_VER="AMDOverdriveCtrl.1.2.7.tar.bz2"
DESCRIPTION="This tool let's you control the frequency and fan settings of your AMD/ATI video card. "
HOMEPAGE="http://sourceforge.net/projects/amdovdrvctrl/"
SRC_URI="mirror://sourceforge/${MY_PN}/files/${PN_VER}"

LICENSE="GPLv2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="x11-libs/amd-adl-sdk
	>=x11-libs/wxGTK-2.8.10"
RDEPEND="${DEPEND}"

S="${WORKDIR}/AMDOverdriveCtrl"
