# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	ab_glyph@0.2.32
	ab_glyph_rasterizer@0.1.10
	adler2@2.0.1
	ahash@0.8.12
	aho-corasick@1.1.4
	aligned-vec@0.6.4
	aligned@0.4.2
	allocator-api2@0.2.21
	android-activity@0.6.0
	android-properties@0.2.2
	anstream@0.6.21
	anstyle-parse@0.2.7
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.13
	anyhow@1.0.100
	arbitrary@1.4.2
	arboard@3.6.1
	arg_enum_proc_macro@0.3.4
	arrayvec@0.7.6
	as-raw-xcb-connection@1.0.1
	as-slice@0.2.1
	ask-cli@0.3.0
	atomic-waker@1.1.2
	autocfg@1.5.0
	av-scenechange@0.14.1
	av1-grain@0.2.5
	avif-serialize@0.8.6
	base64-serde@0.8.0
	base64-simd@0.8.0
	base64@0.22.1
	bit-set@0.8.0
	bit-vec@0.8.0
	bit_field@0.10.3
	bitcode@0.6.7
	bitcode_derive@0.6.7
	bitflags@1.3.2
	bitflags@2.10.0
	bitstream-io@4.9.0
	bitvec@1.0.1
	block2@0.5.1
	bon-macros@3.8.1
	bon@3.8.1
	built@0.8.0
	bumpalo@3.19.0
	bytemuck@1.24.0
	bytemuck_derive@1.10.2
	byteorder-lite@0.1.0
	byteorder@1.5.0
	bytes@1.11.0
	calloop-wayland-source@0.3.0
	calloop-wayland-source@0.4.1
	calloop@0.13.0
	calloop@0.14.3
	camino@1.2.1
	cargo-manifest@0.19.1
	cargo-platform@0.2.0
	cargo-util-schemas@0.8.2
	cargo_metadata@0.21.0
	cassowary@0.3.0
	castaway@0.2.4
	cc@1.2.49
	cesu8@1.1.0
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	cgl@0.3.2
	clap-num@1.2.0
	clap@4.5.53
	clap_builder@4.5.53
	clap_derive@4.5.49
	clap_lex@0.7.6
	clipboard-win@5.4.1
	codespan-reporting@0.12.0
	color_quant@1.1.0
	colorchoice@1.0.4
	combine@4.6.7
	compact_str@0.8.1
	concurrent-queue@2.5.0
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	core-foundation@0.9.4
	core-graphics-types@0.1.3
	core-graphics@0.23.2
	core-text@20.1.0
	core2@0.4.0
	crc32fast@1.5.0
	crossbeam-channel@0.5.15
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crossterm@0.28.1
	crossterm_winapi@0.9.1
	crunchy@0.2.4
	cursor-icon@1.2.0
	cvt@0.1.2
	darling@0.20.11
	darling@0.21.3
	darling_core@0.20.11
	darling_core@0.21.3
	darling_macro@0.20.11
	darling_macro@0.21.3
	dirs-sys@0.5.0
	dirs@6.0.0
	dispatch2@0.3.0
	dispatch@0.2.0
	displaydoc@0.2.5
	dissimilar@1.0.10
	dlib@0.5.2
	document-features@0.2.12
	downcast-rs@1.2.1
	dpi@0.1.2
	dwrote@0.11.5
	ecolor@0.33.3
	eframe@0.33.3
	egui-wgpu@0.33.3
	egui-winit@0.33.3
	egui@0.33.3
	egui_glow@0.33.3
	either@1.15.0
	emath@0.33.3
	env_filter@0.1.4
	env_logger@0.11.8
	epaint@0.33.3
	equator-macro@0.4.2
	equator@0.4.2
	equivalent@1.0.2
	erased-serde@0.4.9
	errno@0.3.14
	error-code@3.3.2
	error-stack@0.6.0
	expect-test@1.5.1
	exr@1.74.0
	fax@0.2.6
	fax_derive@0.2.0
	fdeflate@0.3.7
	find-msvc-tools@0.1.5
	flate2@1.1.5
	float-ord@0.3.2
	fnv@1.0.7
	foldhash@0.1.5
	foldhash@0.2.0
	font-kit@0.14.3
	foreign-types-macros@0.2.3
	foreign-types-shared@0.3.1
	foreign-types@0.5.0
	form_urlencoded@1.2.2
	freetype-sys@0.20.1
	fs_at@0.2.1
	fuc_engine@3.1.1
	funty@2.0.0
	generator@0.8.7
	gethostname@1.1.0
	getrandom@0.2.16
	getrandom@0.3.4
	gif@0.14.1
	gl_generator@0.14.0
	glam@0.30.9
	glow@0.16.0
	glutin-winit@0.5.0
	glutin@0.32.3
	glutin_egl_sys@0.7.1
	glutin_glx_sys@0.6.1
	glutin_wgl_sys@0.6.1
	half@2.7.1
	hashbag@0.1.13
	hashbrown@0.15.5
	hashbrown@0.16.1
	heck@0.5.0
	hermit-abi@0.5.2
	hexf-parse@0.2.1
	icu_collections@2.1.1
	icu_locale_core@2.1.1
	icu_normalizer@2.1.1
	icu_normalizer_data@2.1.1
	icu_properties@2.1.2
	icu_properties_data@2.1.2
	icu_provider@2.1.1
	icy_sixel@0.1.3
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.1
	image-webp@0.2.4
	image@0.25.9
	imgref@1.12.0
	indexmap@2.12.1
	indoc@2.0.7
	instability@0.3.10
	interpolate_name@0.2.4
	io-uring@0.7.11
	is_terminal_polyfill@1.70.2
	itertools@0.13.0
	itertools@0.14.0
	itoa@1.0.15
	jiff-static@0.2.16
	jiff@0.2.16
	jni-sys@0.3.0
	jni@0.21.1
	jobserver@0.1.34
	js-sys@0.3.83
	khronos_api@3.1.0
	lazy_static@1.5.0
	lebe@0.5.3
	libc@0.2.178
	libfuzzer-sys@0.4.10
	libloading@0.8.9
	libm@0.2.15
	libredox@0.1.10
	linux-raw-sys@0.11.0
	linux-raw-sys@0.4.15
	litemap@0.8.1
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.29
	loom@0.7.2
	loop9@0.1.5
	lru@0.12.5
	matchers@0.2.0
	maybe-rayon@0.1.1
	memchr@2.7.6
	memmap2@0.9.9
	memoffset@0.9.1
	mime@0.3.17
	mime_guess@2.0.5
	miniz_oxide@0.8.9
	mio@1.1.1
	moxcms@0.7.10
	naga@27.0.3
	ndk-context@0.1.1
	ndk-sys@0.6.0+11769913
	ndk@0.9.0
	new_debug_unreachable@1.0.6
	nix@0.29.0
	nohash-hasher@0.2.0
	nom@8.0.0
	noop_proc_macro@0.3.0
	normpath@1.5.0
	nu-ansi-term@0.50.3
	num-bigint@0.4.6
	num-derive@0.4.2
	num-integer@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	num_enum@0.7.5
	num_enum_derive@0.7.5
	objc-sys@0.3.5
	objc2-app-kit@0.2.2
	objc2-app-kit@0.3.2
	objc2-cloud-kit@0.2.2
	objc2-contacts@0.2.2
	objc2-core-data@0.2.2
	objc2-core-foundation@0.3.2
	objc2-core-graphics@0.3.2
	objc2-core-image@0.2.2
	objc2-core-location@0.2.2
	objc2-encode@4.1.0
	objc2-foundation@0.2.2
	objc2-foundation@0.3.2
	objc2-io-surface@0.3.2
	objc2-link-presentation@0.2.2
	objc2-metal@0.2.2
	objc2-quartz-core@0.2.2
	objc2-symbols@0.2.2
	objc2-ui-kit@0.2.2
	objc2-uniform-type-identifiers@0.2.2
	objc2-user-notifications@0.2.2
	objc2@0.5.2
	objc2@0.6.3
	once_cell@1.21.3
	once_cell_polyfill@1.70.2
	option-ext@0.2.0
	orbclient@0.3.49
	ordered-float@2.10.1
	outref@0.5.2
	owned_ttf_parser@0.25.1
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	pastey@0.1.1
	pathfinder_geometry@0.5.1
	pathfinder_simd@0.5.5
	percent-encoding@2.3.2
	pin-project-internal@1.1.10
	pin-project-lite@0.2.16
	pin-project@1.1.10
	pkg-config@0.3.32
	png@0.18.0
	polling@3.11.0
	portable-atomic-util@0.2.4
	portable-atomic@1.11.1
	potential_utf@0.1.4
	ppv-lite86@0.2.21
	prettyplease@0.2.37
	proc-macro-crate@3.4.0
	proc-macro2@1.0.103
	profiling-procmacros@1.0.17
	profiling@1.0.17
	public-api@0.49.0
	pxfm@0.1.27
	qoi@0.4.1
	quick-error@2.0.1
	quick-xml@0.37.5
	quick-xml@0.38.4
	quote@1.0.42
	r-efi@5.3.0
	radium@0.7.0
	rand@0.8.5
	rand@0.9.2
	rand_chacha@0.3.1
	rand_chacha@0.9.0
	rand_core@0.6.4
	rand_core@0.9.3
	rand_distr@0.5.1
	rand_xoshiro@0.7.0
	ratatui-image@8.0.2
	ratatui@0.29.0
	rav1e@0.8.1
	ravif@0.12.0
	raw-window-handle@0.6.2
	rayon-core@1.13.0
	rayon@1.11.0
	redox_syscall@0.4.1
	redox_syscall@0.5.18
	redox_users@0.5.2
	regex-automata@0.4.13
	regex-syntax@0.8.8
	regex@1.12.2
	remove_dir_all@1.0.0
	renderdoc-sys@1.1.0
	rgb@0.8.52
	rustc-hash@1.1.0
	rustc-hash@2.1.1
	rustc_version@0.4.1
	rustdoc-json@0.9.7
	rustdoc-types@0.54.0
	rustix@0.38.44
	rustix@1.1.2
	rustversion@1.0.22
	ryu@1.0.20
	same-file@1.0.6
	scoped-tls@1.0.1
	scopeguard@1.2.0
	sd-notify@0.4.5
	semver@1.0.27
	serde-untagged@0.1.9
	serde-value@0.7.0
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.145
	serde_spanned@0.6.9
	serde_spanned@1.0.3
	sharded-slab@0.1.7
	shlex@1.3.0
	signal-hook-mio@0.2.5
	signal-hook-registry@1.4.7
	signal-hook@0.3.18
	simd-adler32@0.3.8
	simd_helpers@0.1.0
	slab@0.4.11
	slotmap@1.1.1
	smallvec@1.15.1
	smallvec@2.0.0-alpha.12
	smithay-client-toolkit@0.19.2
	smithay-client-toolkit@0.20.0
	smithay-clipboard@0.7.3
	smol_str@0.2.2
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	strsim@0.11.1
	strum@0.26.3
	strum_macros@0.26.4
	supercilex-tests@0.4.21
	syn@2.0.111
	synstructure@0.13.2
	tap@1.0.1
	terminal_size@0.4.3
	thiserror-impl@1.0.69
	thiserror-impl@2.0.17
	thiserror@1.0.69
	thiserror@2.0.17
	thread_local@1.1.9
	tiff@0.10.3
	tinystr@0.8.2
	toml@0.8.23
	toml@0.9.8
	toml_datetime@0.6.11
	toml_datetime@0.7.3
	toml_edit@0.22.27
	toml_edit@0.23.9
	toml_parser@1.0.4
	toml_write@0.1.2
	toml_writer@1.0.4
	tracing-attributes@0.1.31
	tracing-core@0.1.35
	tracing-log@0.2.0
	tracing-subscriber@0.3.22
	tracing@0.1.43
	tracy-client-sys@0.27.0
	tracy-client@0.18.3
	ttf-parser@0.25.1
	tui-textarea@0.7.0
	type-map@0.5.1
	typeid@1.0.3
	unicase@2.8.1
	unicode-ident@1.0.22
	unicode-segmentation@1.12.0
	unicode-truncate@1.1.0
	unicode-width@0.1.14
	unicode-width@0.2.0
	unicode-xid@0.2.6
	url@2.5.7
	utf8_iter@1.0.4
	utf8parse@0.2.2
	v_frame@0.3.9
	valuable@0.1.1
	version_check@0.9.5
	vsimd@0.8.0
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.1+wasi-0.2.4
	wasm-bindgen-futures@0.4.56
	wasm-bindgen-macro-support@0.2.106
	wasm-bindgen-macro@0.2.106
	wasm-bindgen-shared@0.2.106
	wasm-bindgen@0.2.106
	wayland-backend@0.3.11
	wayland-client@0.31.11
	wayland-csd-frame@0.3.0
	wayland-cursor@0.31.11
	wayland-protocols-experimental@20250721.0.1
	wayland-protocols-misc@0.3.9
	wayland-protocols-plasma@0.3.9
	wayland-protocols-wlr@0.3.9
	wayland-protocols@0.32.9
	wayland-scanner@0.31.7
	wayland-sys@0.31.7
	web-sys@0.3.83
	web-time@1.1.0
	webbrowser@1.0.6
	weezl@0.1.12
	wgpu-core-deps-windows-linux-android@27.0.0
	wgpu-core@27.0.3
	wgpu-hal@27.0.4
	wgpu-types@27.0.1
	wgpu@27.0.1
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.2.0
	windows-core@0.58.0
	windows-core@0.61.2
	windows-future@0.2.1
	windows-implement@0.58.0
	windows-implement@0.60.2
	windows-interface@0.58.0
	windows-interface@0.59.3
	windows-link@0.1.3
	windows-link@0.2.1
	windows-numerics@0.2.0
	windows-result@0.2.0
	windows-result@0.3.4
	windows-strings@0.1.0
	windows-strings@0.4.2
	windows-sys@0.45.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.42.2
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows-threading@0.1.0
	windows@0.58.0
	windows@0.61.3
	windows_aarch64_gnullvm@0.42.2
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.42.2
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.42.2
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.42.2
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.42.2
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.42.2
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.42.2
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.1
	winit@0.30.12
	winnow@0.7.14
	wio@0.2.2
	wit-bindgen@0.46.0
	writeable@0.6.2
	wyz@0.5.1
	x11-dl@2.21.0
	x11rb-protocol@0.13.2
	x11rb@0.13.2
	xcursor@0.3.10
	xkbcommon-dl@0.4.2
	xkeysym@0.2.1
	xml-rs@0.8.28
	y4m@0.8.0
	yeslogic-fontconfig-sys@6.0.0
	yoke-derive@0.8.1
	yoke@0.8.1
	zerocopy-derive@0.8.31
	zerocopy@0.8.31
	zerofrom-derive@0.1.6
	zerofrom@0.1.6
	zerotrie@0.2.3
	zerovec-derive@0.11.2
	zerovec@0.11.5
	zune-core@0.4.12
	zune-core@0.5.0
	zune-inflate@0.2.54
	zune-jpeg@0.4.21
	zune-jpeg@0.5.6
"

RUST_MIN_VER="9999"
inherit cargo desktop rust systemd xdg

DESCRIPTION="A clipboard history manager with server and multiple clients (Ringboard)"
HOMEPAGE="https://github.com/SUPERCILEX/clipboard-history"

SRC_URI="
	https://github.com/SUPERCILEX/clipboard-history/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="Apache-2.0"

# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CC0-1.0 ISC MIT MPL-2.0 UoI-NCSA
	Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="egui ratatui cli systemd X wayland"

# Runtime dependencies needed by the compiled binaries
RDEPEND="
	systemd? ( >=sys-apps/systemd-232 )
	X? ( x11-libs/libxcb )
	wayland? ( dev-libs/wayland )
"
DEPEND="${RDEPEND}"
# Build dependencies for underlying C libraries (like wayland-client/server C libs)
BDEPEND="
	virtual/pkgconfig
"

RESTRICT="test mirror"

src_configure() {
	local myfeatures=(
		$(usev systemd)
	)

	if use egui; then
		myfeatures+=(
			$(usev wayland)
			$(usex X x11 '')
		)
	fi

	local mycargoconf=(
		--exclude "clipboard-history-client-sdk"
		$(usex cli "" "--exclude clipboard-history")
		$(usex egui "" "--exclude clipboard-history-egui")
		$(usex ratatui "" "--exclude clipboard-history-tui")
		$(usex X "" "--exclude clipboard-history-x11")
		$(usex wayland "" "--exclude clipboard-history-wayland")
	)

	cargo_src_configure --no-default-features --workspace "${mycargoconf[@]}"
}

src_install() {
	# TODO Try this
	# cargo_src_install

	# TODO to avoid this {{{
	# Install all compiled binaries to /usr/bin/
	dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-server
	use egui && {
		dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-egui
		domenu ${FILESDIR}/ringboard-egui.desktop
		newicon ${WORKDIR}/${PN}-${PV}/logo.jpeg ringboard.jpeg
	}
	use ratatui && dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-tui
	use cli && dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard
	use X && dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-x11
	use wayland && dobin ${WORKDIR}/${PN}-${PV}/target/release/ringboard-wayland
	# }}}

	# Install systemd user services
	if use systemd; then
		# NOTE: You must ensure the .service files are present in the source repo
		# or copied into the ebuild's FILESDIR. The `systemd` eclass handles
		# installation to the correct system paths (/usr/lib/systemd/user/).
		systemd_douserunit ${FILESDIR}/ringboard-server.service
		use X && systemd_douserunit ${FILESDIR}/ringboard-x11.service
		use wayland && systemd_douserunit ${FILESDIR}/ringboard-wayland.service
	fi
}
