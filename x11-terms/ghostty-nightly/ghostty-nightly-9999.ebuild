# Copyright 2026 Rosen Aleksandrov
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Fast, feature-rich, and cross-platform terminal emulator"
HOMEPAGE="https://ghostty.org/ https://github.com/ghostty-org/ghostty"

# master изисква Zig 0.17.0 (minimum_zig_version в build.zig.zon).
# zig.eclass търси инсталиран zig в този слот (zig или zig-bin).
ZIG_SLOT="0.17"
ZIG_NEEDS_LLVM=1
inherit git-r3 zig xdg

EGIT_REPO_URI="https://github.com/ghostty-org/ghostty.git"

# Build стъпките на Ghostty (напр. generate_gresource_xml) ползват пътища
# като src/apprt/gtk/css/style.css спрямо текущата директория, т.е.
# zig build трябва да се пуска от корена на сорса, а не от ${P}-build.
BUILD_DIR="${WORKDIR}/${P}"

LICENSE="Apache-2.0 BSD BSD-2 BSD-4 Boost-1.0 MIT MPL-2.0 Unicode-3.0"
SLOT="0"
# live ebuild: без KEYWORDS

# Зависимостите на zig не са фиксирани (няма ZBS_DEPENDENCIES като в
# 1.3.1), затова се теглят по време на src_unpack.
RESTRICT="network-sandbox"

# Същите като в x11-terms/ghostty-1.3.1 от ::gentoo.
# TODO: сверете версиите с master (harfbuzz, highway, glslang...).
COMMON_DEPEND="
	>=dev-libs/oniguruma-6.9.9:=
	>=dev-util/glslang-1.3.296.0:=
	gui-libs/gtk:4=[X?]
	gui-libs/libadwaita:1=
	>=media-libs/fontconfig-2.14.2:=
	>=media-libs/freetype-2.13.2:=[bzip2,harfbuzz,png]
	>=media-libs/harfbuzz-12.2.0:=[truetype,introspection]
	>=dev-cpp/highway-1.3.0:=
	X? ( x11-libs/libX11 )
	wayland? (
		dev-libs/wayland
		gui-libs/gtk4-layer-shell:=
	)
	nls? ( virtual/libintl )
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="
	${COMMON_DEPEND}
	!x11-terms/ghostty-terminfo
"
BDEPEND="
	|| (
		>=dev-lang/zig-bin-0.17.0:${ZIG_SLOT}
		>=dev-lang/zig-0.17.0:${ZIG_SLOT}
	)
	man? ( virtual/pandoc )
	nls? ( sys-devel/gettext )
"

IUSE="X wayland man nls"
REQUIRED_USE="
	|| ( X wayland )
"

src_prepare() {
	# На Gentoo библиотеката е libbz2 (-lbz2), а не libbzip2. Същото прави
	# ghostty-1.3.0-bzip2-dependency.patch от ::gentoo, но кодът на master
	# вече е различен (root_module.linkSystemLibrary), затова се ползва sed.
	sed -i 's/linkSystemLibrary("bzip2"/linkSystemLibrary("bz2"/' \
		src/build/SharedDeps.zig || die
	grep -q 'linkSystemLibrary("bz2"' src/build/SharedDeps.zig \
		|| die "bzip2 -> bz2 substitution did not match"

	zig_src_prepare
}

pkg_setup() {
	# zig-utils.eclass търси Zig по твърд списък с версии, в който още
	# няма 0.17.x, затова намираме инсталацията сами (zig или zig-bin) и
	# подаваме ZIG_EXE/ZIG_VER. zig_pkg_setup пропуска търсенето, ако
	# ZIG_EXE е зададен. Махни това, когато eclass-ът научи 0.17.
	if [[ ${MERGE_TYPE} != binary ]]; then
		local exe
		for exe in "${BROOT}"/usr/bin/zig{,-bin}-${ZIG_SLOT}.*; do
			if [[ -x ${exe} ]]; then
				ZIG_EXE=${exe}
				ZIG_VER=${exe##*-}
				break
			fi
		done
		[[ -n ${ZIG_EXE} ]] || die "Could not find Zig ${ZIG_SLOT} in ${BROOT}/usr/bin"
	fi

	zig_pkg_setup

	# Zig 0.17 добави в libc файла полетата cc_dir (директорията с
	# crtbeginS.o/crtendS.o на компилатора, задължително за Linux) и
	# darwin_sdk_dir (празно за Linux), а zig.eclass още не ги генерира.
	if [[ ${MERGE_TYPE} != binary ]]; then
		local crtbegin
		crtbegin=$($(tc-getCC) ${CFLAGS} -print-file-name=crtbeginS.o) || die
		[[ ${crtbegin} == /* ]] || die "Could not locate crtbeginS.o with $(tc-getCC)"

		cat >> "${T}/zig_libc.txt" <<-_EOF_ || die "Failed to patch zig_libc.txt"
			cc_dir=${crtbegin%/*}
			darwin_sdk_dir=
		_EOF_
	fi
}

src_unpack() {
	git-r3_src_unpack

	# За Zig 0.16+ zig.eclass има zig_live_src_unpack: добавя
	# --build-file "${S}/build.zig" към ZBS_ARGS_BASE и тегли всички
	# зависимости с `zig build --fetch=all`.
	zig_live_src_unpack
}

src_configure() {
	# Ghostty парсва -Dversion-string като semver (major.minor.patch),
	# затова "9999-<commit>" не става. Вземаме базовата версия от
	# build.zig.zon и добавяме -dev+<commit>.
	local base_ver
	base_ver=$(sed -n 's/^[[:space:]]*\.version = "\([0-9][0-9.]*\)[^"]*".*/\1/p' \
		"${S}/build.zig.zon" | head -n1)
	[[ ${base_ver} =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
		|| die "Could not parse .version from build.zig.zon (got '${base_ver}')"

	local my_zbs_args=(
		# XXX: без ReleaseFast Ghostty показва debug banner.
		--release=fast

		-Dapp-runtime=gtk
		-Dfont-backend=fontconfig_freetype
		-Drenderer=opengl
		-Dsimd=true
		-Dgtk-x11=$(usex X true false)
		-Dgtk-wayland=$(usex wayland true false)
		-Di18n=$(usex nls true false)
		-Demit-docs=$(usex man true false)
		-Dstrip=false
		-Dversion-string="${base_ver}-dev+${EGIT_VERSION:0:8}"
		-Demit-terminfo=true
		-Demit-termcap=true
		# https://github.com/mbadolato/iTerm2-Color-Schemes/issues/638
		-Demit-themes=false

		-fsys=freetype
		-fsys=harfbuzz
		-fsys=fontconfig
		-fsys=libpng
		-fsys=zlib
		-fsys=oniguruma
		-fsys=glslang
		-fsys=gtk4-layer-shell
		-fsys=highway

		# няма Gentoo пакети
		-fno-sys=spirv-cross
		-fno-sys=simdutf
	)

	zig_src_configure
}

src_install() {
	# 9999 инсталира собствен /usr/share/terminfo/x/xterm-ghostty
	# (-Demit-terminfo=false на master не го спира). Колизията с
	# x11-terms/ghostty-terminfo (само 1.3.1) се решава от блокера
	# !x11-terms/ghostty-terminfo в RDEPEND.
	zig_src_install

	# QA: bash completion файлът трябва да се казва като командата.
	local bashcomp="${ED}/usr/share/bash-completion/completions"
	if [[ -f ${bashcomp}/ghostty.bash ]]; then
		mv "${bashcomp}/ghostty.bash" "${bashcomp}/ghostty" || die
	fi
}

src_test() {
	# XXX: тестовете на Ghostty изискват Debug режим.
	local my_zbs_args=("${ZBS_ARGS[@]}")
	for i in "${!my_zbs_args[@]}"; do
		if [[ "${my_zbs_args[i]}" =~ --release=* ]]; then
			unset 'my_zbs_args[i]'
		fi
	done

	DESTDIR="${BUILD_DIR}" nonfatal ezig build test "${my_zbs_args[@]}" \
		|| die "Running tests failed!"
}
