# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils git-r3
DESCRIPTION="Application dock for the MATE panel"
HOMEPAGE="https://github.com/robint99/dock-applet"
EGIT_REPO_URI="https://github.com/robint99/dock-applet.git"

LICENSE=""
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/python:3.4
	x11-libs/libwnck:3[introspection]
	sys-devel/automake:1.15"
RDEPEND="${DEPEND}"

