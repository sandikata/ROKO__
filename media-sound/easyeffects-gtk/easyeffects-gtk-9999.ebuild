# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome2 meson toolchain-funcs git-r3

DESCRIPTION="Audio effects for PipeWire applications (GTK4/libadwaita fork)"
HOMEPAGE="https://github.com/Mlocik97/easyeffects-gtk"
SRC_URI=""
EGIT_REPO_URI="https://github.com/Mlocik97/easyeffects-gtk.git"
EGIT_BRANCH="port"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE="calf +doc libportal mda-lv2 +rnnoise zamaudio"

COMMON_DEPEND="
	dev-cpp/nlohmann_json
	dev-cpp/tbb:=
	>=dev-libs/glib-2.56:2
	>=dev-libs/libfmt-8.0.0:=
	>=dev-libs/libsigc++-3.0.6:3
	>=gui-libs/gtk-4.10.0:4
	>=gui-libs/libadwaita-1.2.0:1
	media-libs/libbs2b
	>=media-libs/libebur128-1.2.0:=
	media-libs/libsamplerate
	media-libs/libsndfile
	media-libs/libsoundtouch:=
	>=media-libs/lilv-0.22
	>=media-libs/lv2-1.18.2
	media-libs/speexdsp
	>=media-libs/zita-convolver-3.0.0:=
	>=media-video/pipewire-0.3.58:=
	sci-libs/fftw:3.0=
	sci-libs/gsl:=
	x11-libs/cairo
	x11-libs/pango
	libportal? ( dev-libs/libportal[gtk] )
	rnnoise? ( media-libs/rnnoise )
"

DEPEND="
	${COMMON_DEPEND}
	media-libs/ladspa-sdk
"

RDEPEND="
	${COMMON_DEPEND}
	!media-sound/easyeffects
	>=media-libs/lsp-plugins-1.2.10[lv2]
	sys-apps/dbus
	calf? ( >=media-plugins/calf-0.90.1[lv2] )
	doc? ( gnome-extra/yelp )
	mda-lv2? ( media-plugins/mda-lv2 )
	zamaudio? ( media-plugins/zam-plugins )
"

BDEPEND="
	dev-libs/appstream-glib
	dev-util/desktop-file-utils
	dev-util/itstool
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-fix-gclosure-notify.patch"
	"${FILESDIR}/${PN}-fix-gtk-header.patch"
	"${FILESDIR}/${PN}-fix-autotune-span.patch"
	"${FILESDIR}/${PN}-fix-port-name-collision.patch"
	"${FILESDIR}/${PN}-fix-dbus-callbacks.patch"
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if tc-is-gcc; then
			[[ $(gcc-major-version) -ge 11 ]] ||
				die "GCC 11 or newer is required"
		elif tc-is-clang; then
			[[ $(clang-major-version) -ge 16 ]] ||
				die "Clang 16 or newer is required"
		else
			die "Unsupported compiler"
		fi
	fi
}

src_configure() {
	local libcxx=false
	[[ $(tc-get-cxx-stdlib) == libc++ ]] && libcxx=true

	local emesonargs=(
		-Ddevel=false
		-Denable-mold=false
		-Denable-libcpp-workarounds=${libcxx}
		$(meson_use libportal enable-libportal)
		$(meson_use rnnoise enable-rnnoise)
	)

	meson_src_configure
}
