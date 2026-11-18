# Copyright 2026 Rosen Aleksandrov
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker systemd xdg

DESCRIPTION="An open-source remote desktop, alternative to TeamViewer (prebuilt unattended Wayland build)"
HOMEPAGE="https://rustdesk.com/"
SRC_URI="https://github.com/rustdesk/rustdesk/releases/download/nightly/rustdesk-unattended-wayland-${PV}-x86_64.deb -> ${P}.deb"
S="${WORKDIR}"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="-* ~amd64"
# nightly artifacts get overwritten upstream, so the Manifest will go stale
RESTRICT="bindist mirror strip"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	media-libs/alsa-lib
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/libpulse
	media-libs/libva[X]
	media-video/pipewire[gstreamer]
	sys-apps/dbus
	virtual/zlib:=
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libXfixes
	x11-libs/libxcb:=
	x11-libs/libxkbcommon
	x11-libs/libXtst
	x11-libs/libvdpau
	x11-libs/pango
	x11-misc/xdotool
"

QA_PREBUILT="*"

src_install() {
	# deb layout: usr/share/rustdesk (binary, lib/, data/), usr/bin, desktop files, icons
	insinto /usr
	doins -r usr/.
	dosym ../share/rustdesk/rustdesk /usr/bin/rustdesk
	fperms +x /usr/share/${PN%-wayland-bin}/rustdesk
	[[ -e usr/bin/rustdesk ]] && fperms +x /usr/bin/rustdesk

	# systemd unit may be in usr/lib/systemd/system or lib/systemd/system
	local unit
	for unit in usr/lib/systemd/system/rustdesk.service lib/systemd/system/rustdesk.service; do
		if [[ -f ${unit} ]]; then
			systemd_dounit "${unit}"
			break
		fi
	done
}
