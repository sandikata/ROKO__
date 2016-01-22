# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit autotools eutils python-single-r1

DESCRIPTION="Python binding for Nemo components"
HOMEPAGE="https://github.com/linuxmint/nemo-extensions"
SRC_URI="https://github.com/linuxmint/nemo-extensions/archive/2.8.x.tar.gz"
S="${WORKDIR}/nemo-extensions-2.8.x/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}"
DEPEND="${RDEPEND}
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	>=gnome-extra/nemo-2.8.0[introspection]
	>=dev-util/gtk-doc-am-1.9
	virtual/pkgconfig
	doc? (
		app-text/docbook-xml-dtd:4.1.2
		dev-libs/libxslt
		>=dev-util/gtk-doc-1.9 )
"
src_prepare() {
	if [[ ! -e configure ]] ; then
		./autogen.sh || die
	fi
}

src_install() {
	default_src_install
	# Directory for systemwide extensions
	keepdir /usr/share/nemo-python/extensions
}
