# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PLOCALES="be bg ca cmn cs da de el en_GB es_AR es_MX es et eu fa_IR fi fr gl
	hu id_ID it ja ko ky lt lv ml_IN ms nl pl pt_BR pt_PT ru si sk sr sr_RS sv
	ta tr uk zh_CN zh_TW"
PLOCALE_BACKUP="en_GB"

inherit eutils l10n multilib

DESCRIPTION="Plugins for Audacious music player"
HOMEPAGE="http://audacious-media-player.org/"
SRC_URI="!gtk3? ( http://distfiles.audacious-media-player.org/${P}.tar.bz2 )
	gtk3? ( http://distfiles.audacious-media-player.org/${P}-gtk3.tar.bz2 )"

LICENSE="BSD-2 filewriter? ( GPL-2+ ) libnotify? ( GPL-3+ ) pulseaudio? ( GPL-2+ )
	sndfile? ( GPL-2+ ) spectrum? ( GPL-2+ )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="aac alsa bs2b cdda cue ffmpeg +filewriter flac gnome +gtk -gtk3 http
	jack lame libav libnotify libsamplerate lirc midi mms modplug mp3
	pulseaudio qt5 scrobbler sdl sid sndfile soxr spectrum vorbis wavpack"
REQUIRED_USE="	|| ( gtk qt5 )
	filewriter? ( gtk )
	gtk3? ( gtk )
	libnotify? ( gtk )
	scrobbler? ( gtk )
	spectrum? ( || ( gtk qt5 ) )"

COMMON_DEPEND=">=dev-libs/dbus-glib-0.60
	dev-libs/libxml2:2
	~media-sound/audacious-3.7[gtk=,gtk3=,qt5=]
	>=sys-apps/dbus-0.6.0
	>=sys-devel/gcc-4.7.0:*
	x11-libs/libXcomposite
	x11-libs/libXrender
	aac? ( >=media-libs/faad2-2.7 )
	alsa? ( >=media-libs/alsa-lib-1.0.16 )
	bs2b? ( >=media-libs/libbs2b-3.0.0 )
	cdda? ( >=media-libs/libcddb-1.2.1
		>=dev-libs/libcdio-0.70
		>=dev-libs/libcdio-paranoia-0.70 )
	cue? ( media-libs/libcue )
	ffmpeg? ( libav? ( media-video/libav:0= )
		!libav? ( media-video/ffmpeg:0= ) )
	flac? ( >=media-libs/libvorbis-1.0
		>=media-libs/flac-1.2.1-r1 )
	gtk? ( !gtk3? ( x11-libs/gtk+:2 ) )
	gtk3? ( x11-libs/gtk+:3 )
	http? ( >=net-libs/neon-0.27 )
	jack? ( >=media-libs/bio2jack-0.4
		>=media-sound/jack-audio-connection-kit-0.120.1 )
	lame? ( media-sound/lame )
	libnotify? ( >=x11-libs/libnotify-0.7 )
	libsamplerate? ( media-libs/libsamplerate )
	lirc? ( app-misc/lirc )
	midi? ( >=media-sound/fluidsynth-1.0.6 )
	mms? ( >=media-libs/libmms-0.3 )
	modplug? ( media-libs/libmodplug )
	mp3? ( >=media-sound/mpg123-1.12.1 )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.5 )
	qt5? ( dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtmultimedia:5
		dev-qt/qtwidgets:5
		spectrum? ( dev-qt/qtopengl:5 ) )
	scrobbler? ( >=net-misc/curl-7.9.7 )
	sdl? ( || ( >=media-libs/libsdl-1.2.11[sound]
			>=media-libs/libsdl2-2.0[sound] ) )
	sid? ( >=media-libs/libsidplayfp-1.0.0 )
	sndfile? ( >=media-libs/libsndfile-1.0.17-r1 )
	soxr? ( media-libs/soxr )
	spectrum? ( virtual/opengl
		qt5? ( dev-qt/qtopengl:5 ) )
	vorbis? ( >=media-libs/libogg-1.1.3
		>=media-libs/libvorbis-1.2.0 )
	wavpack? ( >=media-sound/wavpack-4.50.1-r1 )"
DEPEND="${COMMON_DEPEND}
	|| ( >=dev-libs/glib-2.32.2
		dev-util/gdbus-codegen )
	sys-devel/gettext
	virtual/pkgconfig"
RDEPEND=${COMMON_DEPEND}

use gtk3 && S="${WORKDIR}/${P}-gtk3"
RESTRICT="mirror"

pkg_pretend() {
	use mp3 || ewarn \
		"MP3 support is optional. Are you sure to disable mp3 USE flag?"
}

src_prepare() {
	epatch "${FILESDIR}/${P}-gl-spectrum-qt-include-glu.patch"
	l10n_for_each_disabled_locale_do remove_locales
}

src_configure() {
	local ffmpeg_conf=""
	use ffmpeg && ffmpeg_conf="--with-ffmpeg=ffmpeg"
	use libav && ffmpeg_conf="--with-ffmpeg=libav"

	local spectrum_conf=""
	if use spectrum ; then
		use gtk && spectrum_conf="${spectrum_conf} --enable-glspectrum"
		use qt5 && spectrum_conf="${spectrum_conf} --enable-qtglspectrum"
	fi

	# coreaudio and mac-media-keys are for MacOSX / Darwin
	econf \
		--disable-coreaudio \
		--disable-mac-media-keys \
		$(use_enable aac) \
		$(use_enable alsa) \
		$(use_enable bs2b) \
		$(use_enable cdda cdaudio) \
		$(use_enable cue) \
		${ffmpeg_conf} \
		$(use_enable flac flacng) \
		$(use_enable flac filewriter_flac) \
		$(use_enable gnome gnomeshortcuts) \
		$(use_enable gtk aosd) \
		$(use_enable gtk aosd-xcomp) \
		$(use_enable gtk) \
		$(use_enable gtk hotkey) \
		$(use_enable http neon) \
		$(use_enable jack) \
		$(use_enable lame filewriter_mp3) \
		$(use_enable libnotify notify) \
		$(use_enable libsamplerate resample) \
		$(use_enable lirc) \
		$(use_enable midi amidiplug) \
		$(use_enable mms) \
		$(use_enable modplug) \
		$(use_enable mp3) \
		$(use_enable midi amidiplug) \
		$(use_enable pulseaudio pulse) \
		$(use_enable qt5 qt) \
		$(use_enable qt5 qtaudio) \
		$(use_enable scrobbler scrobbler2) \
		$(use_enable sdl sdlout) \
		$(use_enable sid) \
		$(use_enable sndfile) \
		$(use_enable soxr) \
		${spectrum_conf} \
		$(use_enable vorbis) \
		$(use_enable wavpack)
}

remove_locales() {
	sed -i "s/${1}.po//" po/Makefile
}
