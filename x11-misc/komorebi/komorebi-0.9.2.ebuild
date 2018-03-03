# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils eutils autotools flag-o-matic

DESCRIPTION="A beautiful, customizable wallpapers manager for Kedos."
HOMEPAGE="https://github.com/iabem97/komorebi"
SRC_URI="https://github.com/iabem97/${PN}/archive/${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	=dev-lang/vala-0.34* 
	dev-libs/glib:2
	dev-util/cmake 
	gnome-base/libgtop 
	x11-libs/gtk+:3
"
RDEPEND="${DEPEND}"

src_prepare() { 

	# apparently Gentoo doesnt symlink valac-version into valac, we have to search 
	# for it manually so CMake can find it. 
	sed -i 's/NAMES valac/NAMES valac-0.34/g' cmake/FindVala.cmake || die "Sedding FindVala.cmake failed"

	# CMake cant find library files, dont know a better approach
	# maybe fixed in 0.9.2
	# append-cflags "`pkg-config --cflags --libs glib-2.0 gtk+-3.0 libgtop-2.0`"

	# By default this program uses an ugly directory hierarchy, and doesnt 
	# respect DCMAKE_INSTALL_PREFIX so lets try to manually fix it.
	sed -i 's|/System/Applications/|/usr/bin/|g' CMakeLists.txt
	sed -i 's|/System/Resources/Komorebi|/usr/share/komorebi|g' CMakeLists.txt
	sed -i '/$ENV{HOME}/d' CMakeLists.txt

	# These paths are also hardcoded into some source files
	sed -i 's|/System/Resources/Komorebi|/usr/share/komorebi|g' src/OnScreen/InfoBox.vala
	sed -i 's|/System/Resources/Komorebi|/usr/share/komorebi|g' src/OnScreen/BackgroundWindow.vala
	sed -i 's|/System/Resources/Komorebi|/usr/share/komorebi|g' src/OnScreen/PreferencesWindow.vala

	default

}

src_configure() { 

	mycmakeargs=(
		${mycmakeargs} 
		-DCMAKE_INSTALL_PREFIX="/usr"
	)

	cmake-utils_src_configure 

}

src_install() { 

	cmake-utils_src_install

}

