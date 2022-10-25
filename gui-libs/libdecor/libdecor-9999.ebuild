# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.gnome.org/jadahl/libdecor.git"
else
	SRC_URI="https://gitlab.gnome.org/jadahl/libdecor/-/archive/${PV}/${P}.tar.gz"
	KEYWORDS="~amd64"
fi

DESCRIPTION="A client-side decorations library for Wayland clients"
HOMEPAGE="https://gitlab.gnome.org/jadahl/libdecor"
LICENSE="MIT"
SLOT="0"
IUSE="+dbus"

DEPEND="
	>=dev-libs/wayland-1.18
	>=dev-libs/wayland-protocols-1.15
	dbus? ( sys-apps/dbus )
	x11-libs/pango
"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-util/meson-0.47"
