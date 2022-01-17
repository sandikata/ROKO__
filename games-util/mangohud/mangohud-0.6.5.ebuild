# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )

inherit meson distutils-r1 multilib-minimal flag-o-matic

DESCRIPTION="A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more."
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

IMGUI_VER="1.81"

IMGUI_SRC_URI="
	https://github.com/ocornut/imgui/archive/v${IMGUI_VER}.tar.gz -> ${PN}-imgui-${IMGUI_VER}.tar.gz
	https://wrapdb.mesonbuild.com/v1/projects/imgui/${IMGUI_VER}/1/get_zip -> ${PN}-imgui-wrap-${IMGUI_VER}.zip
"

if [[ ${PV} == "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/flightlessmango/MangoHud.git"
	SRC_URI="${IMGUI_SRC_URI}"
else
	SRC_URI="
		https://github.com/flightlessmango/MangoHud/archive/v${PV}.tar.gz -> ${P}.tar.gz
		${IMGUI_SRC_URI}
	"
	KEYWORDS="-* ~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+dbus debug +X xnvctrl wayland video_cards_nvidia"

REQUIRED_USE="
	^^ ( X wayland )
	xnvctrl? ( video_cards_nvidia )"

BDEPEND="dev-python/mako[${PYTHON_USEDEP}]"

DEPEND="
	dev-util/glslang
	>=dev-util/vulkan-headers-1.2
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	media-libs/libglvnd[$MULTILIB_USEDEP]
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	X? ( x11-libs/libX11[${MULTILIB_USEDEP}] )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[${MULTILIB_USEDEP}]
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? ( dev-libs/wayland[${MULTILIB_USEDEP}] )"

RDEPEND="${DEPEND}"

if ! [[ ${PV} == "9999" ]]; then
	S="${WORKDIR}"/MangoHud-${PV}
fi

src_unpack() {
	git-r3_src_unpack
	default
}

src_prepare() {
	# Both imgui archives use the same folder name, so we don't need
	# to rename anything. Just move the folders to the appropriate location.
	mv "${WORKDIR}/imgui-${IMGUI_VER}" "${S}/subprojects" || die

	eapply_user
}

multilib_src_configure() {
	local emesonargs=(
		-Dappend_libdir_mangohud=false
		-Duse_system_vulkan=enabled
		-Dinclude_doc=false
		-Dwith_nvml=$(usex video_cards_nvidia enabled disabled)
		-Dwith_xnvctrl=$(usex xnvctrl enabled disabled)
		-Dwith_x11=$(usex X enabled disabled)
		-Dwith_wayland=$(usex wayland enabled disabled)
		-Dwith_dbus=$(usex dbus enabled disabled)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	dodoc "${S}/bin/MangoHud.conf"

	einstalldocs
}

pkg_postinst() {
	if ! use xnvctrl; then
		einfo ""
		einfo "If mangohud can't get GPU load, or other GPU information,"
		einfo "and you have an older Nvidia device."
		einfo ""
		einfo "Try enabling the 'xnvctrl' useflag."
		einfo ""
	fi
}
