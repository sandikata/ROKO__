# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="update-notifier like tray icon for portage"
HOMEPAGE="https://github.com/hartwork/update-notifier-tray"
SRC_URI="https://github.com/hartwork/update-notifier-tray/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-python/pyside
	sys-apps/lsb-release
	sys-apps/portage
	virtual/notification-daemon
	x11-themes/tango-icon-theme
	x11-terms/terminator
	"
