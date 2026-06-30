# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11,12,13,14} )

inherit gnome2-utils meson python-single-r1 xdg

DESCRIPTION="Make your screenshots ready for all"
HOMEPAGE="
	https://gradia.alexandervanhee.be/
	https://github.com/AlexanderVanhee/Gradia
"
SRC_URI="https://github.com/AlexanderVanhee/Gradia/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Gradia-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+ocr"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/glib:2
	>=dev-libs/libportal-0.7[gtk,introspection]
	>=gui-libs/gtk-4.12:4[introspection]
	>=gui-libs/libadwaita-1.5[introspection]
	gui-libs/gtksourceview:5[introspection]
	$(python_gen_cond_dep '
		>=dev-python/pygobject-3.48[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP},webp,avif,jpeg,tiff]
		ocr? ( dev-python/pytesseract[${PYTHON_USEDEP}] )
	')
	ocr? ( app-text/tesseract )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-util/blueprint-compiler
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	default

	# Replace hardcoded Flatpak OCR paths with Gentoo system paths so
	# OCR works on a regular system installation.
	sed -i \
		-e "s|/app/bin/tesseract|/usr/bin/tesseract|" \
		-e "s|/app/share/tessdata|/usr/share/tessdata|" \
		meson.build || die
}

src_configure() {
	local emesonargs=(
		-Denable-ocr=$(usex ocr true false)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	python_fix_shebang "${ED}"/usr/bin/gradia
	python_optimize "${ED}"/usr/share/gradia
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
