# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: media-sound/oss/oss-4.2.2009.ebuild,v 1.6 2014/08/08 20:31:48 -tclover Exp $

EAPI=5

inherit eutils flag-o-matic libtool versionator

MY_PV=$(get_version_component_range 1-2)
MY_B=$(get_version_component_range 3)
MY_P=${PN}-v${MY_PV}-build${MY_B}-src-gpl

DESCRIPTION="OSSv4 portable, mixing-capable, high quality sound system for Unix"
HOMEPAGE="http://developer.opensound.com/"
SRC_URI="http://www.4front-tech.com/developer/sources/stable/gpl/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

AUDIO_CARDS=( ali5455 atiaudio audigyls audioloop audiopci cmi878x cmpci cs4281
cs461x digi96 emu10k1x envy24 envy24ht fmedia geode hdaudio ich imux madi midiloop
midimix sblive sbpci sbxfi solo trident usb userdev via823x via97 ymf7xx )
DEFAULT_CARDS=( hdaudio ich imux midiloop midimix )

for card in ${AUDIO_CARDS[@]}; do
	has ${card} ${DEFAULT_CARDS[@]} &&
	CARDS=(${CARDS[@]} +oss_cards_${card}) ||
	CARDS=(${CARDS[@]} oss_cards_${card})
done

IUSE="alsa +midi pax_kernel ${CARDS[@]}"
REQUIRED_USE="oss_cards_midiloop? ( midi ) oss_cards_midimix? ( midi )
	|| ( ${CARDS[@]//+} )"
unset CARDS

DEPEND="sys-apps/gawk
	x11-libs/gtk+:2
	>=sys-kernel/linux-headers-2.6.11
	!media-sound/oss-devel"

RDEPEND="${DEPEND}"

S="${WORKDIR}"/${MY_P}
unset MY_{B,P,PV}

src_prepare() {
	cp "${FILESDIR}"/oss.initd "${S}"/setup/Linux/oss/etc/S89oss
	epatch "${FILESDIR}"/${PN}-${PV}-linux.patch
	use pax_kernel && epatch "${FILESDIR}"/pax_kernel.patch

	elibtoolize
}

src_configure() {
	local drv=osscore
	for card in ${AUDIO_CARDS[@]}; do
	if use oss_cards_${card} ||
		has ${card} ${OSS_CARDS} || has ${card} ${DEFAULT_CARDS[@]};then
			drv+=,oss_${card}
		fi
	done

	local myconfargs=(
		$(use alsa || echo '--enable-libsalsa=NO')
		$(use midi && echo '--config-midi=YES' || echo '--config-midi=NO')
		--only-drv=$drv
	)
	mkdir -p ../build && pushd ../build
	"${S}"/configure "${myconfargs[@]}"
}

src_compile() {
	pushd ../build
	emake build
}

src_install() {
	pushd ../build
	cp -a prototype/* "${D}" || die

	# install a pkgconfig file and make symlink to standard library dir
	newinitd "${FILESDIR}"/oss.initd oss
	local libdir=$(get_libdir)
	insinto /usr/${libdir}/pkgconfig
	doins "${FILESDIR}"/OSSlib.pc
	dosym /usr/${libdir}/{oss/lib/,}libOSSlib.so
	dosym /usr/${libdir}/{oss/lib/,}libossmix.so
	use alsa && dosym /usr/${libdir}/{oss/lib/,}libsalsa.so.2.0.0
	dosym /usr/${libdir}/oss/include /usr/include/oss
}

pkg_postinst() {
	elog ""
	elog "To use ${P} for the first time you must run: \`/etc/init.d/oss start'"
	elog "If you are upgrading, run: \`/etc/init.d/oss restart'"
	elog ""
}
