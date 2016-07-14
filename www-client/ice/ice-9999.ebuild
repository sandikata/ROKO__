# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit git-r3 eutils
DESCRIPTION="Tool to create Chromium/Chrome/Firefox WebApps in Peppermint OS."
HOMEPAGE="https://github.com/peppermintos/ice"
SRC_URI=""
EGIT_REPO_URI="https://github.com/peppermintos/ice.git"

LICENSE="GPL-v2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-python/requests
	dev-python/beautifulsoup:4
	dev-lang/python:3.4
	dev-python/pygobject:3"
RDEPEND="${DEPEND}"


src_install(){
	cp -R usr "${D}"
}

