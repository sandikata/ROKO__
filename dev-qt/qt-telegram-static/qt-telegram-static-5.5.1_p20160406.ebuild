# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

# 'module > subdir > package' bindings: https://wiki.gentoo.org/wiki/Project:Qt/Qt5status

QT5_MODULE='qtbase' # base ( core dbus gui network widgets ) imageformats
QT_MODULES=(qtbase qtimageformats)

inherit qmake-utils versionator eutils qt5-build check-reqs

# prevent qttest from being assigned to DEPEND
E_DEPEND="${E_DEPEND/test? \( \~dev-qt\/qttest-* \)}"

DESCRIPTION='Patched Qt for net-im/telegram'
HOMEPAGE='https://github.com/telegramdesktop/tdesktop'
SLOT='0'

qt_ver="$( get_version_component_range 1-3 )"

qt_patch_rev="$(get_version_component_range 4)"
# convert date to ISO8601 and format it properly
qt_patch_rev="master@{${qt_patch_rev:1:4}-${qt_patch_rev:5:2}-${qt_patch_rev:7:2}}"
qt_patch_name="${P}-qtbase.patch"
qt_submodules_base_uri="https://download.qt-project.org/official_releases/qt/${qt_ver%.*}/${qt_ver}/submodules"
SRC_URI="
	$( eval echo "${qt_submodules_base_uri}/"\{$( IFS=,; echo "${QT_MODULES[*]}" )\}"-opensource-src-${qt_ver}.tar.xz" )
	https://github.com/telegramdesktop/tdesktop/raw/${qt_patch_rev}/Telegram/_qtbase_${qt_ver//./_}_patch.diff -> ${qt_patch_name}
"

KEYWORDS='~amd64'
RESTRICT='strip test'
IUSE='bindist gtkstyle libproxy systemd tslib'
REQUIRED_USE=''

RDEPEND=(
	## BEGIN - QtCore
	'>=dev-libs/libpcre-8.35[pcre16]'
	'>=sys-libs/zlib-1.2.5'
	'virtual/libiconv'
	'dev-libs/glib:2'
	## END - QtCore

	## BEGIN - QtDbus
	'>=sys-apps/dbus-1.4.20'
	## END - QtDbus

	## BEGIN - QtGui
	'media-libs/fontconfig'
	'>=media-libs/freetype-2.5.5:2'
	'>=media-libs/harfbuzz-0.9.40:='
	'>=sys-libs/zlib-1.2.5'
	'gtkstyle? ('
		'x11-libs/gtk+:2'
		'x11-libs/pango'
		'!!x11-libs/cairo[qt4]'
	')'
	'virtual/jpeg:0'
	'media-libs/libpng:0='
	'tslib? ( x11-libs/tslib )'
		# BEGIN - QtGui - XCB
		'x11-libs/libICE'
		'x11-libs/libSM'
		'x11-libs/libX11'
		'>=x11-libs/libXi-1.7.4'
		'x11-libs/libXrender'
		'>=x11-libs/libxcb-1.10:=[xkb]'
		'>=x11-libs/libxkbcommon-0.4.1[X]'
		'x11-libs/xcb-util-image'
		'x11-libs/xcb-util-keysyms'
		'x11-libs/xcb-util-renderutil'
		'x11-libs/xcb-util-wm'
		# END - QtGui - XCB
	'systemd? ( sys-apps/systemd )'
	## END - QtGui

	## BEGIN - QtImageFormats
	'media-libs/jasper'
	'media-libs/libmng'
	'media-libs/libwebp'
	'media-libs/tiff:0'
	## END - QtImageFormats

	## BEGIN - QtNetwork
	'dev-libs/openssl:0[bindist=]'
	'>=sys-libs/zlib-1.2.5'
	'libproxy? ( net-libs/libproxy )'
	## END - QtNetwork

	# tools
	'dev-qt/qt'{core,dbus,widgets}':5'
)
DEPEND=("${RDEPEND[@]}"
	'virtual/pkgconfig'
)
PDEPEND=( '>=net-im/telegram-0.9.40' )

DEPEND="${DEPEND[*]}"
RDEPEND="${RDEPEND[*]}"
PDEPEND="${PDEPEND[*]}"

## !!! ORDER MATTERS !!!
QT5_TARGET_SUBDIRS=(
	## BEGIN - QtCore
	'qtbase/src/tools/'{bootstrap,moc,rcc}
	'qtbase/src/corelib'
	## END - QtCore

	## BEGIN - QtDbus (core)
	'qtbase/src/dbus'
	'qtbase/src/tools/qdbusxml2cpp'
	## END - QtDbus

	## BEGIN - QtNetwork (core, dbus)
	'qtbase/src/network'
	## END - QtNetwork

	## BEGIN - QtGui (core,dbus)
	'qtbase/src/'{gui,platform{headers,support}}
	'qtbase/src/plugins/'{generic,imageformats,platforms,platform{inputcontexts,themes}}
	## END - QtGui

	## BEGIN - QtImageFormats (core,gui)
	'qtimageformats'
	## END - QtImageFormats

	## BEGIN - QtWidgets (core,gui)
	'qtbase/src/tools/uic'
	'qtbase/src/widgets'
	## END - QtWidgets
)

CHECKREQS_DISK_BUILD='800M'

S="${WORKDIR}"
QT5_BUILD_DIR="${S}"
qtbase_dir="${S}/qtbase"
# this path must be in sync with net-im/telegram ebuild
QT5_PREFIX="${EROOT}opt/telegram-qtstatic"
TOOLS=() # list of all tools which will be linked from system wide qt5 to qt-static bin dir

src_unpack() {
	qt5-build_src_unpack

	for m in ${QT_MODULES[@]} ;do
		mv "${m}-opensource-src-${qt_ver}" "${m}" || die
	done
}

# override env to use our prefix and paths expected by tg sources
qt5_prepare_env() {
	QT5_HEADERDIR="${QT5_PREFIX}/include"
	QT5_LIBDIR="${QT5_PREFIX}/lib"
	QT5_ARCHDATADIR="${QT5_PREFIX}"
	QT5_BINDIR="${QT5_ARCHDATADIR}/bin"
	QT5_PLUGINDIR="${QT5_ARCHDATADIR}/plugins"
	QT5_LIBEXECDIR="${QT5_ARCHDATADIR}/libexec"
	QT5_IMPORTDIR="${QT5_ARCHDATADIR}/imports"
	QT5_QMLDIR="${QT5_ARCHDATADIR}/qml"
	QT5_DATADIR="${QT5_PREFIX}/share"
	QT5_DOCDIR="${QT5_PREFIX}/share/doc/qt-${qt_ver}"
	QT5_TRANSLATIONDIR="${QT5_DATADIR}/translations"
	QT5_EXAMPLESDIR="${QT5_DATADIR}/examples"
	QT5_TESTSDIR="${QT5_DATADIR}/tests"
	QT5_SYSCONFDIR="${EPREFIX}/etc/xdg"
	readonly QT5_PREFIX QT5_HEADERDIR QT5_LIBDIR QT5_ARCHDATADIR \
		QT5_BINDIR QT5_PLUGINDIR QT5_LIBEXECDIR QT5_IMPORTDIR \
		QT5_QMLDIR QT5_DATADIR QT5_DOCDIR QT5_TRANSLATIONDIR \
		QT5_EXAMPLESDIR QT5_TESTSDIR QT5_SYSCONFDIR

	# see mkspecs/features/qt_config.prf
	export QMAKEMODULES="${QT5_BUILD_DIR}/mkspecs/modules:${S}/mkspecs/modules:${QT5_ARCHDATADIR}/mkspecs/modules"
}

# my alternative is inline in src_configure()
qt5_symlink_tools_to_build_dir() { true; }

src_prepare() {
	cd "${qtbase_dir}" || die

	local qt_patch_file_lock="${T}/.qt_patched"
	if ! [ -f "${qt_patch_file_lock}" ] ;then
		eapply "${DISTDIR}/${qt_patch_name}" && touch "${qt_patch_file_lock}"
	fi

	## BEGIN - QtGui
	# avoid automagic dep on qtnetwork
	sed -i -e '/SUBDIRS += tuiotouch/d' \
		-- 'src/plugins/generic/generic.pro' || die
	## END - QtGui

	# apply user patches now, because qt5-build_src_prepare() calls default() in a wrong dir
	pushd "${S}" >/dev/null || die
	eapply_user
	popd >/dev/null || die

	qt5-build_src_prepare
}

src_configure() {
	local myconf=(
		-static

		# use system libs
		-system-{freetype,harfbuzz,libjpeg,libpng,pcre,xcb,xkbcommon-x11,zlib}

		# enabled features
		-{fontconfig,glib,gui,iconv,icu,xcb,xcb-xlib,xinput2,xkb,xrender,widgets}
		-{dbus,openssl}-linked
		# disabled features
		-no-{cups,directfb,eglfs,evdev,kms,libinput,linuxfb,mtdev,nis,opengl}

		# Telegram doesn't support sending files >4GB
		-no-largefile

		$(qt_use gtkstyle)
		$(qt_use libproxy)
		$(qt_use systemd journald)
		$(qt_use tslib)
	)

	# This configure will build qmake for use in builds of other modules.
	# The global qmake will not work.
	S="${qtbase_dir}" QT5_BUILD_DIR="${qtbase_dir}" \
		qt5_base_configure

	my_qt5_qmake() {
		QT5_MODULE='' QT5_BINDIR="${qtbase_dir}/bin" \
			qt5_qmake
	}
	qt5_foreach_target_subdir \
		my_qt5_qmake

	# The qmake above now generated make targets for the tools specified in `QT5_TARGET_SUBDIRS`
	# for use in other modules. The problem is that it tries to use tools from `qtbase/bin` dir.
	# These tools don't have to be built though, as we can just use the system ones.
	# So we'll just symlink them to `qtbase/bin` and remove them from `QT5_TARGET_SUBDIRS`
	# to prevent them from being built.
	local qt5_bindir="$(qt5_get_bindir)" QT5_TARGET_SUBDIRS_NEW=()
	for d in "${QT5_TARGET_SUBDIRS[@]}" ;do
		if [[ "$d" == *'/tools/'* ]] ;then
			local tool="${d##*/}"
			local target="${qt5_bindir}/${tool}" dir_out="${qtbase_dir}/bin"
			if [ -x "${target}" ] ;then
				elog "Symlinking tool '${tool}'"
				ln -s "${target}" "${dir_out}/" || die
				TOOLS+=( "${tool}" )
			else
				elog "Not symlinking '${tool}'"
			fi
		else
			QT5_TARGET_SUBDIRS_NEW+=( "$d" )
		fi
	done
	QT5_TARGET_SUBDIRS=( "${QT5_TARGET_SUBDIRS_NEW[@]}" )
}

src_compile() {
	qt5_foreach_target_subdir \
		emake
}

src_install() {
	qt5_foreach_target_subdir \
		emake INSTALL_ROOT="${D}" install
	emake -C "${qtbase_dir}" INSTALL_ROOT="${D}" install_qmake install_mkspecs

	local qt5_bindir="$(qt5_get_bindir)"
	for t in "${TOOLS[@]}" ;do
		dosym "${qt5_bindir}/${t}" "${QT5_BINDIR}/${t}"
	done
}

# unneeded funcs
qt5-build_pkg_postinst() { true; }
qt5-build_pkg_postrm() { true; }
