# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit font check-reqs

DESCRIPTION="Collection of fonts that are patched to include a high number of glyphs (icons)."
HOMEPAGE="https://nerdfonts.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DIRNAME=(
	3270
	Agave
	AnonymousPro
	Arimo
	AurulentSansMono
	BigBlueTerminal
	BitstreamVeraSansMono
	CascadiaCode
	CodeNewRoman
	Cousine
	DaddyTimeMono
	DejaVuSansMono
	DroidSansMono
	FantasqueSansMono
	FiraCode
	FiraMono
	Go-Mono
	Gohu
	Hack
	Hasklig
	HeavyData
	Hermit
	iA-Writer
	IBMPlexMono
	Inconsolata
	InconsolataGo
	InconsolataLGC
	Iosevka
	JetBrainsMono
	Lekton
	LiberationMono
	Meslo
	Monofur
	Monoid
	Mononoki
	MPlus
	Noto
	OpenDyslexic
	Overpass
	ProFont
	ProggyClean
	RobotoMono
	ShareTechMono
	SourceCodePro
	SpaceMono
	Terminus
	Tinos
	Ubuntu
	UbuntuMono
	VictorMono
)

IUSE_FLAGS=(${DIRNAME[*],,})
IUSE="${IUSE_FLAGS[*]}"
REQUIRED_USE="X || ( ${IUSE_FLAGS[*]} )"

MY_URI="https://github.com/ryanoasis/${PN}/releases/download/v${PV}"
SRC_URI="3270?            ( "${MY_URI}/3270.zip" )
	agave?                  ( "${MY_URI}/Agave.zip" )
	anonymouspro?           ( "${MY_URI}/AnonymousPro.zip" )
	arimo?                  ( "${MY_URI}/Arimo.zip" )
	aurulentsansmono?       ( "${MY_URI}/AurulentSansMono.zip" )
	bigblueterminal?        ( "${MY_URI}/BigBlueTerminal.zip" )
	bitstreamverasansmono?  ( "${MY_URI}/BitstreamVeraSansMono.zip" )
	cascadiacode?           ( "${MY_URI}/CascadiaCode.zip" )
	codenewroman?           ( "${MY_URI}/CodeNewRoman.zip" )
	cousine?                ( "${MY_URI}/Cousine.zip" )
	daddytimemono?          ( "${MY_URI}/DaddyTimeMono.zip" )
	dejavusansmono?         ( "${MY_URI}/DejaVuSansMono.zip" )
	droidsansmono?          ( "${MY_URI}/DroidSansMono.zip" )
	fantasquesansmono?      ( "${MY_URI}/FantasqueSansMono.zip" )
	firacode?               ( "${MY_URI}/FiraCode.zip" )
	firamono?               ( "${MY_URI}/FiraMono.zip" )
	go-mono?                ( "${MY_URI}/Go-Mono.zip" )
	gohu?                   ( "${MY_URI}/Gohu.zip" )
	hack?                   ( "${MY_URI}/Hack.zip" )
	hasklig?                ( "${MY_URI}/Hasklig.zip" )
	heavydata?              ( "${MY_URI}/HeavyData.zip" )
	hermit?                 ( "${MY_URI}/Hermit.zip" )
	ia-writer?              ( "${MY_URI}/iA-Writer.zip" )
	ibmplexmono?            ( "${MY_URI}/IBMPlexMono.zip" )
	inconsolata?            ( "${MY_URI}/Inconsolata.zip" )
	inconsolatago?          ( "${MY_URI}/InconsolataGo.zip" )
	inconsolatalgc?         ( "${MY_URI}/InconsolataLGC.zip" )
	iosevka?                ( "${MY_URI}/Iosevka.zip" )
	jetbrainsmono?          ( "${MY_URI}/JetBrainsMono.zip" )
	lekton?                 ( "${MY_URI}/Lekton.zip" )
	liberationmono?         ( "${MY_URI}/LiberationMono.zip" )
	meslo?                  ( "${MY_URI}/Meslo.zip" )
	monofur?                ( "${MY_URI}/Monofur.zip" )
	monoid?                 ( "${MY_URI}/Monoid.zip" )
	mononoki?               ( "${MY_URI}/Mononoki.zip" )
	mplus?                  ( "${MY_URI}/MPlus.zip" )
	noto?                   ( "${MY_URI}/Noto.zip" )
	opendyslexic?           ( "${MY_URI}/OpenDyslexic.zip" )
	overpass?               ( "${MY_URI}/Overpass.zip" )
	profont?                ( "${MY_URI}/ProFont.zip" )
	proggyclean?            ( "${MY_URI}/ProggyClean.zip" )
	robotomono?             ( "${MY_URI}/RobotoMono.zip" )
	sharetechmono?          ( "${MY_URI}/ShareTechMono.zip" )
	sourcecodepro?          ( "${MY_URI}/SourceCodePro.zip" )
	spacemono?              ( "${MY_URI}/SpaceMono.zip" )
	terminus?               ( "${MY_URI}/Terminus.zip" )
	tinos?                  ( "${MY_URI}/Tinos.zip" )
	ubuntu?                 ( "${MY_URI}/Ubuntu.zip" )
	ubuntumono?             ( "${MY_URI}/UbuntuMono.zip" )
	victormono?             ( "${MY_URI}/VictorMono.zip" )
"

DEPEND="app-arch/unzip"
RDEPEND="media-libs/fontconfig"

CHECKREQS_DISK_BUILD="3G"
CHECKREQS_DISK_USR="4G"

S="${WORKDIR}"
FONT_CONF=(
	"${FILESDIR}"/10-nerd-font-symbols.conf
)
FONT_S=${S}

pkg_pretend() {
	check-reqs_pkg_setup
}
src_install() {
	declare -A font_filetypes
	local otf_file_number ttf_file_number

	otf_file_number=$(ls ${S} | grep -i otf | wc -l)
	ttf_file_number=$(ls ${S} | grep -i ttf | wc -l)

	if [[ ${otf_file_number} != 0 ]]; then
		font_filetypes[otf]=
	fi

	if [[ ${ttf_file_number} != 0 ]]; then
		font_filetypes[ttf]=
	fi

	FONT_SUFFIX="${!font_filetypes[@]}"

	font_src_install
}

pkg_postinst() {
	einfo "Installing font-patcher via an ebuild is hard, because paths are hardcoded differently"
	einfo "in .sh files. You can still get it and use it by git cloning the nerd-font project and"
	einfo "running it from the cloned directory."
	einfo "https://github.com/ryanoasis/nerd-fonts"

	elog "You might have to enable 50-user.conf and 10-nerd-font-symbols.conf by using"
	elog "eselect fontconfig"
}
