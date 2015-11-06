# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PLOCALES="be bg bn ca cs da de el en_GB es et eu fa fi fr gl he hr hu id it ja kk km lg
	lt nl pl pt pt_BR ro ru si_LK sk sl sr sr@latin sv te tr ug uk vi zh_CN zh_TW"

PLOCALE_BACKUP="en_GB"

inherit autotools eutils fdo-mime gnome2-utils l10n

SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

KEYWORDS="*"

DESCRIPTION="foobar2k-like music player"
HOMEPAGE="http://deadbeef.sourceforge.net"

RESTRICT="mirror"

LICENSE="BSD
	UNICODE
	ZLIB
	aac? ( GPL GPL-2 )
	adplug? ( LGPL-2.1 ZLIB )
	alac? ( MIT GPL-2 )
	alsa? ( GPL-2 )
	cdda? ( GPL-2 LGPL-2 GPL-3 )
	cover? ( ZLIB )
	converter? ( GPL-2 )
	curl? ( curl ZLIB )
	dts? ( GPL-2 )
	dumb? ( DUMB-0.9.3 ZLIB )
	equalizer? ( GPL-2 )
	ffmpeg? ( GPL-2 )
	flac? ( BSD )
	gme? ( LGPL-2.1 )
	gtk2? ( GPL-2 )
	gtk3? ( GPL-2 )
	hotkeys? ( ZLIB )
	lastfm? ( GPL-2 )
	libnotify? ( GPL-2 )
	libsamplerate? ( GPL-2 )
	m3u? ( ZLIB )
	mac? ( GPL-2 )
	midi? ( LGPL-2.1 ZLIB )
	mms? ( GPL-2 ZLIB )
	mono2stereo? ( ZLIB )
	mp3? ( GPL-2 ZLIB )
	musepack? ( BSD ZLIB )
	nullout? ( ZLIB )
	oss? ( GPL-2 )
	playlist-browser? ( ZLIB )
	psf? ( BSD GPL MAME ZLIB )
	pulseaudio? ( GPL-2 )
	shell-exec? ( GPL-2 )
	shn? ( shorten ZLIB )
	sid? ( GPL-2 )
	sndfile? ( GPL-2 LGPL-2 )
	tta? ( BSD ZLIB )
	vorbis? ( BSD ZLIB )
	vtx? ( GPL-2 ZLIB )
	wavpack? ( BSD )
	wma? ( GPL-2 LGPL-2 ZLIB )
	zip? ( ZLIB )"

SLOT="0"

IUSE="+alsa +flac +gtk2 +hotkeys +m3u +mp3 +sndfile +vorbis
	aac adplug alac cdda converter cover cover-imlib2 cover-network curl dts dumb equalizer
	ffmpeg gme gtk3 lastfm libnotify libsamplerate mac midi mms mono2stereo musepack nls nullout
	oss playlist-browser psf pulseaudio shell-exec shn sid tta unity vtx wavpack wma zip"

REQUIRED_USE="converter? ( || ( gtk2 gtk3 ) )
	cover-imlib2? ( cover )
	cover-network? ( cover curl )
	cover? ( || ( gtk2 gtk3 ) )
	lastfm? ( curl )
	playlist-browser? ( || ( gtk2 gtk3 ) )
	|| ( alsa oss pulseaudio nullout )"

PDEPEND="media-plugins/deadbeef-plugins-meta"

RDEPEND="dev-libs/glib
	aac? ( media-libs/faad2 )
	adplug? ( media-libs/adplug )
	alsa? ( media-libs/alsa-lib )
	alac? ( media-libs/faad2 )
	cdda? ( dev-libs/libcdio media-libs/libcddb )
	cover? ( cover-imlib2? ( media-libs/imlib2 )
		media-libs/libpng
		virtual/jpeg
		x11-libs/gdk-pixbuf[jpeg] )
	curl? ( net-misc/curl )
	ffmpeg? ( virtual/ffmpeg )
	flac? ( media-libs/libogg
		media-libs/flac )
	gme? ( sys-libs/zlib )
	gtk2? ( dev-libs/atk
		x11-libs/cairo
		x11-libs/gtk+:2
		x11-libs/pango )
	gtk3? ( x11-libs/gtk+:3 )
	hotkeys? ( x11-libs/libX11 )
	libnotify? ( sys-apps/dbus )
	libsamplerate? ( media-libs/libsamplerate )
	mac? ( dev-lang/yasm )
	midi? ( media-sound/timidity-freepats )
	mp3? ( media-libs/libmad )
	psf? ( sys-libs/zlib )
	pulseaudio? ( media-sound/pulseaudio )
	sndfile? ( media-libs/libsndfile )
	vorbis? ( media-libs/libogg
		media-libs/libvorbis )
	wavpack? ( media-sound/wavpack )
	zip? ( dev-libs/libzip )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( virtual/libintl
		dev-util/intltool )"

src_prepare() {
	if ! use_if_iuse linguas_pt_BR && use_if_iuse linguas_ru ; then
		epatch "${FILESDIR}/${PN}-remove-pt_br-help-translation.patch"
		rm "${S}/translation/help.pt_BR.txt" || die
	fi

	if ! use_if_iuse linguas_ru && use_if_iuse linguas_pt_BR ; then
		epatch "${FILESDIR}/${PN}-remove-ru-help-translation.patch"
		rm "${S}/translation/help.ru.txt" || die
	fi

	if ! use_if_iuse linguas_pt_BR && ! use_if_iuse linguas_ru ; then
		epatch "${FILESDIR}/${PN}-remove-pt_br-and-ru-help-translation.patch"
		rm "${S}/translation/help.pt_BR.txt" "${S}/translation/help.ru.txt" || die
	fi

	if use midi ; then
		# set default gentoo path
		sed -e 's;/etc/timidity++/timidity-freepats.cfg;/usr/share/timidity/freepats/timidity.cfg;g' \
			-i "${S}/plugins/wildmidi/wildmidiplug.c" || die
	fi

	if ! use unity ; then
		# remove unity trash
		epatch "${FILESDIR}/${PN}-0.6.2-or-higher-remove-unity-trash.patch"
	fi

	config_rpath_update "${S}/config.rpath" || die
	eautoreconf
}

src_configure() {
	if use shell-exec ; then
		if use gtk2 || use gtk3 ; then
			shell-exec-ui="--enable-shellexec-ui"
		else
			shell-exec-ui="--disable-shellexec-ui"
		fi
	fi

	econf --disable-coreaudio \
		--disable-portable \
		--disable-static \
		--docdir=/usr/share/${PN} \
		${shell-exec-ui} \
		$(use_enable aac) \
		$(use_enable adplug) \
		$(use_enable alac) \
		$(use_enable alsa) \
		$(use_enable cdda) \
		$(use_enable converter) \
		$(use_enable cover artwork) \
		$(use_enable cover-imlib2 artwork-imlib2) \
		$(use_enable cover-network artwork-network) \
		$(use_enable curl vfs-curl) \
		$(use_enable dts dca) \
		$(use_enable dumb) \
		$(use_enable equalizer supereq) \
		$(use_enable ffmpeg) \
		$(use_enable flac) \
		$(use_enable gme) \
		$(use_enable gtk2) \
		$(use_enable gtk3) \
		$(use_enable hotkeys) \
		$(use_enable lastfm lfm) \
		$(use_enable libnotify notify) \
		$(use_enable libsamplerate src) \
		$(use_enable m3u) \
		$(use_enable mac ffap) \
		$(use_enable midi wildmidi) \
		$(use_enable mms) \
		$(use_enable mono2stereo) \
		$(use_enable mp3 mad) \
		$(use_enable musepack) \
		$(use_enable nls) \
		$(use_enable nullout) \
		$(use_enable oss) \
		$(use_enable playlist-browser pltbrowser) \
		$(use_enable psf) \
		$(use_enable pulseaudio pulse) \
		$(use_enable shell-exec shellexec) \
		$(use_enable shn) \
		$(use_enable sid) \
		$(use_enable sndfile) \
		$(use_enable tta) \
		$(use_enable vorbis) \
		$(use_enable vtx) \
		$(use_enable wavpack) \
		$(use_enable wma) \
		$(use_enable zip vfs-zip)
}

pkg_preinst() {
	if use gtk2 || use gtk3 ; then
		gnome2_icon_savelist
	fi
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	if use gtk2 || use gtk3 ; then
		gnome2_icon_cache_update
	fi
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	if use gtk2 || use gtk3 ; then
		gnome2_icon_cache_update
	fi
}
