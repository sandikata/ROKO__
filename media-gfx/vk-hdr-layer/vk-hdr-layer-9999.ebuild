# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 meson

DESCRIPTION="Vulkan Wayland HDR WSI Layer"
HOMEPAGE="https://github.com/Zamundaaa/VK_hdr_layer"
EGIT_REPO_URI="https://github.com/Zamundaaa/VK_hdr_layer.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	x11-libs/libX11
	dev-util/vulkan-headers
	media-libs/vulkan-loader
	dev-libs/wayland
"
RDEPEND="${DEPEND}"
BDEPEND=""
