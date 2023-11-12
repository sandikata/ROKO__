# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="A vulkan post processing layer for linux"
HOMEPAGE="https://github.com/DadSchoorse/vkBasalt"
SRC_URI="https://github.com/DadSchoorse/vkBasalt/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64"

# No tests
RESTRICT="test"

CDEPEND="x11-libs/libX11"
DEPEND="
	${CDEPEND}
	dev-util/spirv-headers
	dev-util/vulkan-headers
"
RDEPEND="${CDEPEND}"
BDEPEND="dev-util/glslang"
