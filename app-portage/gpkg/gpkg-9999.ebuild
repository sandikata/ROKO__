# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
RUST_MIN_VER="1.75.0"

inherit cargo desktop git-r3 systemd xdg-utils

DESCRIPTION="Graphical package manager for Gentoo Linux (Portage frontend)"
HOMEPAGE="https://codeberg.org/NoBodyZ/gpkg"
SRC_URI="
	${CARGO_CRATE_URIS}
"
EGIT_REPO_URI="https://codeberg.org/aleksandrov/gpkg.git"

# S="${WORKDIR}/gpkg"

LICENSE="GPL-2"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD ISC MIT MPL-2.0 Unicode-3.0"
SLOT="0"
KEYWORDS=""
IUSE="+sourceview +vte btrfs dracut appindicator grub2 kerneltools limine refind systemd systemd-boot"
REQUIRED_USE="
	kerneltools? ( ^^ ( limine grub2 systemd-boot refind ) )
	btrfs? ( kerneltools )
	dracut? ( kerneltools )
	limine? ( kerneltools )
	grub2? ( kerneltools )
	systemd-boot? ( kerneltools )
	refind? ( kerneltools )
"

DEPEND="
	>=gui-libs/gtk-4.12:4
	>=gui-libs/libadwaita-1.4:1
	>=dev-libs/glib-2.76:2
	sys-apps/dbus
	media-libs/graphene
	x11-libs/cairo
	x11-libs/pango
	x11-libs/gdk-pixbuf:2
	media-libs/freetype:2
	media-libs/fontconfig
	sys-devel/gettext
	vte? ( >=gui-libs/vte-0.74:2.91-gtk4 )
	sourceview? ( >=gui-libs/gtksourceview-5.10:5 )
"
RDEPEND="
	${DEPEND}
	sys-apps/portage
	app-portage/gentoolkit
	app-portage/eix
	sys-auth/polkit
	kerneltools? (
		|| ( sys-apps/systemd sys-apps/systemd-utils[kernel-install] )
		sys-kernel/linux-firmware
	)
	dracut? ( sys-kernel/dracut )
	btrfs? ( app-backup/snapper )
	appindicator? ( gnome-extra/gnome-shell-extension-appindicator )
"
BDEPEND="
	virtual/pkgconfig
"

QA_FLAGS_IGNORED="
	usr/bin/gpkg
	usr/bin/gpkg-daemon
"

PROPERTIES="live"
RESTRICT="network-sandbox"

src_unpack() {
    git-r3_src_unpack
}

src_prepare() {

	eapply_user
}

src_configure() {
	cargo_gen_config
	rm -f "${ECARGO_HOME}/config.toml" || die

	local myfeatures=(
		$(usev vte)
		$(usev sourceview)
		$(usev kerneltools)
		$(usev limine)
		$(usev grub2)
		$(usev systemd-boot)
		$(usev refind)
		$(usev btrfs)
		$(usev dracut)
	)
	cargo build --release --workspace ${myfeatures[*]/#/--features } || die
}

src_compile() {
	:
}

src_test() {
	cargo_src_test
}

src_install() {
	# Install binaries from workspace build (cargo_src_compile already built
	# everything with correct per-crate feature resolution; cargo install
	# would fail because gpkg-daemon doesn't define the GUI features)
	dobin target/release/gpkg-daemon
	dobin target/release/gpkg

	# D-Bus system bus configuration
	insinto /etc/dbus-1/system.d
	doins data/dbus/org.gentoo.PkgMngt.conf

	# D-Bus service activation file
	insinto /usr/share/dbus-1/system-services
	doins data/dbus/org.gentoo.PkgMngt.service

	# Polkit authorization policies
	insinto /usr/share/polkit-1/actions
	doins data/polkit/org.gentoo.pkgmngt.policy

	# Desktop file
	domenu data/org.gentoo.PkgMngt.desktop

	# Icons — all sizes (PNG) + scalable SVGs + systray status icons
	insinto /usr/share/icons
	doins -r data/icons/hicolor

	# AppStream metainfo
	insinto /usr/share/metainfo
	doins data/org.gentoo.PkgMngt.metainfo.xml

	# CSS stylesheet
	insinto /usr/share/gpkg
	doins data/style/style.css

#	# Locale
#	insinto /usr/share/locale/fr/LC_MESSAGES
#	newins po/fr.mo gpkg.mo

# Locale: install all compiled .mo files
for mo in target/release/build/gpkg-gui-*/out/*.mo; do
    lang=$(basename "$mo" .mo)
    insinto /usr/share/locale/${lang}/LC_MESSAGES
    newins "$mo" gpkg.mo
done

	# Kernel tools (USE=kerneltools)
	if use kerneltools; then
		exeinto /usr/lib/kernel
		doexe data/kernel/scripts/compile-kernel.sh

		exeinto /usr/lib/kernel/install.d
		use limine && doexe data/kernel/hooks/95-limine-gentoo.install

		# Portage hook for auto-compile on emerge *-sources
		insinto /etc/portage
		newins data/kernel/hooks/portage-bashrc bashrc

		insinto /etc/kernel
		doins data/kernel/configs/auto-compile.conf
		doins data/kernel/configs/default-type

		keepdir /var/log/kernel-compile
	fi

	# Systemd service unit
	if use systemd; then
		systemd_dounit systemd/gpkg-daemon.service
	fi

	# OpenRC init script and config
	newinitd "${FILESDIR}"/gpkg-daemon.initd gpkg-daemon
	newconfd "${FILESDIR}"/gpkg-daemon.confd gpkg-daemon

	# Documentation
	dodoc README.md
}

pkg_postinst() {
	# 1. Configuration Setup
	local make_conf="${EROOT}/etc/portage/make.conf"
	local gpkg_conf="${EROOT}/etc/portage/gpkg-defaults.conf"

	# Create the helper config if it doesn't exist
	if [[ ! -f "${gpkg_conf}" ]]; then
		einfo "Creating ${gpkg_conf} with recommended defaults..."
		cat <<-EOF > "${gpkg_conf}"
# Recommended defaults for gpkg.
# WARNING: If you use a binhost, consider setting --with-bdeps=n and --complete-graph=n
EMERGE_DEFAULT_OPTS="\${EMERGE_DEFAULT_OPTS} --backtrack=50 --binpkg-respect-use=y --ask=n --verbose --with-bdeps=y --complete-graph=y"
EOF
	fi

	# Source the gpkg config in the main make.conf if not already present
	if [[ -f "${make_conf}" ]]; then
		if ! grep -q "source ${gpkg_conf}" "${make_conf}"; then
			einfo "Adding source line to ${make_conf}"
			echo -e "\n# Added by gpkg\nsource ${gpkg_conf}" >> "${make_conf}"
		fi
	fi

	# 2. Performance Warning (Always show)
	echo
	ewarn "!!! PERFORMANCE NOTICE !!!"
	ewarn "gpkg settings are sourced in: ${make_conf}"
	ewarn "If you experience slow dependency calculations (15+ min) while using"
	ewarn "a BINARY HOST, please edit ${gpkg_conf} and set:"
	ewarn "  --with-bdeps=n"
	ewarn "  --complete-graph=n"
	echo

	# 3. Standard XDG updates
	xdg_icon_cache_update
	xdg_desktop_database_update

	# 4. Daemon and usage instructions
	elog ""
	elog "To start the gpkg daemon:"
	elog ""
	if use systemd; then
		elog "  systemctl enable --now gpkg-daemon"
	else
		elog "  rc-update add gpkg-daemon default"
		elog "  rc-service gpkg-daemon start"
	fi
	elog ""
	elog "Then launch the GUI:  gpkg"
	elog ""
	elog "The console tab works without the daemon."
	elog "All other tabs require a running gpkg-daemon."
	elog ""

	# 5. Kernel tools integration
	if use kerneltools; then
		elog "Kernel tools installed:"
		elog "  - Automatic kernel compilation hooks"
		elog "  - Kernel Conf tab in the GUI"
		use limine && elog "  - Limine bootloader integration"
		use btrfs && elog "  - Btrfs snapshot management"
		elog ""
		elog "To enable auto-compilation, toggle it in the Kernel Conf tab"
		elog "or edit /etc/kernel/auto-compile.conf"
		elog ""
	fi
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_desktop_database_update
}
