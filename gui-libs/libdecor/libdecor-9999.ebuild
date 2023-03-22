# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="A client-side decorations library for Wayland client"
HOMEPAGE="https://gitlab.freedesktop.org/libdecor/libdecor"

if [[ ${PV} == 9999 ]]; then
    inherit git-r3
    EGIT_REPO_URI="${HOMEPAGE}"
    KEYWORDS=""
else
	SRC_URI="${HOMEPAGE}/-/archive/${PV}/${P}.tar.gz"
    KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="dbus"

DEPEND="dbus? ( sys-apps/dbus )"
RDEPEND="${DEPEND}"
BDEPEND="dev-libs/wayland
	x11-libs/cairo"
