# Copyright 2026 Rosen Aleksandrov
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	accesskit@0.24.1
	adler2@2.0.1
	ahash@0.8.12
	aho-corasick@1.1.4
	aligned-vec@0.6.4
	aligned@0.4.3
	allocator-api2@0.2.21
	android-activity@0.6.1
	android-properties@0.2.2
	anstream@1.0.0
	anstyle-parse@1.0.0
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.14
	anyhow@1.0.102
	approx@0.5.1
	arbitrary@1.4.2
	arboard@3.6.1
	arg_enum_proc_macro@0.3.4
	arrayvec@0.7.7
	as-raw-xcb-connection@1.0.1
	as-slice@0.2.1
	atomic-waker@1.1.2
	atomic@0.6.1
	autocfg@1.5.1
	av-data@0.4.4
	av-scenechange@0.14.1
	av1-grain@0.2.5
	avif-serialize@0.8.9
	base64-serde@0.8.0
	base64-simd@0.8.0
	base64@0.22.1
	bit-set@0.5.3
	bit-set@0.9.1
	bit-vec@0.6.3
	bit-vec@0.9.1
	bit_field@0.10.3
	bitcode@0.6.9
	bitcode_derive@0.6.9
	bitflags@1.3.2
	bitflags@2.13.0
	bitreader@0.3.11
	bitstream-io@4.10.0
	bitvec@1.1.1
	block-buffer@0.10.4
	block2@0.5.1
	block2@0.6.2
	bon-macros@3.9.3
	bon@3.9.3
	built@0.8.1
	bumpalo@3.20.3
	by_address@1.2.1
	byte-slice-cast@1.2.3
	bytemuck@1.25.0
	bytemuck_derive@1.10.2
	byteorder-lite@0.1.0
	byteorder@1.5.0
	bytes@1.12.0
	calloop-wayland-source@0.3.0
	calloop-wayland-source@0.4.1
	calloop@0.13.0
	calloop@0.14.4
	camino@1.2.3
	cargo-manifest@0.20.0
	cargo-platform@0.3.3
	cargo_metadata@0.23.1
	castaway@0.2.4
	cc@1.2.65
	cfg-expr@0.20.8
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	cgl@0.3.2
	clap-num@1.2.0
	clap@4.6.1
	clap_builder@4.6.0
	clap_derive@4.6.1
	clap_lex@1.1.0
	clipboard-win@5.4.1
	codespan-reporting@0.13.1
	color@0.3.3
	color_quant@1.1.0
	colorchoice@1.0.5
	combine@4.6.7
	compact_str@0.9.1
	concurrent-queue@2.5.0
	console@0.15.11
	convert_case@0.10.0
	core-foundation-sys@0.8.7
	core-foundation@0.10.1
	core-foundation@0.9.4
	core-graphics-types@0.1.3
	core-graphics@0.23.2
	core-text@20.1.0
	cpufeatures@0.2.17
	crc32fast@1.5.0
	critical-section@1.2.0
	crossbeam-channel@0.5.15
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crossterm@0.29.0
	crossterm_winapi@0.9.1
	crunchy@0.2.4
	crypto-common@0.1.7
	csscolorparser@0.6.2
	cursor-icon@1.2.0
	cvt@0.1.2
	darling@0.23.0
	darling_core@0.23.0
	darling_macro@0.23.0
	dav1d-sys@0.8.3
	dav1d@0.11.1
	defmt-macros@1.1.0
	defmt-parser@1.0.0
	defmt@1.1.0
	deltae@0.3.2
	deranged@0.5.8
	derive_more-impl@2.1.1
	derive_more@2.1.1
	digest@0.10.7
	dirs-sys@0.5.0
	dirs@6.0.0
	dispatch2@0.3.1
	dispatch@0.2.0
	displaydoc@0.2.6
	dissimilar@1.0.11
	dlib@0.5.3
	document-features@0.2.12
	downcast-rs@1.2.1
	dpi@0.1.2
	dwrote@0.11.5
	ecolor@0.34.3
	eframe@0.34.3
	egui-wgpu@0.34.3
	egui-winit@0.34.3
	egui@0.34.3
	egui_glow@0.34.3
	either@1.16.0
	emath@0.34.3
	encode_unicode@1.0.0
	env_filter@1.0.1
	env_logger@0.11.10
	epaint@0.34.3
	equator-macro@0.4.2
	equator@0.4.2
	equivalent@1.0.2
	errno@0.3.14
	error-code@3.3.2
	error-stack@0.7.1
	euclid@0.22.14
	expect-test@1.5.1
	exr@1.74.0
	fallible_collections@0.4.9
	fancy-regex@0.11.0
	fast-srgb8@1.0.0
	fax@0.2.7
	fdeflate@0.3.7
	fearless_simd@0.3.0
	filedescriptor@0.8.3
	find-msvc-tools@0.1.9
	finl_unicode@1.4.0
	fixedbitset@0.4.2
	flate2@1.1.9
	float-ord@0.3.2
	fnv@1.0.7
	foldhash@0.2.0
	font-kit@0.14.3
	font-types@0.11.3
	foreign-types-macros@0.2.3
	foreign-types-shared@0.3.1
	foreign-types@0.5.0
	form_urlencoded@1.2.2
	freetype-sys@0.20.1
	fs_at@0.2.1
	fuc_engine@3.1.7
	funty@2.0.0
	futures-core@0.3.32
	futures-task@0.3.32
	futures-util@0.3.32
	generator@0.8.9
	generic-array@0.14.7
	gethostname@1.1.0
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	gif@0.14.2
	gl_generator@0.14.0
	glam@0.33.1
	glow@0.17.0
	glutin-winit@0.5.0
	glutin@0.32.3
	glutin_egl_sys@0.7.1
	glutin_glx_sys@0.6.1
	glutin_wgl_sys@0.6.1
	half@2.7.1
	hashbag@0.1.13
	hashbrown@0.13.2
	hashbrown@0.16.1
	hashbrown@0.17.1
	heck@0.5.0
	hermit-abi@0.5.2
	hex@0.4.3
	hexf-parse@0.2.1
	icu_collections@2.2.0
	icu_locale_core@2.2.0
	icu_normalizer@2.2.0
	icu_normalizer_data@2.2.0
	icu_properties@2.2.0
	icu_properties_data@2.2.0
	icu_provider@2.2.0
	icy_sixel@0.5.0
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.2
	image-webp@0.2.4
	image@0.25.10
	imgref@1.12.2
	indexmap@2.14.0
	indoc@2.0.7
	instability@0.3.12
	interpolate_name@0.2.4
	io-uring@0.7.12
	is_terminal_polyfill@1.70.2
	itertools@0.14.0
	itoa@1.0.18
	jiff-static@0.2.29
	jiff@0.2.29
	jni-macros@0.22.4
	jni-sys-macros@0.4.1
	jni-sys@0.3.1
	jni-sys@0.4.1
	jni@0.22.4
	jobserver@0.1.34
	js-sys@0.3.102
	kasuari@0.4.12
	khronos_api@3.1.0
	kurbo@0.13.1
	lab@0.11.0
	lazy_static@1.5.0
	lebe@0.5.3
	libc@0.2.186
	libfuzzer-sys@0.4.13
	libloading@0.8.9
	libm@0.2.16
	libredox@0.1.17
	line-clipping@0.3.7
	linebender_resource_handle@0.1.1
	linux-raw-sys@0.12.1
	linux-raw-sys@0.4.15
	litemap@0.8.2
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.33
	loom@0.7.2
	loop9@0.1.5
	lru@0.18.0
	mac_address@1.1.8
	matchers@0.2.0
	maybe-rayon@0.1.1
	memchr@2.8.2
	memmap2@0.9.10
	memmem@0.1.1
	memoffset@0.9.1
	mime@0.3.17
	mime_guess@2.0.5
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	mio@1.2.1
	moxcms@0.8.1
	mp4parse@0.17.0
	naga@29.0.3
	ndk-context@0.1.1
	ndk-sys@0.6.0+11769913
	ndk@0.9.0
	new_debug_unreachable@1.0.6
	nix@0.29.0
	no_std_io2@0.9.4
	nohash-hasher@0.2.0
	nom@7.1.3
	nom@8.0.0
	noop_proc_macro@0.3.0
	normpath@1.5.1
	nu-ansi-term@0.50.3
	num-bigint@0.4.6
	num-conv@0.2.2
	num-derive@0.4.2
	num-integer@0.1.46
	num-rational@0.4.2
	num-traits@0.2.19
	num_enum@0.7.6
	num_enum_derive@0.7.6
	num_threads@0.1.7
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
	objc2-ui-kit@0.3.2
	objc2-uniform-type-identifiers@0.2.2
	objc2-user-notifications@0.2.2
	objc2@0.5.2
	objc2@0.6.4
	once_cell@1.21.4
	once_cell_polyfill@1.70.2
	option-ext@0.2.0
	orbclient@0.3.55
	ordered-float@4.6.0
	ordered-float@5.3.0
	outref@0.5.2
	palette@0.7.6
	palette_derive@0.7.6
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	pastey@0.1.1
	pathfinder_geometry@0.5.1
	pathfinder_simd@0.5.6
	peniko@0.6.1
	percent-encoding@2.3.2
	pest@2.8.6
	pest_derive@2.8.6
	pest_generator@2.8.6
	pest_meta@2.8.6
	phf@0.11.3
	phf_codegen@0.11.3
	phf_generator@0.11.3
	phf_macros@0.11.3
	phf_shared@0.11.3
	pin-project-internal@1.1.13
	pin-project-lite@0.2.17
	pin-project@1.1.13
	pkg-config@0.3.33
	plain@0.2.3
	png@0.18.1
	polling@3.11.0
	polycool@0.4.0
	portable-atomic-util@0.2.7
	portable-atomic@1.13.1
	potential_utf@0.1.5
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	prettyplease@0.2.37
	proc-macro-crate@3.5.0
	proc-macro-error-attr2@2.0.0
	proc-macro-error2@2.0.1
	proc-macro2@1.0.106
	profiling-procmacros@1.0.18
	profiling@1.0.18
	public-api@0.51.0
	pxfm@0.1.29
	qoi@0.4.1
	quantette@0.5.1
	quick-error@2.0.1
	quick-xml@0.39.4
	quick-xml@0.40.1
	quote@1.0.45
	r-efi@5.3.0
	r-efi@6.0.0
	radium@0.7.0
	rand@0.10.1
	rand@0.8.6
	rand@0.9.4
	rand_chacha@0.3.1
	rand_chacha@0.9.0
	rand_core@0.10.1
	rand_core@0.6.4
	rand_core@0.9.5
	rand_distr@0.6.0
	rand_xoshiro@0.7.0
	rand_xoshiro@0.8.1
	ratatui-core@0.1.2
	ratatui-crossterm@0.1.2
	ratatui-image@11.0.5
	ratatui-macros@0.7.2
	ratatui-termina@0.1.0
	ratatui-termwiz@0.1.2
	ratatui-widgets@0.3.2
	ratatui@0.30.2
	rav1e@0.8.1
	ravif@0.13.0
	raw-window-handle@0.6.2
	rayon-core@1.13.0
	rayon@1.12.0
	read-fonts@0.37.0
	redox_syscall@0.4.1
	redox_syscall@0.5.18
	redox_syscall@0.8.1
	redox_users@0.5.2
	ref-cast-impl@1.0.25
	ref-cast@1.0.25
	regex-automata@0.4.14
	regex-syntax@0.8.11
	regex@1.12.4
	remove_dir_all@1.0.0
	renderdoc-sys@1.1.0
	rgb@0.8.53
	rustc-hash@1.1.0
	rustc-hash@2.1.2
	rustc_version@0.4.1
	rustdoc-json@0.9.10
	rustdoc-types@0.56.0
	rustix@0.38.44
	rustix@1.1.4
	rustversion@1.0.22
	ryu@1.0.23
	safe_arch@0.9.3
	same-file@1.0.6
	scoped-tls@1.0.1
	scopeguard@1.2.0
	sd-notify@0.5.0
	self_cell@1.2.2
	semver@1.0.28
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	serde_spanned@0.6.9
	serde_spanned@1.1.1
	sha2@0.10.9
	sharded-slab@0.1.7
	shlex@2.0.1
	signal-hook-mio@0.2.5
	signal-hook-registry@1.4.8
	signal-hook@0.3.18
	simd-adler32@0.3.9
	simd_cesu8@1.1.1
	simd_helpers@0.1.0
	simdutf8@0.1.5
	similar-asserts@1.7.0
	similar@2.7.0
	siphasher@1.0.3
	skrifa@0.40.0
	slab@0.4.12
	slotmap@1.1.1
	smallvec@1.15.2
	smallvec@2.0.0-alpha.12
	smithay-client-toolkit@0.19.2
	smithay-client-toolkit@0.20.0
	smithay-clipboard@0.7.3
	smol_str@0.2.2
	snapshot-testing@0.1.8
	stable-type@0.1.1
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	strsim@0.11.1
	strum@0.28.0
	strum_macros@0.28.0
	supercilex-tests@0.4.22
	syn@1.0.109
	syn@2.0.118
	synstructure@0.13.2
	system-deps@7.0.8
	tap@1.0.1
	target-lexicon@0.13.5
	termina@0.3.3
	terminal_size@0.4.4
	terminfo@0.9.0
	termios@0.3.3
	termwiz@0.23.3
	thiserror-impl@1.0.69
	thiserror-impl@2.0.18
	thiserror@1.0.69
	thiserror@2.0.18
	thread_local@1.1.9
	tiff@0.11.3
	time-core@0.1.9
	time@0.3.49
	tinystr@0.8.3
	toml@0.8.23
	toml@1.1.2+spec-1.1.0
	toml_datetime@0.6.11
	toml_datetime@1.1.1+spec-1.1.0
	toml_edit@0.22.27
	toml_edit@0.25.12+spec-1.1.0
	toml_parser@1.1.2+spec-1.1.0
	toml_writer@1.1.1+spec-1.1.0
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.23
	tracing@0.1.44
	tracy-client-sys@0.28.0
	tracy-client@0.18.4
	tui-input@0.15.3
	type-map@0.5.1
	typenum@1.20.1
	ucd-trie@0.1.7
	unicase@2.9.0
	unicode-ident@1.0.24
	unicode-segmentation@1.13.3
	unicode-truncate@2.0.1
	unicode-width@0.2.2
	url@2.5.8
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@1.23.3
	v_frame@0.3.9
	valuable@0.1.1
	vello_common@0.0.6
	vello_cpu@0.0.6
	version-compare@0.2.1
	version_check@0.9.5
	vsimd@0.8.0
	vtparse@0.6.2
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.4+wasi-0.2.12
	wasm-bindgen-futures@0.4.75
	wasm-bindgen-macro-support@0.2.125
	wasm-bindgen-macro@0.2.125
	wasm-bindgen-shared@0.2.125
	wasm-bindgen@0.2.125
	wayland-backend@0.3.15
	wayland-client@0.31.14
	wayland-csd-frame@0.3.0
	wayland-cursor@0.31.14
	wayland-protocols-experimental@20250721.0.1
	wayland-protocols-misc@0.3.12
	wayland-protocols-plasma@0.3.12
	wayland-protocols-wlr@0.3.12
	wayland-protocols@0.32.13
	wayland-scanner@0.31.10
	wayland-sys@0.31.11
	web-sys@0.3.102
	web-time@1.1.0
	webbrowser@1.2.1
	weezl@0.1.12
	wezterm-bidi@0.2.3
	wezterm-blob-leases@0.1.1
	wezterm-color-types@0.3.0
	wezterm-dynamic-derive@0.1.1
	wezterm-dynamic@0.2.1
	wezterm-input-types@0.1.0
	wgpu-core-deps-windows-linux-android@29.0.3
	wgpu-core@29.0.3
	wgpu-hal@29.0.3
	wgpu-naga-bridge@29.0.3
	wgpu-types@29.0.3
	wgpu@29.0.3
	wide@0.8.3
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-core@0.58.0
	windows-implement@0.58.0
	windows-interface@0.58.0
	windows-link@0.2.1
	windows-result@0.2.0
	windows-result@0.4.1
	windows-strings@0.1.0
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows@0.58.0
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.1
	winit@0.30.13
	winnow@0.7.15
	winnow@1.0.3
	wio@0.2.2
	wit-bindgen@0.57.1
	writeable@0.6.3
	wyz@0.5.1
	x11-dl@2.21.0
	x11rb-protocol@0.13.2
	x11rb@0.13.2
	xcursor@0.3.10
	xkbcommon-dl@0.4.2
	xkeysym@0.2.1
	xml-rs@0.8.28
	y4m@0.8.0
	yeslogic-fontconfig-sys@6.0.1
	yoke-derive@0.8.2
	yoke@0.8.3
	zerocopy-derive@0.8.52
	zerocopy@0.8.52
	zerofrom-derive@0.1.7
	zerofrom@0.1.8
	zerotrie@0.2.4
	zerovec-derive@0.11.3
	zerovec@0.11.6
	zmij@1.0.21
	zune-core@0.5.1
	zune-inflate@0.2.54
	zune-jpeg@0.5.15
"

# Upstream tag 0.17.0 is the "Stable Rust 1.95 patch" commit: no nightly
# features are used any more, so no need for RUST_MIN_VER="9999".
RUST_MIN_VER="1.95.0"

inherit cargo desktop rust systemd xdg

DESCRIPTION="A fast, efficient and composable clipboard manager (Ringboard)"
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

IUSE="cli egui ratatui wayland X"
REQUIRED_USE="egui? ( || ( wayland X ) )"

# The server and the clipboard watchers are pure Rust (sd-notify, x11rb and
# wayland-client use their native Rust implementations). eframe/winit
# dlopen() the libraries below at runtime.
RDEPEND="
	egui? (
		media-libs/libglvnd
		x11-libs/libxkbcommon
		wayland? ( dev-libs/wayland )
		X? (
			x11-libs/libX11
			x11-libs/libXcursor
			x11-libs/libXi
			x11-libs/libXrandr
		)
	)
"

RESTRICT="test mirror"

src_prepare() {
	default

	# systemd wants absolute paths in ExecStart=
	sed -i -e 's|^ExecStart=ringboard-|ExecStart=/usr/bin/ringboard-|' \
		server/ringboard-server.service \
		x11/ringboard-x11.service \
		wayland/ringboard-wayland.service || die

	# Same tweaks as upstream's install-with-cargo-systemd.sh. The icon is a
	# JPEG, which hicolor theme lookup does not support, so use an absolute path.
	sed -i \
		-e 's|^Exec=ringboard-egui|Exec=ringboard-egui toggle|' \
		-e 's|^Icon=ringboard|Icon=/usr/share/pixmaps/ringboard.jpeg|' \
		egui/ringboard-egui.desktop || die
}

src_compile() {
	# Nothing to do: the workspace root is a dummy "lint" package and every
	# binary is built (once, with its own features) by cargo_src_install.
	:
}

src_install() {
	# Server: sd-notify support is required by Type=notify in the unit.
	cargo_src_install --path server --no-default-features --features systemd

	use cli && cargo_src_install --path cli
	use ratatui && cargo_src_install --path tui
	use X && cargo_src_install --path x11 --no-default-features
	use wayland && cargo_src_install --path wayland --no-default-features

	if use egui; then
		local egui_features=( $(usev wayland) $(usev X x11) )
		cargo_src_install --path egui --no-default-features \
			--features "$(IFS=,; echo "${egui_features[*]}")"

		domenu egui/ringboard-egui.desktop
		newicon logo.jpeg ringboard.jpeg
	fi

	# systemd user units (the services reference Slice=ringboard.slice)
	systemd_douserunit ringboard.slice
	systemd_douserunit server/ringboard-server.service
	use X && systemd_douserunit x11/ringboard-x11.service
	use wayland && systemd_douserunit wayland/ringboard-wayland.service

	einstalldocs
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Ringboard needs Linux 6+ with io_uring enabled."
	elog "Enable the services for your user, e.g.:"
	elog "  systemctl --user enable --now ringboard-server"
	use wayland && elog "  systemctl --user enable --now ringboard-wayland"
	use X && elog "  systemctl --user enable --now ringboard-x11"
	if use wayland; then
		elog
		elog "On COSMIC, the Wayland watcher needs COSMIC_DATA_CONTROL_ENABLED=1"
		elog "in the session environment (e.g. /etc/profile.d/clipboard.sh), then re-login."
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
}
