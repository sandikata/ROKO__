# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )

inherit distutils-r1 python-utils-r1

DESCRIPTION="Tweak tool for the MATE Desktop, a fork of mintDesktop"
HOMEPAGE="https://launchpad.net/ubuntu/+source/mate-tweak
	https://github.com/ubuntu-mate/mate-tweak"
SRC_URI="https://github.com/ubuntu-mate/mate-tweak/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="GPL-2+"
KEYWORDS="~amd64 ~x86"
SLOT="0"

COMMON_DEPEND=${PYTHON_DEPS}
DEPEND="${COMMON_DEPEND}
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	sys-devel/gettext"
RDEPEND="${COMMON_DEPEND}
	app-shells/bash:*
	dev-libs/glib:2
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/setproctitle[${PYTHON_USEDEP}]
	gnome-base/dconf
	mate-base/caja
	>=mate-base/mate-desktop-1.14
	mate-base/mate-panel
	mate-extra/mate-media
	sys-process/psmisc
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	>=x11-libs/libnotify-0.7"

RESTRICT="mirror"

pkg_setup() {
	python_setup
}

src_install() {
	distutils-r1_python_install
    python_fix_shebang "${ED}"
}
