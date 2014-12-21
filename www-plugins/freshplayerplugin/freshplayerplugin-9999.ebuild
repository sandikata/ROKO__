# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit git-2 cmake-utils

DESCRIPTION="Chromium Flash wrapper for Mozilla Firefox"
HOMEPAGE="https://github.com/i-rinat/freshplayerplugin"
SRC_URI=""
EGIT_REPO_URI="https://github.com/i-rinat/${PN}.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-libs/glib
	dev-libs/libconfig
	dev-libs/libevent[threads]
	dev-libs/uriparser
	media-libs/alsa-lib
	media-libs/freetype
	media-libs/mesa[egl,gles2]
	x11-libs/cairo
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXinerama
	x11-libs/pango
	"
RDEPEND="${DEPEND}
	|| (
		www-plugins/chrome-binary-plugins[flash]
		www-client/google-chrome
		!www-client/google-chrome-beta
		!www-client/google-chrome-unstable
		!www-plugins/chrome-binary-plugins-beta
		!www-plugins/chrome-binary-plugins-unstable
	)
	"

src_install() {
	insinto /etc
	newins data/freshwrapper.conf.example freshwrapper.conf
	ewarn 'Currently supported PPAPI for firefox 34.0.5 is chrome 39'

	insinto /usr/lib/nsbrowser/plugins/
	doins "${BUILD_DIR}"/libfreshwrapper-pepperflash.so
}
