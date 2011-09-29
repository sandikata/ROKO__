# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ETYPE="sources"
EAPI=3
inherit kernel-2 eutils
detect_version

DESCRIPTION="Slackware Current Kernel Sources 64 Bit only"
HOMEPAGE="http://slackware.com/"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${FILESDIR}/slackware-sources-2.6.38.7.tar.xz
	}

src_install() {
	kernel-2_src_install
	}
