# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: mate.eclass
# @MAINTAINER:
# micia@sabayon.org
# @BLURB:
# @DESCRIPTION:
# Exports portage base functions used by ebuilds written for packages using the
# MATE framework. For additional functions, see mate-utils.eclass.

inherit autotools fdo-mime libtool mate-desktop.org mate-utils

DEPEND="dev-util/gtk-doc
		dev-util/gtk-doc-am"

case "${EAPI:-0}" in
	0|1)
		EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_preinst pkg_postinst pkg_postrm
		;;
	2|3|4|5)
		EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install pkg_preinst pkg_postinst pkg_postrm
		;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

# @ECLASS-VARIABLE: G2CONF
# @DEFAULT-UNSET
# @DESCRIPTION:
# Extra configure opts passed to econf
G2CONF=${G2CONF:-""}

# @ECLASS-VARIABLE: MATE_LA_PUNT
# @DESCRIPTION:
# Should we delete all the .la files?
# NOT to be used without due consideration.
MATE_LA_PUNT=${MATE_LA_PUNT:-"no"}

# @ECLASS-VARIABLE: ELTCONF
# @DEFAULT-UNSET
# @DESCRIPTION:
# Extra options passed to elibtoolize
ELTCONF=${ELTCONF:-""}

# @ECLASS-VARIABLE: USE_EINSTALL
# @DEFAULT-UNSET
# @DEPRECATED
# @DESCRIPTION:
# Should we use EINSTALL instead of DESTDIR
USE_EINSTALL=${USE_EINSTALL:-""}

# @ECLASS-VARIABLE: SCROLLKEEPER_UPDATE
# @DEPRECATED
# @DESCRIPTION:
# Whether to run scrollkeeper for this package or not.
SCROLLKEEPER_UPDATE=${SCROLLKEEPER_UPDATE:-"1"}

# @ECLASS-VARIABLE: DOCS
# @DEFAULT-UNSET
# @DESCRIPTION:
# String containing documents passed to dodoc command.

# @ECLASS-VARIABLE: GCONF_DEBUG
# @DEFAULT_UNSET
# @DESCRIPTION:
# Whether to handle debug or not.
# Some gnome applications support various levels of debugging (yes, no, minimum,
# etc), but using --disable-debug also removes g_assert which makes debugging
# harder. This variable should be set to yes for such packages for the eclass
# to handle it properly. It will enable minimal debug with USE=-debug.
# Note that this is most commonly found in configure.ac as GNOME_DEBUG_CHECK.


if [[ ${GCONF_DEBUG} != "no" ]]; then
	IUSE="debug"
fi


# @FUNCTION: mate_src_unpack
# @DESCRIPTION:
# Stub function for old EAPI.
mate_src_unpack() {
	unpack ${A}
	cd "${S}"
	has ${EAPI:-0} 0 1 && mate_src_prepare
}

# @FUNCTION: mate_src_prepare
# @DESCRIPTION:
# Prepare environment for build, fix build of scrollkeeper documentation,
# run elibtoolize.
mate_src_prepare() {
	# Prevent assorted access violations and test failures
	mate_environment_reset

	# Prevent scrollkeeper access violations
	mate_omf_fix

	# Retrieve configure script
	local mate_conf_in
	if [[ -f "${S}/configure.in" ]]; then
		mate_conf_in="${S}/configure.in"
	elif [[ -f "${S}/configure.ac" ]]; then
		mate_conf_in="${S}/configure.ac"
	else
		einfo "no configure.in or configure.ac file were found"
		return 0
	fi

	# Mate preparation, doing similar to autotools eclass stuff. (Do we need die here?)
	if grep -q "^AM_GLIB_GNU_GETTEXT" "${mate_conf_in}"; then
		autotools_run_tool glib-gettextize --copy --force || die
	elif grep -q "^AM_GNU_GETTEXT" "${mate_conf_in}"; then
		eautopoint --force
	fi

	if grep -q "^AC_PROG_INTLTOOL" "${mate_conf_in}" || grep -q "^IT_PROG_INTLTOOL" "${mate_conf_in}"; then
		mkdir -p "${S}/m4"
		autotools_run_tool intltoolize --automake --copy --force || die
	fi

	if grep -q "^GTK_DOC_CHECK" "${mate_conf_in}"; then
		autotools_run_tool gtkdocize --copy || die
	fi

	if grep -q "^MATE_DOC_INIT" "${mate_conf_in}"; then
		autotools_run_tool mate-doc-prepare --force --copy || die
		autotools_run_tool mate-doc-common --copy || die
	fi

	if grep -q "^A[CM]_PROG_LIBTOOL" "${mate_conf_in}" || grep -q "^LT_INIT" "${mate_conf_in}"; then
		_elibtoolize --copy --force --install
	fi

	eaclocal
	eautoconf
	eautoheader
	eautomake
}

# @FUNCTION: mate_src_configure
# @DESCRIPTION:
# MATE specific configure handling
mate_src_configure() {
	# Skip phase if configure file doesn't exist
	if [[ ! -f "${S}/configure" ]]; then
		einfo "no configure file was found"
		return 0
	fi

	# Update the MATE configuration options
	if [[ ${GCONF_DEBUG} != 'no' ]] ; then
		if use debug ; then
			G2CONF="${G2CONF} --enable-debug=yes"
		fi
	fi

	# Starting with EAPI=5, we consider packages installing gtk-doc to be
	# handled by adding DEPEND="dev-util/gtk-doc-am" which provides tools to
	# relink URLs in documentation to already installed documentation.
	# This decision also greatly helps with constantly broken doc generation.
	# Remember to drop 'doc' USE flag from your package if it was only used to
	# rebuild docs.
	# Preserve old behavior for older EAPI.
	if grep -q "enable-gtk-doc" ${ECONF_SOURCE:-.}/configure ; then
		if has ${EAPI:-0} 0 1 2 3 4 && in_iuse doc ; then
			G2CONF="$(use_enable doc gtk-doc) ${G2CONF}"
		else
			G2CONF="--disable-gtk-doc ${G2CONF}"
		fi
	fi

	# Pass --disable-maintainer-mode when needed
	if grep -q "^[[:space:]]*AM_MAINTAINER_MODE(\[enable\])" configure.*; then
		G2CONF="${G2CONF} --disable-maintainer-mode"
	fi

	# Pass --disable-scrollkeeper when possible
	if grep -q "disable-scrollkeeper" configure; then
		G2CONF="${G2CONF} --disable-scrollkeeper"
	fi

	# Pass --disable-schemas-install when possible
	if grep -q "disable-schemas-install" configure; then
		G2CONF="${G2CONF} --disable-schemas-install"
	fi

	# Control static building
	if grep -q "disable-static" configure; then
		if use static-libs; then
			G2CONF="${G2CONF} --enable-static"
		else
			G2CONF="${G2CONF} --disable-static"
		fi
	fi

	# Enable gtk2/gtk3 depends on use for future support of MATE Desktop
	if grep -q "with-gtk" configure; then
		if use gtk3; then
			G2CONF="${G2CONF} --with-gtk=3.0"
		else
			G2CONF="${G2CONF} --with-gtk=2.0"
		fi
	fi

	econf "$@" ${G2CONF}
}

# @FUNCTION: mate_src_compile
# @DESCRIPTION:
# Stub function for old EAPI.
mate_src_compile() {
	has ${EAPI:-0} 0 1 && mate_src_configure "$@"
	emake || die "compile failure"
}

# @FUNCTION: mate_src_install
# @DESCRIPTION:
# MATE specific install. Handles typical MateConf and scrollkeeper setup
# in packages and removal of .la files if requested
mate_src_install() {
	has ${EAPI:-0} 0 1 2 && ! use prefix && ED="${D}"
	# if this is not present, scrollkeeper-update may segfault and
	# create bogus directories in /var/lib/
	local sk_tmp_dir="/var/lib/scrollkeeper"
	dodir "${sk_tmp_dir}" || die "dodir failed"

	# we must delay gconf schema installation due to sandbox
	export MATECONF_DISABLE_MAKEFILE_SCHEMA_INSTALL="1"

	if [[ -z "${USE_EINSTALL}" || "${USE_EINSTALL}" = "0" ]]; then
		debug-print "Installing with 'make install'"
		emake DESTDIR="${D}" "scrollkeeper_localstate_dir=${ED}${sk_tmp_dir} " "$@" install || die "install failed"
	else
		debug-print "Installing with 'einstall'"
		einstall "scrollkeeper_localstate_dir=${ED}${sk_tmp_dir} " "$@" || die "einstall failed"
	fi

	unset MATECONF_DISABLE_MAKEFILE_SCHEMA_INSTALL

	# Manual document installation
	if [[ -n "${DOCS}" ]]; then
		dodoc ${DOCS} || die "dodoc failed"
	fi

	# Do not keep /var/lib/scrollkeeper because:
	# 1. The scrollkeeper database is regenerated at pkg_postinst()
	# 2. ${ED}/var/lib/scrollkeeper contains only indexes for the current pkg
	#    thus it makes no sense if pkg_postinst ISN'T run for some reason.
	rm -rf "${ED}${sk_tmp_dir}"
	rmdir "${ED}/var/lib" 2>/dev/null
	rmdir "${ED}/var" 2>/dev/null

	# Make sure this one doesn't get in the portage db
	rm -fr "${ED}/usr/share/applications/mimeinfo.cache"

	# Delete all .la files
	if [[ "${MATE_LA_PUNT}" != "no" ]]; then
		ebegin "Removing .la files"
		if ! { has static-libs ${IUSE//+} && use static-libs; }; then
			find "${D}" -name '*.la' -exec rm -f {} + || die "la file removal failed"
		fi
		eend
	fi
}

# @FUNCTION: mate_pkg_preinst
# @DESCRIPTION:
# Finds Icons, MateConf and GSettings schemas for later handling in pkg_postinst
mate_pkg_preinst() {
	mate_gconf_collect
	mate_icon_savelist
	mate_schemas_savelist
	mate_scrollkeeper_savelist
}

# @FUNCTION: mate_pkg_postinst
# @DESCRIPTION:
# Handle scrollkeeper, MateConf, GSettings, Icons, desktop and mime
# database updates.
mate_pkg_postinst() {
	mate_gconf_install
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	mate_icon_cache_update
	mate_schemas_update
	mate_scrollkeeper_update
}

# @FUNCTION: mate_pkg_postrm
# @DESCRIPTION:
# Handle scrollkeeper, MateConf, GSettings, Icons, desktop and
# mime database updates.
mate_pkg_postrm() {
	mate_gconf_uninstall
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	mate_icon_cache_update
	mate_schemas_update
	mate_scrollkeeper_update
}
