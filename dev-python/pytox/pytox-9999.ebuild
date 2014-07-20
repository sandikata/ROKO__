# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
PYTHON_COMPAT=( python{2_7,3_3} )

inherit distutils-r1 eutils

if [[ ${PV} == "9999" ]] ; then
	inherit git-2
	EGIT_REPO_URI="https://github.com/aitjcize/PyTox.git"
else
	SRC_URI="https://github.com/aitjcize/PyTox/archive/${PV}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Python bindings for the Tox library"
HOMEPAGE="https://github.com/aitjcize/PyTox"
LICENSE="GPL-2"
SLOT="0"

RDEPEND="net-libs/tox"
DEPEND="${RDEPEND}"
