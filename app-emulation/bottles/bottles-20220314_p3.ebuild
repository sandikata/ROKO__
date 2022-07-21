# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit optfeature gnome2-utils python-single-r1 meson xdg

DESCRIPTION="Easily manage WINE prefixes in a new way"
HOMEPAGE="
	https://usebottles.com/
	https://github.com/bottlesdevs/Bottles
"

LICENSE="GPL-3+"
SLOT="0"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/bottlesdevs/${PN^}.git"
else
	VERSION_CODENAME="trento"
	year="${PV::4}" month="${PV:4:2}" day="${PV:6:2}" patch="${PV:10:1}"
	MY_PV="${year}.${month#0}.${day#0}-${VERSION_CODENAME}${patch:+"-${patch}"}"
	SRC_URI="https://github.com/bottlesdevs/${PN^}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
	S="${WORKDIR}/${PN^}-${MY_PV}"
fi

RESTRICT="mirror !test? ( test )"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
PROPERTIES="test_network"

# Dependencies adapted from AppImageBuilder.yml, omitted selinux others might be redundant as well.
DEPEND="
	${PYTHON_DEPS}
	>=x11-libs/gtk+-3.24.10[introspection]
	dev-libs/appstream-glib[introspection]
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP},cairo]
	')
"
BDEPEND="
	test? (
		dev-libs/appstream
		dev-libs/glib
		dev-util/desktop-file-utils
	)
"
RDEPEND="
	${DEPEND}
	app-arch/bzip2
	app-arch/cabextract
	app-arch/p7zip
	app-i18n/ibus
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libffi
	dev-libs/libgee
	dev-libs/libgpg-error
	dev-libs/libpcre:3
	gnome-base/dconf
	gnome-base/gsettings-desktop-schemas
	gnome-base/librsvg:2
	gui-libs/libhandy:1[introspection]
	media-libs/freetype
	media-libs/libcanberra[gtk3]
	media-libs/vulkan-loader
	net-fs/samba[winbind]
	net-libs/gnutls
	net-libs/webkit-gtk:4
	sys-libs/zlib
	sys-process/procps
	x11-apps/xdpyinfo
	x11-libs/gtksourceview:4
	x11-libs/libnotify[introspection]
	virtual/opengl
	amd64? (
		media-libs/freetype[abi_x86_32(-)]
		media-libs/vulkan-loader[abi_x86_32(-)]
		net-libs/gnutls[abi_x86_32(-)]
		sys-libs/glibc[multilib(-)]
		virtual/opengl[abi_x86_32(-)]
	)
	$(python_gen_cond_dep '
		app-arch/patool[${PYTHON_USEDEP}]
		dev-python/certifi[${PYTHON_USEDEP}]
		dev-python/markdown[${PYTHON_USEDEP}]
		dev-python/requests[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]

	')
"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	eapply_user

	if [[ "${PV}" == *9999* ]]; then
		# https://github.com/bottlesdevs/Bottles#notices-for-package-maintainers
		sed -i "s/\(.*\)/\1-$(git rev-parse --short HEAD)/" "${S}/VERSION" || die
	fi

	sed -i \
		"s:^\(conf.set('PYTHON',\).*$:\1 '/usr/bin/${EPYTHON}'):" \
		"${S}/src/meson.build" || die
}

src_install() {
	meson_src_install
	python_optimize "${D}/usr/share/bottles/"
}

pkg_preinst() {
	xdg_pkg_preinst
	gnome2_schemas_savelist
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
	optfeature "gamemode support" games-util/gamemode
}
