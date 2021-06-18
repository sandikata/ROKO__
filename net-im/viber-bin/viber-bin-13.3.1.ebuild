# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Source overlay: https://github.com/BlueManCZ/edgets

EAPI=7
inherit desktop unpacker xdg-utils

MY_PN="${PN/-bin/}"
UP_PN="${MY_PN^}"

DESCRIPTION="Free calls, text and picture sharing with anyone, anywhere!"
HOMEPAGE="http://www.viber.com"
SRC_URI="http://webly3d.net/static/edgets-overlay/net-im/viber-bin/${P}.deb"

LICENSE="viber"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+pulseaudio xscreensaver"

RDEPEND="dev-libs/icu
  dev-libs/nss
  media-libs/alsa-lib
  media-libs/gst-plugins-base
	media-libs/gst-plugins-good
	media-libs/gst-plugins-ugly
	media-plugins/gst-plugins-libav
	media-plugins/gst-plugins-pulse
  sys-libs/zlib
  pulseaudio? ( media-sound/pulseaudio )
  xscreensaver? ( x11-libs/libXScrnSaver )"

QA_PREBUILT="*"

S="${WORKDIR}"

src_prepare() {
  mv "usr/share/icons/hicolor/scalable/apps/Viber.svg" "usr/share/icons/hicolor/scalable/apps/viber.svg"
  default
}

src_install() {
  insinto "/opt"
	doins -r "opt/${MY_PN}"

  insinto "/usr/share/"
  doins -r "usr/share/icons" "usr/share/pixmaps"

  exeinto "/opt/${MY_PN}"
  doexe "opt/viber/Viber"

  exeinto "/opt/${MY_PN}/libexec"
  doexe "opt/viber/libexec/QtWebEngineProcess"

  dosym "/opt/${MY_PN}/Viber" "/usr/bin/${MY_PN}"
  dosym "/opt/${MY_PN}/" "/usr/share/${MY_PN}"

  make_desktop_entry ${MY_PN} ${UP_PN} ${MY_PN} "Network;InstantMessaging;P2P" \
    "MimeType=x-scheme-handler/viber;\nStartupWMClass=ViberPC"
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
  xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
