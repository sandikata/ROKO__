# Distributed under the terms of the GNU General Public License, v2 or later
# Author Mauro Toffanin <toffanin.mauro@gmail.com>
# $Header: $
inherit eutils

# show overlay warnings
overlay_pkg_setup() {

	echo
	einfo "This ebuild is provided from the \`${OVERLAY_NAME}\`"
	einfo "and is not part of the Gentoo portage project."
	echo
	ewarn "The soft/hard masked ebuilds that come from this repository"
	ewarn "are not always in perfect condition and may break things,"
	ewarn "so please use at your own risk and NEVER USE THEM unless"
	ewarn "YOU KNOW exactly WHAT ARE YOU DOING."
	echo
	einfo "If you have troubles/problems with this ebuild,"
	einfo "please contact the ebuild maintainer and not"
	einfo "the good people at Gentoo, so please"
	ewarn "NEVER REPORT BUGS AT http://bugs.gentoo.org"
	ewarn "instead use the proper bugzilla:"
	ewarn
	ewarn "  ${OVERLAY_BUGZILLA}"
	ebeep 3
	echo
}

EXPORT_FUNCTIONS pkg_setup