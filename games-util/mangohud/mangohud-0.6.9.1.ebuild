# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..11} )
MY_PV="0.6.9-1"

inherit meson distutils-r1 multilib-minimal flag-o-matic git-r3

DESCRIPTION="A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more. AMDGPU testing branch"
HOMEPAGE="https://github.com/flightlessmango/MangoHud"

EGIT_REPO_URI="https://github.com/flightlessmango/MangoHud.git"
if [[ ${PV} == "9999" ]]; then
	SRC_URI="
    	https://github.com/ocornut/imgui/archive/v1.81.tar.gz -> imgui-1.81.tar.gz
    	https://wrapdb.mesonbuild.com/v1/projects/imgui/1.81/1/get_zip -> imgui_wrap-1.81.zip
    	https://github.com/nlohmann/json/releases/download/v3.10.5/include.zip -> nlohmann_json-3.10.5.zip
    	https://github.com/gabime/spdlog/archive/v1.8.5.tar.gz -> spdlog-1.8.5.tar.gz
    	https://wrapdb.mesonbuild.com/v2/spdlog_1.8.5-1/get_patch -> spdlog-1.8.5-1-wrap.zip
    	https://github.com/KhronosGroup/Vulkan-Headers/archive/v1.2.158.tar.gz -> vulkan-headers-1.2.158.tar.gz
    	https://wrapdb.mesonbuild.com/v2/vulkan-headers_1.2.158-2/get_patch -> vulkan-headers-1.2.158-2-wrap.zip
	"
else
	SRC_URI="
    	https://github.com/ocornut/imgui/archive/v1.81.tar.gz -> imgui-1.81.tar.gz
    	https://wrapdb.mesonbuild.com/v1/projects/imgui/1.81/1/get_zip -> imgui_wrap-1.81.zip
    	https://github.com/nlohmann/json/releases/download/v3.10.5/include.zip -> nlohmann_json-3.10.5.zip
    	https://github.com/gabime/spdlog/archive/v1.8.5.tar.gz -> spdlog-1.8.5.tar.gz
    	https://wrapdb.mesonbuild.com/v2/spdlog_1.8.5-1/get_patch -> spdlog-1.8.5-1-wrap.zip
    	https://github.com/KhronosGroup/Vulkan-Headers/archive/v1.2.158.tar.gz -> vulkan-headers-1.2.158.tar.gz
    	https://wrapdb.mesonbuild.com/v2/vulkan-headers_1.2.158-2/get_patch -> vulkan-headers-1.2.158-2-wrap.zip
	"
	EGIT_COMMIT="v${MY_PV}"
	KEYWORDS="-* ~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+dbus glvnd +X xnvctrl wayland -video_cards_nvidia +video_cards_amdgpu"
REQUIRED_USE="
	xnvctrl? ( video_cards_nvidia )
"

BDEPEND="
	dev-python/mako[${PYTHON_USEDEP}]
	dev-util/ninja
"
DEPEND="
	!games-util/mangohud
	media-libs/glfw
	dev-util/glslang
	media-libs/vulkan-loader[${MULTILIB_USEDEP}]
	video_cards_amdgpu? (
		x11-libs/libdrm[video_cards_amdgpu]
	)
	glvnd? (
		media-libs/libglvnd[${MULTILIB_USEDEP}]
	)
	dbus? ( sys-apps/dbus[${MULTILIB_USEDEP}] )
	X? ( x11-libs/libX11[${MULTILIB_USEDEP}] )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[${MULTILIB_USEDEP}]
		xnvctrl? ( x11-drivers/nvidia-drivers[static-libs] )
	)
	wayland? ( dev-libs/wayland[${MULTILIB_USEDEP}] )
"

RDEPEND="${DEPEND}"

src_unpack() {
	git-r3_src_unpack
	default

	mv imgui-1.81 ${S}/subprojects
	mv spdlog-1.8.5 ${S}/subprojects
	mv Vulkan-Headers-1.2.158 ${S}/subprojects

	mkdir ${S}/subprojects/nlohmann_json-3.10.5
	mv {single_,}include LICENSE.MIT meson.build ${S}/subprojects/nlohmann_json-3.10.5
}
multilib_src_configure() {
	local emesonargs=(
		-Dappend_libdir_mangohud=false
		-Dinclude_doc=false
		$(meson_feature video_cards_nvidia with_nvml)
		$(meson_feature xnvctrl with_xnvctrl)
		$(meson_feature X with_x11)
		$(meson_feature wayland with_wayland)
		$(meson_feature dbus with_dbus)
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
	dodoc "${S}/data/MangoHud.conf"

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
