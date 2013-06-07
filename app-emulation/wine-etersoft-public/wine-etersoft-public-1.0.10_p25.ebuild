# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

inherit rpm eutils flag-o-matic multilib

DESCRIPTION="MS Windows compatibility layer (WINE@Etersoft public edition)"
HOMEPAGE="http://etersoft.ru/wine"

WINEVER=${PV%_p*}
ETER_REV=${PV#*_p}

SRC_URI="ftp://updates.etersoft.ru/pub/Etersoft/WINE@Etersoft/${WINEVER}-eter${ETER_REV}/sources/tarball/wine-etersoft-${WINEVER}-eter${ETER_REV}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE="alsa arts cups dbus esd hal jack jpeg lcms ldap nas ncurses opengl oss scanner xml X cifs"
RESTRICT="nomirror"
	

RDEPEND=">=media-libs/freetype-2.0.0
	!app-emulation/wine
	cifs? ( >=net-fs/etercifs-4.3.6 )
	media-fonts/corefonts
	ncurses? ( >=sys-libs/ncurses-5.2 )
	jack? ( media-sound/jack-audio-connection-kit )
	dbus? ( sys-apps/dbus )
	hal? ( sys-apps/hal )
	X? (
		x11-libs/libXcursor
		x11-libs/libXrandr
		x11-libs/libXi
		x11-libs/libXmu
		x11-libs/libXxf86vm
		x11-apps/xmessage
	)
	alsa? ( media-libs/alsa-lib )
	esd? ( media-sound/esound )
	nas? ( media-libs/nas )
	cups? ( net-print/cups )
	opengl? ( virtual/opengl )
	jpeg? ( media-libs/jpeg )
	ldap? ( net-nds/openldap )
	lcms? ( media-libs/lcms )
	xml? ( dev-libs/libxml2 dev-libs/libxslt )
	>=media-gfx/fontforge-20060703
	scanner? ( media-gfx/sane-backends )
	amd64? (
		>=app-emulation/emul-linux-x86-xlibs-2.1
		>=app-emulation/emul-linux-x86-soundlibs-2.1
		>=sys-kernel/linux-headers-2.6
	)"
DEPEND="${RDEPEND}
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
	)
	sys-devel/bison
	sys-devel/flex"

pkg_setup() {
	use alsa || return 0
	if ! built_with_use --missing true media-libs/alsa-lib midi ; then
		eerror "You must build media-libs/alsa-lib with USE=midi"
		die "please re-emerge media-libs/alsa-lib with USE=midi"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"/wine-etersoft-${WINEVER}/

	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in
	epatch "${FILESDIR}"/oem_charset-jrd63fix.patch
	sed -i '/^MimeType/d' tools/wine.desktop || die #117785
	
}

config_cache() {
	local h ans="no"
	use $1 && ans="yes"
	shift
	for h in "$@" ; do
		[[ ${h} == *.h ]] \
			&& h=header_${h} \
			|| h=lib_${h}
		export ac_cv_${h//[:\/.]/_}=${ans}
	done
}

src_compile() {
	export LDCONFIG=/bin/true
	use arts    || export ac_cv_path_ARTSCCONFIG=""
	use esd     || export ac_cv_path_ESDCONFIG=""
	use scanner || export ac_cv_path_sane_devel="no"
	config_cache jack jack/jack.h
	config_cache cups cups/cups.h
	config_cache alsa alsa/asoundlib.h sys/asoundlib.h asound:snd_pcm_open
	config_cache nas audio/audiolib.h audio/soundlib.h
	config_cache xml libxml/parser.h libxslt/pattern.h libxslt/transform.h
	config_cache ldap ldap.h lber.h
	config_cache dbus dbus/dbus.h
	config_cache hal hal/libhal.h
	config_cache jpeg jpeglib.h
	config_cache oss sys/soundcard.h machine/soundcard.h soundcard.h
	config_cache lcms lcms.h

	strip-flags

	#use amd64 && multilib_toolchain_setup x86

	cd "${WORKDIR}"/wine-etersoft-${WINEVER}/
	
	econf \
		--sysconfdir=/etc \
		--enable-dll \
		--prefix=/usr \
		$(use_with ncurses curses) \
		$(use_with opengl) \
		$(use_with X x) \
		$(use_enable debug trace) \
		$(use_enable debug) \
		|| die "configure failed"

	emake -j1 depend || die "depend"
	emake all || die "all"
}

src_install() {
	cd "${WORKDIR}"/wine-etersoft-${WINEVER}/
	make DESTDIR=${D} initdir=/etc/init.d sysconfdir=/etc install || die
	dodoc ANNOUNCE AUTHORS ChangeLog README
	cp "${FILESDIR}"/*.fon ${D}/usr/share/wine/fonts/
	cp "${FILESDIR}"/*.ttf ${D}/usr/share/wine/fonts/

	/bin/rm -f ${D}/etc/init.d/*
	newinitd "${FILESDIR}"/wine.init wine
}

pkg_postinst() {
	elog "~/.wine/config is now deprecated.  For configuration either use"
	elog "winecfg or regedit HKCU\\Software\\Wine"
	elog ""
	elog "Use wine for initial user enviroment or wine --update."
}
