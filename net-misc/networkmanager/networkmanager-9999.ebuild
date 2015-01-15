# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
VALA_MIN_API_VERSION="0.18"
VALA_USE_DEPEND="vapigen"

inherit versionator bash-completion-r1 systemd user toolchain-funcs vala virtualx udev eutils
[ ${PV} == 9999 ] && inherit git-r3 autotools

DESCRIPTION="A network configuration daemon"
HOMEPAGE="http://www.gnome.org/projects/NetworkManager/"
EGIT_REPO_URI="http://anongit.freedesktop.org/git/NetworkManager/NetworkManager.git"

if [ ${PV} != 9999 ]; then
	U_PN=NetworkManager
	U_P=${U_PN}-${PV}
	SRC_URI="https://download.gnome.org/sources/${U_PN}/$(get_version_component_range -2)/${U_P}.tar.xz"
	KEYWORDS="~x86 ~amd64"
	S="${WORKDIR}/${U_P}"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="avahi bluetooth +connection-sharing +consolekit +dhclient dhcpcd gnutls
+introspection modemmanager +nss +openrc +ppp resolvconf systemd test vala
+wext doc"
REQUIRED_USE="
	modemmanager? ( ppp )
	^^ ( nss gnutls )
	^^ ( dhclient dhcpcd )
"
COMMON_DEPEND="
	>=sys-apps/dbus-1.2
	>=dev-libs/dbus-glib-0.94
	>=dev-libs/glib-2.30
	>=dev-libs/libnl-3.2.7:3=
	net-libs/libndp
	>=sys-auth/polkit-0.106
	>=net-libs/libsoup-2.26:2.4=
	>=net-wireless/wpa_supplicant-0.7.3-r3[dbus]
	>=virtual/udev-165
	bluetooth? ( >=net-wireless/bluez-4.82 )
	avahi? ( net-dns/avahi:=[autoipd] )
	connection-sharing? (
		net-dns/dnsmasq
		net-firewall/iptables )
	gnutls? (
		dev-libs/libgcrypt:=
		net-libs/gnutls:= )
	modemmanager? ( >=net-misc/modemmanager-0.7.991 )
	nss? ( >=dev-libs/nss-3.11:= )
	dhclient? ( =net-misc/dhcp-4*[client] )
	dhcpcd? ( >=net-misc/dhcpcd-4.0.0_rc3 )
	introspection? ( >=dev-libs/gobject-introspection-0.10.3 )
	ppp? ( >=net-dialup/ppp-2.4.5[ipv6] )
	resolvconf? ( net-dns/openresolv )
	systemd? ( >=sys-apps/systemd-200 )
	!systemd? ( sys-power/upower )
"
RDEPEND="${COMMON_DEPEND}
	consolekit? ( sys-auth/consolekit )
"
DEPEND="${COMMON_DEPEND}
	openrc? ( dev-util/systemd2openrc )
	doc? (
		dev-perl/yaml
		dev-util/gtk-doc
		dev-util/gtk-doc-am )
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	>=sys-kernel/linux-headers-2.6.29
	virtual/pkgconfig
	vala? ( $(vala_depend) )
	test? (
		dev-lang/python:2.7
		dev-python/dbus-python[python_targets_python2_7]
		dev-python/pygobject:2[python_targets_python2_7] )
"

src_prepare() {
	use vala && vala_src_prepare
}

src_configure() {
	NOCONFIGURE=yes ./autogen.sh

	econf \
		--disable-more-warnings \
		--localstatedir=/var \
		--with-dbus-sys-dir=/etc/dbus-1/system.d \
		--with-udev-dir="$(get_udevdir)" \
		--with-iptables=/sbin/iptables \
		--enable-concheck \
		--with-crypto=$(usex nss nss gnutls) \
		--with-suspend-resume=$(usex systemd systemd upower) \
		--disable-wimax \
		$(use_enable introspection) \
		$(use_enable vala) \
		$(use_enable ppp) \
		$(use_enable test tests) \
		$(use_enable doc gtk-doc) \
		$(use_with systemd systemd-logind) \
		$(use_with consolekit) \
		$(use_with dhclient) \
		$(use_with dhcpcd) \
		$(use_with modemmanager modem-manager-1) \
		$(use_with resolvconf) \
		$(use_with wext) \
		"$(systemd_with_unitdir)"
}

src_compile() {
	default

	if use openrc; then
		mkdir openrc || die
		systemd2openrc data/NetworkManager.service --nodeps --pidfile /etc/NetworkManager/NetworkManager.pid > openrc/NetworkManager || die
		systemd2openrc data/NetworkManager-dispatcher.service > openrc/NetworkManager-dispatcher || die
		systemd2openrc data/NetworkManager-wait-online.service --nodeps > openrc/NetworkManager-wait-online || die

		echo -ne "\ndepend() {\n    need NetworkManager\n    provide net\n}\n" >> openrc/NetworkManager-wait-online
	fi
}

src_install() {
	default

	keepdir /etc/NetworkManager/dispatcher.d

	for i in data/*.service; do
		systemd_dounit $i || die
	done
	if use openrc; then
		for i in openrc/*; do
			doinitd $i || die
		done
	fi

	systemd_enable_service network-online.target NetworkManager-wait-online.service

	# Add keyfile plugin support
	keepdir /etc/NetworkManager/system-connections
	chmod 0600 "${ED}"/etc/NetworkManager/system-connections/.keep* # bug #383765

	# Allow users in plugdev group to modify system connections
	insinto /usr/share/polkit-1/rules.d/
	doins "${FILESDIR}/01-org.freedesktop.NetworkManager.settings.modify.system.rules"

	# Remove useless .la files
	prune_libtool_files --modules
}
