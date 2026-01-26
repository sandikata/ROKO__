# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	adler32@1.2.0
	aho-corasick@1.1.4
	allocator-api2@0.2.21
	amdgpu-sysfs@0.19.3
	android_system_properties@0.1.5
	anstream@0.6.21
	anstyle-parse@0.2.7
	anstyle-query@1.1.5
	anstyle-wincon@3.0.11
	anstyle@1.0.13
	anyhow@1.0.100
	arc-swap@1.8.0
	async-broadcast@0.7.2
	async-recursion@1.1.1
	async-trait@0.1.89
	autocfg@1.5.0
	base64@0.22.1
	basic-toml@0.1.10
	bindgen@0.71.1
	bitflags@1.3.2
	bitflags@2.10.0
	block-buffer@0.10.4
	bumpalo@3.19.1
	bytes@1.11.0
	cairo-rs@0.21.5
	cairo-sys-rs@0.21.5
	cc@1.2.51
	cexpr@0.6.0
	cfg-expr@0.20.5
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	chrono@0.4.42
	clang-sys@1.8.1
	clap@4.5.53
	clap_builder@4.5.53
	clap_derive@4.5.49
	clap_lex@0.7.6
	colorchoice@1.0.4
	concurrent-queue@2.5.0
	condtype@1.3.0
	console@0.15.11
	cookie@0.18.1
	cookie_store@0.22.0
	core-foundation-sys@0.8.7
	core2@0.4.0
	cpufeatures@0.2.17
	crc32fast@1.5.0
	crossbeam-utils@0.8.21
	crypto-common@0.1.7
	darling@0.20.11
	darling@0.21.3
	darling_core@0.20.11
	darling_core@0.21.3
	darling_macro@0.20.11
	darling_macro@0.21.3
	dary_heap@0.3.8
	deranged@0.5.5
	diff@0.1.13
	digest@0.10.7
	displaydoc@0.2.5
	divan-macros@0.1.21
	divan@0.1.21
	document-features@0.2.12
	easy_fuser@0.4.3
	either@1.15.0
	encode_unicode@1.0.0
	endi@1.1.1
	enum_dispatch@0.3.13
	enumflags2@0.7.12
	enumflags2_derive@0.7.12
	equivalent@1.0.2
	errno@0.3.14
	event-listener-strategy@0.5.4
	event-listener@5.4.1
	fastrand@2.3.0
	field-offset@0.3.6
	filetime@0.2.26
	find-crate@0.6.3
	find-msvc-tools@0.1.6
	flate2@1.1.5
	fluent-bundle@0.16.0
	fluent-langneg@0.13.1
	fluent-syntax@0.12.0
	fluent@0.17.0
	flume@0.11.1
	fnv@1.0.7
	foldhash@0.2.0
	form_urlencoded@1.2.2
	fragile@2.0.1
	fuser@0.16.0
	futures-channel@0.3.31
	futures-core@0.3.31
	futures-executor@0.3.31
	futures-io@0.3.31
	futures-lite@2.6.1
	futures-macro@0.3.31
	futures-sink@0.3.31
	futures-task@0.3.31
	futures-util@0.3.31
	futures@0.3.31
	gdk-pixbuf-sys@0.21.5
	gdk-pixbuf@0.21.5
	gdk4-sys@0.10.3
	gdk4@0.10.3
	generic-array@0.14.7
	getrandom@0.2.16
	getrandom@0.3.4
	gio-sys@0.21.5
	gio@0.21.5
	glib-macros@0.21.5
	glib-sys@0.21.5
	glib@0.21.5
	glob@0.3.3
	gobject-sys@0.21.5
	graphene-rs@0.21.5
	graphene-sys@0.21.5
	gsk4-sys@0.10.3
	gsk4@0.10.3
	gtk4-macros@0.10.3
	gtk4-sys@0.10.3
	gtk4@0.10.3
	hashbrown@0.16.1
	heck@0.5.0
	hermit-abi@0.5.2
	hex@0.4.3
	http@1.4.0
	httparse@1.10.1
	i18n-config@0.4.8
	i18n-embed-fl@0.10.0
	i18n-embed-impl@0.8.4
	i18n-embed@0.16.0
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.64
	icu_collections@2.1.1
	icu_locale_core@2.1.1
	icu_normalizer@2.1.1
	icu_normalizer_data@2.1.1
	icu_properties@2.1.2
	icu_properties_data@2.1.2
	icu_provider@2.1.1
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.1
	indexmap@2.12.1
	inotify-sys@0.1.5
	inotify@0.11.0
	insta@1.45.0
	intl-memoizer@0.5.3
	intl_pluralrules@7.0.2
	is_terminal_polyfill@1.70.2
	itertools@0.13.0
	itoa@1.0.16
	js-sys@0.3.83
	kqueue-sys@1.0.4
	kqueue@1.1.1
	lazy_static@1.5.0
	libadwaita-sys@0.8.1
	libadwaita@0.8.1
	libc@0.2.178
	libcopes@1.0.0
	libdrm_amdgpu_sys@0.8.8
	libflate@2.2.1
	libflate_lz77@2.2.0
	libloading@0.8.9
	libredox@0.1.11
	linux-raw-sys@0.11.0
	litemap@0.8.1
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.29
	matchers@0.2.0
	memchr@2.7.6
	memoffset@0.9.1
	minimal-lexical@0.2.1
	miniz_oxide@0.8.9
	mio@1.1.1
	nanorand@0.7.0
	nix@0.29.0
	nix@0.30.1
	nom@7.1.3
	notify-types@2.0.0
	notify@8.2.0
	nu-ansi-term@0.50.3
	num-conv@0.1.0
	num-traits@0.2.19
	num_cpus@1.17.0
	num_threads@0.1.7
	nvml-wrapper-sys@0.9.0
	nvml-wrapper@0.11.0
	once_cell@1.21.3
	once_cell_polyfill@1.70.2
	ordered-stream@0.2.0
	os-release@0.1.0
	page_size@0.6.0
	pango-sys@0.21.5
	pango@0.21.5
	parking@2.2.1
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	pciid-parser@0.8.0
	percent-encoding@2.3.2
	pin-project-lite@0.2.16
	pin-utils@0.1.0
	pkg-config@0.3.32
	plotters-backend@0.3.7
	plotters-cairo@0.8.0
	plotters@0.3.7
	potential_utf@0.1.4
	powerfmt@0.2.0
	pretty_assertions@1.4.1
	prettyplease@0.2.37
	proc-macro-crate@3.4.0
	proc-macro-error-attr2@2.0.0
	proc-macro-error2@2.0.1
	proc-macro2@1.0.103
	quote@1.0.42
	r-efi@5.3.0
	redox_syscall@0.5.18
	redox_syscall@0.6.0
	regex-automata@0.4.13
	regex-lite@0.1.8
	regex-syntax@0.8.8
	regex@1.12.2
	relm4-components@0.10.0
	relm4-css@0.10.0
	relm4-macros@0.10.0
	relm4@0.10.0
	ring@0.17.14
	rle-decode-fast@1.0.3
	rust-embed-impl@8.9.0
	rust-embed-utils@8.9.0
	rust-embed@8.9.0
	rustc-hash@2.1.1
	rustc_version@0.4.1
	rustix@1.1.3
	rustls-pki-types@1.13.2
	rustls-webpki@0.103.8
	rustls@0.23.35
	rustversion@1.0.22
	ryu@1.0.21
	same-file@1.0.6
	scopeguard@1.2.0
	self_cell@1.2.1
	semver@1.0.27
	serde-error@0.1.3
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.147
	serde_norway@0.9.42
	serde_repr@0.1.20
	serde_spanned@1.0.4
	serde_with@3.16.1
	serde_with_macros@3.16.1
	sha2@0.10.9
	sharded-slab@0.1.7
	shlex@1.3.0
	signal-hook-registry@1.4.8
	simd-adler32@0.3.8
	similar@2.7.0
	slab@0.4.11
	smallvec@1.15.1
	socket2@0.6.1
	spin@0.9.8
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	strsim@0.11.1
	subtle@2.6.1
	syn@2.0.111
	synstructure@0.13.2
	sys-locale@0.3.2
	system-deps@7.0.7
	tar@0.4.44
	target-lexicon@0.13.3
	tempfile@3.24.0
	terminal_size@0.4.3
	thiserror-impl@1.0.69
	thiserror-impl@2.0.17
	thiserror@1.0.69
	thiserror@2.0.17
	thread-priority@3.0.0
	thread_local@1.1.9
	threadpool@1.8.1
	time-core@0.1.6
	time-macros@0.2.24
	time@0.3.44
	tinystr@0.8.2
	tokio-macros@2.6.0
	tokio@1.48.0
	toml@0.5.11
	toml@0.9.10+spec-1.1.0
	toml_datetime@0.7.5+spec-1.1.0
	toml_edit@0.23.10+spec-1.0.0
	toml_parser@1.0.6+spec-1.1.0
	toml_writer@1.0.6+spec-1.1.0
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-subscriber@0.3.22
	tracing@0.1.44
	tracker-macros@0.2.2
	tracker@0.2.2
	type-map@0.5.1
	typenum@1.19.0
	uds_windows@1.1.0
	unic-langid-impl@0.9.6
	unic-langid@0.9.6
	unicode-ident@1.0.22
	unsafe-libyaml-norway@0.2.15
	untrusted@0.9.0
	ureq-proto@0.5.3
	ureq@3.1.4
	url@2.5.7
	utf-8@0.7.6
	utf8_iter@1.0.4
	utf8parse@0.2.2
	uuid@1.19.0
	valuable@0.1.1
	vergen@8.3.2
	version-compare@0.2.1
	version_check@0.9.5
	walkdir@2.5.0
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.1+wasi-0.2.4
	wasm-bindgen-macro-support@0.2.106
	wasm-bindgen-macro@0.2.106
	wasm-bindgen-shared@0.2.106
	wasm-bindgen@0.2.106
	web-sys@0.3.83
	webpki-roots@1.0.4
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.2.0
	windows-core@0.61.2
	windows-core@0.62.2
	windows-future@0.2.1
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.1.3
	windows-link@0.2.1
	windows-numerics@0.2.0
	windows-result@0.3.4
	windows-result@0.4.1
	windows-strings@0.4.2
	windows-strings@0.5.1
	windows-sys@0.52.0
	windows-sys@0.59.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows-threading@0.1.0
	windows@0.61.3
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
	winnow@0.7.14
	wit-bindgen@0.46.0
	wrapcenum-derive@0.4.1
	writeable@0.6.2
	xattr@1.6.1
	yansi@1.0.1
	yoke-derive@0.8.1
	yoke@0.8.1
	zbus@5.12.0
	zbus_macros@5.12.0
	zbus_names@4.2.0
	zerocopy-derive@0.8.31
	zerocopy@0.8.31
	zerofrom-derive@0.1.6
	zerofrom@0.1.6
	zeroize@1.8.2
	zerotrie@0.2.3
	zerovec-derive@0.11.2
	zerovec@0.11.5
	zmij@0.1.9
	zvariant@5.8.0
	zvariant_derive@5.8.0
	zvariant_utils@3.2.1
"

LLVM_COMPAT=( {18..21} )
RUST_MIN_VER="1.85.0"

inherit cargo llvm-r2 xdg

DESCRIPTION="Linux GPU Control Application"
HOMEPAGE="https://github.com/ilya-zlobintsev/LACT"
SRC_URI="
	https://github.com/ilya-zlobintsev/LACT/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"
#if [[ ${PKGBUMPING} != ${PVR} ]]; then
#	SRC_URI+="
#		https://github.com/pastalian/distfiles/releases/download/${P}/${P}-crates.tar.xz
#	"
#fi
S="${WORKDIR}/${P^^}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD CC0-1.0
	CDLA-Permissive-2.0 ISC LGPL-3+ MIT MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui libadwaita test video_cards_nvidia"
REQUIRED_USE="libadwaita? ( gui ) test? ( gui )"
RESTRICT="!test? ( test )"

COMMON_DEPEND="
	virtual/opencl
	x11-libs/libdrm[video_cards_amdgpu]
	gui? (
		dev-libs/glib:2
		gui-libs/gtk:4[introspection]
		media-libs/fontconfig
		media-libs/freetype
		media-libs/graphene
		x11-libs/cairo
		x11-libs/pango
	)
	libadwaita? ( >=gui-libs/libadwaita-1.4.0:1 )
"
RDEPEND="
	${COMMON_DEPEND}
	dev-util/vulkan-tools
	sys-apps/hwdata
"
DEPEND="
	${COMMON_DEPEND}
	test? ( sys-fs/fuse:3 )
"
# libclang is required for bindgen
BDEPEND="
	virtual/pkgconfig
	$(llvm_gen_dep 'llvm-core/clang:${LLVM_SLOT}')
"

QA_FLAGS_IGNORED="usr/bin/lact"

pkg_setup() {
	llvm-r2_pkg_setup
	rust_pkg_setup
}

src_configure() {
	local myfeatures=(
		$(usev gui lact-gui)
		$(usev libadwaita adw)
		$(usev video_cards_nvidia nvidia)
	)
	cargo_src_configure --no-default-features
}

src_install() {
	cargo_src_install --path lact
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install-resources
	newinitd res/lact-daemon-openrc lactd
}

src_test() {
	local skip=(
		# requires newer sys-apps/hwdata
		--skip tests::snapshot_everything
	)
	cargo_src_test --workspace -- "${skip[@]}"
}
