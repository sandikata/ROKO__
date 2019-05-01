# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit bash-completion-r1 golang-base golang-vcs-snapshot linux-info systemd

DESCRIPTION="Service and tools for management of snap packages"
HOMEPAGE="http://snapcraft.io/"
SRC_URI="https://github.com/snapcore/${PN}/releases/download/${PV}/${PN}_${PV}.vendor.tar.xz -> ${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="primaryuri"

MY_S="${S}/src/github.com/snapcore/${PN}"
PKG_LINGUAS="am bs ca cs da de el en_GB es fi fr gl hr ia id it ja lt ms nb oc pt_BR pt ru sv tr ug zh_CN"

CONFIG_CHECK="	CGROUPS \
		CGROUP_DEVICE \
		CGROUP_FREEZER \
		NAMESPACES \
		SQUASHFS \
		SQUASHFS_ZLIB \
		SQUASHFS_LZO \
		SQUASHFS_XZ \
		BLK_DEV_LOOP \
		SECCOMP \
		SECCOMP_FILTER \
		SECURITY_APPARMOR"

export GOPATH="${S}/${PN}"

EGO_PN="github.com/snapcore/${PN}"

RDEPEND="!sys-apps/snap-confine
	sys-libs/libseccomp[static-libs]
	sys-apps/apparmor
	dev-libs/glib
	sys-fs/squashfs-tools:*"
DEPEND="${RDEPEND}
	>=dev-lang/go-1.9
	dev-python/docutils
	sys-devel/gettext
	sys-fs/xfsprogs"

src_configure() {
	debug-print-function $FUNCNAME "$@"

	cd "${MY_S}/cmd/"
	cat <<EOF > "${MY_S}/cmd/version_generated.go"
package cmd

func init() {
        Version = "${PV}"
}
EOF
	echo "${PV}" > "${MY_S}/cmd/VERSION"
	echo "VERSION=${PV}" > "${MY_S}/data/info"

	test -f configure.ac	# Sanity check, are we in the right directory?
	rm -f config.status
	autoreconf -i -f	# Regenerate the build system
	econf --enable-maintainer-mode --disable-silent-rules --enable-apparmor
}

src_compile() {
	debug-print-function $FUNCNAME "$@"

	C="${MY_S}/cmd/"
	emake -C "${MY_S}/data/"
	emake -C "${C}"

	# Generate snapd-apparmor systemd unit
	emake -C "${MY_S}/data/systemd"

	export GOPATH="${S}/"
	VX="-v -x" # or "-v -x" for verbosity
	for I in snapctl snap-exec snap snapd snap-seccomp snap-update-ns; do
		einfo "go building: ${I}"
		go install $VX "github.com/snapcore/${PN}/cmd/${I}"
	done
	"${S}/bin/snap" help --man > "${C}/snap/snap.1"
	rst2man.py "${C}/snap-confine/"snap-confine.{rst,1}
	rst2man.py "${C}/snap-discard-ns/"snap-discard-ns.{rst,5}

	for I in ${PKG_LINGUAS};do
		einfo "mo building: ${I}"
		msgfmt -v --output-file="${MY_S}/po/${I}.mo" "${MY_S}/po/${I}.po"
	done

	# Generate apparmor profile
	sed -e 's,[@]LIBEXECDIR[@],/usr/lib64/snapd,g' \
		-e 's,[@]SNAP_MOUNT_DIR[@],/snap,' \
		"${C}/snap-confine/snap-confine.apparmor.in" \
		> "${C}/snap-confine/usr.lib.snapd.snap-confine.real"
}

src_install() {
	debug-print-function $FUNCNAME "$@"

	C="${MY_S}/cmd"
	DS="${MY_S}/data/systemd"

	doman \
		"${C}/snap-confine/snap-confine.1" \
		"${C}/snap/snap.1" \
		"${C}/snap-discard-ns/snap-discard-ns.5"

	systemd_dounit \
		"${DS}/snapd.service" \
		"${DS}/snapd.socket" \
		"${DS}/snapd.apparmor.service"

	cd "${MY_S}"
	dodir  \
		"/etc/profile.d" \
		"/usr/lib64/snapd" \
		"/usr/share/dbus-1/services" \
		"/usr/share/polkit-1/actions" \
		"/var/lib/snapd"

	exeinto "/usr/lib64/${PN}"
	doexe \
			data/completion/etelpmoc.sh \
			data/completion/complete.sh
	insinto "/usr/share/selinux/targeted/include/snapd/"
	doins \
			data/selinux/snappy.if \
			data/selinux/snappy.te \
			data/selinux/snappy.fc
	doexe "${C}"/decode-mount-opts/decode-mount-opts
	doexe "${C}"/snap-discard-ns/snap-discard-ns

	insinto "/usr/share/dbus-1/services/"
	doins data/dbus/io.snapcraft.Launcher.service
	insinto "/usr/share/polkit-1/actions/"
	doins data/polkit/io.snapcraft.snapd.policy
	doexe "${S}/bin"/snapd
	doexe "${S}/bin"/snap-exec
	doexe "${S}/bin"/snap-update-ns
	doexe "${S}/bin"/snap-seccomp ### missing libseccomp
	doexe "${MY_S}/cmd/snapd-apparmor/snapd-apparmor"

	insinto "/usr/lib64/snapd/"
	doins "${MY_S}/data/info"
	insinto "/etc/profile.d/"
	doins data/env/snapd.sh
	insinto "/etc/apparmor.d"
	doins "${C}/snap-confine/usr.lib.snapd.snap-confine.real"
	
	dodoc	"${MY_S}/packaging/ubuntu-14.04"/copyright \
		"${MY_S}/packaging/ubuntu-16.04"/changelog

	dobin "${S}/bin"/{snap,snapctl}

	dobashcomp data/completion/snap

	domo "${MY_S}/po"/*.mo

	doexe "${C}"/snap-confine/snap-device-helper
	exeopts -m 6755
	doexe "${C}"/snap-confine/snap-confine
}

pkg_postrm() {
	debug-print-function $FUNCNAME "$@"

	if systemctl is-active --quiet snapd.service snapd.socket; then
		snapd_was_active=yes
		systemctl stop snapd.socket snapd.service snapd.apparmor.service
	fi
	umount /var/lib/snapd/snaps/*.snap
	rm -rf /var/lib/snapd/*
	rm -f /etc/systemd/system/snap-*.mount
	rm -f /etc/systemd/system/snap-*.service
	rm -f /etc/systemd/system/multi-user.target.wants/snap-*.mount
	rm -rf /snap/*
}

pkg_postinst() {
	CMDLINE=$(cat /proc/cmdline) 
	if [[ $CMDLINE == *"apparmor=1"* ]] && [[ $CMDLINE == *"security=apparmor"* ]]; then
	    apparmor_parser -r /etc/apparmor.d/usr.lib.snapd.snap-confine.real
		einfo "Enable snapd snapd.socket and snapd.apparmor service, then reload the apparmor service to start using snapd"
	else 
		einfo ""
		einfo "Apparmor needs to be enabled and configred as the default security"
		einfo "Ensure /etc/default/grub is updated to include:"
		einfo "GRUB_CMDLINE_LINIX_DEFAULT=\"apparmor=1 security=apparmor\""
		einfo "Then update grub, enable snapd, snapd.socket and snapd.apparmor and reboot"
		einfo ""
	fi
}
