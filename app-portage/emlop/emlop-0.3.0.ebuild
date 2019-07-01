# Copyright 2017-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CRATES="
aho-corasick-0.6.9
ansi_term-0.11.0
arrayvec-0.4.10
assert_cli-0.6.3
atty-0.2.11
autocfg-0.1.1
backtrace-0.3.13
backtrace-sys-0.1.28
bitflags-1.0.4
cc-1.0.28
cfg-if-0.1.6
chrono-0.4.6
chrono-english-0.1.4
clap-2.32.0
cloudabi-0.0.3
colored-1.6.1
crossbeam-channel-0.3.4
crossbeam-epoch-0.7.0
crossbeam-utils-0.6.3
difference-2.0.0
environment-0.1.1
errno-0.2.4
errno-dragonfly-0.1.1
failure-0.1.3
failure_derive-0.1.3
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
gcc-0.3.55
indoc-0.3.1
indoc-impl-0.3.1
itoa-0.4.3
kernel32-sys-0.2.2
lazy_static-1.2.0
libc-0.2.45
lock_api-0.1.5
log-0.4.6
memchr-2.1.2
memoffset-0.2.1
nodrop-0.1.13
num-integer-0.1.39
num-traits-0.2.6
owning_ref-0.4.0
parking_lot-0.7.0
parking_lot_core-0.4.0
proc-macro-hack-0.5.3
proc-macro2-0.4.24
quote-0.6.10
rand-0.6.1
rand_chacha-0.1.0
rand_core-0.3.0
rand_hc-0.1.0
rand_isaac-0.1.1
rand_pcg-0.1.1
rand_xorshift-0.1.0
redox_syscall-0.1.44
redox_termios-0.1.1
regex-1.1.0
regex-syntax-0.6.4
rustc-demangle-0.1.11
rustc_version-0.2.3
ryu-0.2.7
scanlex-0.1.2
scopeguard-0.3.3
semver-0.9.0
semver-parser-0.7.0
serde-1.0.82
serde_json-1.0.33
smallvec-0.6.7
stable_deref_trait-1.1.1
stderrlog-0.4.1
strsim-0.7.0
syn-0.15.23
synstructure-0.10.1
sysconf-0.3.4
tabwriter-1.1.0
termcolor-0.3.6
termion-1.5.1
textwrap-0.10.0
thread_local-0.3.6
time-0.1.41
ucd-util-0.1.3
unicode-width-0.1.5
unicode-xid-0.1.0
unindent-0.1.3
unreachable-1.0.0
utf8-ranges-1.0.2
vec_map-0.8.1
version_check-0.1.5
void-1.0.2
winapi-0.2.8
winapi-0.3.6
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-0.1.6
"

inherit cargo

DESCRIPTION="A fast, accurate, ergonomic emerge.log parser"
HOMEPAGE="https://github.com/vincentdephily/emlop"
SRC_URI="https://github.com/vincentdephily/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
		 $(cargo_crate_uris ${CRATES})"

LICENSE="GPL-3"
SLOT="0"
IUSE=""
KEYWORDS="~amd64 ~x86"

DEPEND=">=virtual/rust-1.30
	 virtual/cargo"
RDEPEND=""

src_test() {
	cargo test || die "tests failed"
}

src_install() {
	cargo_src_install
	dodoc README.md COMPARISON.md
}
