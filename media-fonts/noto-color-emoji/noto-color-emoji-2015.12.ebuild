# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit font

DESCRIPTION="Noto emoji color"
HOMEPAGE="https://www.google.com/get/noto/#emoji-qaae-color"
SRC_URI="https://dev.gentoo.org/~tranquility/distfiles/${P}.zip"
# renamed from upstream's unversioned NotoColorEmoji-unhinted.zip
# version number based on the timestamp of most recently updated file in the zip

S="${WORKDIR}"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"

FONT_SUFFIX="ttf"
