# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
GNOME2_LA_PUNT="yes" # Needed with USE 'sendto'

inherit gnome2 readme.gentoo-r1 versionator meson

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Nautilus"

LICENSE="GPL-2+ LGPL-2+ FDL-1.1"
SLOT="0"
KEYWORDS="*"

IUSE="exif gnome +introspection packagekit +previewer selinux sendto vanilla-menu vanilla-menu-compress vanilla-rename vanilla-search vanilla-thumbnailer xmp"

# FIXME: tests fails under Xvfb, but pass when building manually
# "FAIL: check failed in nautilus-file.c, line 8307"
# need org.gnome.SessionManager service (aka gnome-session) but cannot find it
RESTRICT="test"

# Require {glib,gdbus-codegen}-2.30.0 due to GDBus API changes between 2.29.92
# and 2.30.0
COMMON_DEPEND="
	>=app-arch/gnome-autoar-0.2.1
	>=dev-libs/glib-2.51.2:2[dbus]
	>=x11-libs/pango-1.28.3
	>=x11-libs/gtk+-3.21.6:3[introspection?]
	>=dev-libs/libxml2-2.7.8:2
	>=gnome-base/gnome-desktop-3:3=

	gnome-base/dconf
	>=gnome-base/gsettings-desktop-schemas-3.8.0
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrender

	exif? ( >=media-libs/libexif-0.6.20 )
	introspection? ( >=dev-libs/gobject-introspection-0.6.4:= )
	selinux? ( >=sys-libs/libselinux-2 )
	xmp? ( >=media-libs/exempi-2.1.0:2 )
"
DEPEND="${COMMON_DEPEND}
	>=dev-lang/perl-5
	>=dev-util/gdbus-codegen-2.33
	>=dev-util/gtk-doc-am-1.10
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
	x11-proto/xproto
	app-misc/tracker
"
RDEPEND="${COMMON_DEPEND}
	packagekit? ( app-admin/packagekit-base )
	sendto? ( !<gnome-extra/nautilus-sendto-3.0.1 )
"

# For eautoreconf
#	gnome-base/gnome-common
#	dev-util/gtk-doc-am"

PDEPEND="
	gnome? ( x11-themes/adwaita-icon-theme )
	previewer? ( >=gnome-extra/sushi-0.1.9 )
	sendto? ( >=gnome-extra/nautilus-sendto-3.0.1 )
	>=gnome-base/gvfs-1.14[gtk]
	>=media-video/totem-$(get_version_component_range 1-2)[vanilla-thumbnailer=]
	!vanilla-thumbnailer? ( media-video/ffmpegthumbnailer )
"
# Need gvfs[gtk] for recent:/// support

src_prepare() {
	if use previewer; then
		DOC_CONTENTS="nautilus uses gnome-extra/sushi to preview media files.
			To activate the previewer, select a file and press space; to
			close the previewer, press space again."
	fi

	# From GNOME:
	# 	https://bugzilla.gnome.org/show_bug.cgi?id=784189
	eapply "${FILESDIR}"/${PN}-3.26.0-dont-explicitly-require-libm.patch

	if ! use vanilla-menu; then
		eapply "${FILESDIR}"/${PN}-3.22.0-reorder-context-menu.patch
		if ! use vanilla-menu-compress; then
			# From GNOME:
			# 	https://gitlab.gnome.org/GNOME/nautilus/commit/cd78b1c9863a25a5fae0f2f7f98ca6d58681cbd6
			# 	https://gitlab.gnome.org/GNOME/nautilus/commit/501ece61be272b575f3e95acd857bb7d8cf93240
			# 	https://gitlab.gnome.org/GNOME/nautilus/commit/1bdc404245da0491b8c5f41eee947aef59f5d73e
			eapply -R "${FILESDIR}"/${PN}-3.25.90-mime-actions-null-check-app-info.patch
			eapply -R "${FILESDIR}"/${PN}-3.25.90-general-remove-spaces-from-desktop-mimetype-list.patch
			eapply -R "${FILESDIR}"/${PN}-3.25.1-general-add-mime-type-support-for-archives.patch

			eapply "${FILESDIR}"/${PN}-3.26.0-disable-automatic-decompression-of-archives.patch
			eapply "${FILESDIR}"/${PN}-3.22.0-remove-native-compress-rebased.patch
		fi
	elif ! use vanilla-menu-compress; then
		# From GNOME:
		# 	https://gitlab.gnome.org/GNOME/nautilus/commit/cd78b1c9863a25a5fae0f2f7f98ca6d58681cbd6
		# 	https://gitlab.gnome.org/GNOME/nautilus/commit/501ece61be272b575f3e95acd857bb7d8cf93240
		# 	https://gitlab.gnome.org/GNOME/nautilus/commit/1bdc404245da0491b8c5f41eee947aef59f5d73e
		eapply -R "${FILESDIR}"/${PN}-3.25.90-mime-actions-null-check-app-info.patch
		eapply -R "${FILESDIR}"/${PN}-3.25.90-general-remove-spaces-from-desktop-mimetype-list.patch
		eapply -R "${FILESDIR}"/${PN}-3.25.1-general-add-mime-type-support-for-archives.patch

		eapply "${FILESDIR}"/${PN}-3.26.0-disable-automatic-decompression-of-archives.patch
		eapply "${FILESDIR}"/${PN}-3.22.0-remove-native-compress.patch
	fi

	if ! use vanilla-rename; then
		eapply "${FILESDIR}"/${PN}-3.26.0-support-slow-double-click-to-rename.patch
	fi

	if ! use vanilla-search; then
		# From Dr. Amr Osman:
		# 	https://bugs.launchpad.net/ubuntu/+source/nautilus/+bug/1164016/comments/31
		eapply "${FILESDIR}"/${PN}-3.26.0-support-alternative-search.patch
	fi

	eapply_user
}

src_configure() {
	local emesonargs=(
		-Denable-exif=$(usex exif true false)
		-Denable-xmp=$(usex xmp true false)
		-Denable-packagekit=$(usex packagekit true false)
		-Denable-nst-extension=$(usex sendto true false)
		-Denable-selinux=$(usex selinux true false)
		-Denable-selinux=$(usex selinux true false)
		-Denable-profiling=false
		-Denable-desktop=true
	)
	meson_src_configure
}

src_install() {
	use previewer && readme.gentoo_create_doc
	meson_src_install
}

pkg_postinst() {
	gnome2_pkg_postinst

	if use previewer; then
		readme.gentoo_print_elog
	else
		elog "To preview media files, emerge nautilus with USE=previewer"
	fi
}
