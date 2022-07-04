# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit meson multilib-minimal ninja-utils

DESCRIPTION="Optimise Linux system performance on demand"
HOMEPAGE="https://github.com/FeralInteractive/gamemode"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/FeralInteractive/gamemode.git"
	GAMEMODE_GIT_PTR="master"
	inherit git-r3
else
	GAMEMODE_GIT_PTR="${PV}"
	SRC_URI="https://github.com/FeralInteractive/gamemode/releases/download/${GAMEMODE_GIT_PTR}/${P}.tar.xz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD"
SLOT="0"
IUSE="systemd elogind"

REQUIRED_USE="
	?? ( elogind systemd )
"

RDEPEND="
	systemd? (
		>=sys-apps/systemd-236[${MULTILIB_USEDEP}]
	)
	elogind? (
		sys-auth/elogind
	)
	sys-auth/polkit
	acct-group/gamemode
	dev-libs/inih[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"

#PATCHES=("${FILESDIR}/pull-228-elogind-support.patch")

pkg_pretend() {
	elog
	elog "GameMode needs a kernel capable of SCHED_ISO to use its soft realtime"
	elog "feature. Examples of kernels providing that are sys-kernel/ck-source"
	elog "and sys-kernel/pf-sources."
	elog
	elog "Support for soft realtime is completely optional. It may provide the"
	elog "following benefits with systems having at least four CPU cores:"
	elog
	elog "  * more CPU shares allocated exclusively to the game"
	elog "  * reduced input lag and reduced thread latency"
	elog "  * more consistent frame times resulting in less microstutters"
	elog
	elog "You probably won't benefit from soft realtime mode and thus don't need"
	elog "SCHED_ISO if:"
	elog
	elog "  * Your CPU has less than four cores because the game may experience"
	elog "    priority inversion with the graphics driver (thus heuristics"
	elog "    automatically disable SCHED_ISO usage then)"
	elog "  * Your game uses busy-loops to interface with the graphics driver"
	elog "    but you may still force SCHED_ISO per configuation file, YMMV,"
	elog "    it depends on the graphics driver implementation, i.e. usage of"
	elog "    __GL_THREADED_OPTIMIZATIONS or similar."
	elog "  * If your game causes more than 70% CPU usage across all cores,"
	elog "    SCHED_ISO automatically turns off and on depending on usage and"
	elog "    is processed with higher-than-normal priority then (renice)."
	elog "    This auto-switching may result in a lesser game experience."
	elog
	elog "For more info look at:"
	elog "https://github.com/FeralInteractive/gamemode/blob/${GAMEMODE_GIT_PTR}/README.md"
	elog
}

multilib_src_configure() {
	if multilib_is_native_abi; then
		local emesonargs=(
			-Dwith-sd-bus-provider=$(usex systemd "systemd" "elogind")
		)
	else
		local emesonargs=(
			-Dwith-sd-bus-provider="no-daemon"
		)
	fi

	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

pkg_postinst() {
	elog
	elog "GameMode can renice your games. You need to be in the gamemode group for this to work."
	elog "Run the following command as root to add your user:"
	elog "# gpasswd -a USER gamemode  # with USER = your user name"
	elog

#<<<<<<< HEAD
	elog "Enable and start the daemon in your systemd user instance, then add"
	elog "LD_PRELOAD=\$LD_PRELOAD:/usr/\$LIB/libgamemodeauto.so %command%"
#=======
	elog "Enable and start the daemon in your systemd user instance,"
	elog "or simply run 'gamemoded -d' if using OpenRC, then add"
	elog "gamemoderun %command%"
#>>>>>>> 22c13dcfdcd463d12073e1f84212798b388cfc26
	elog "to the start options of any steam game to enable the performance"
	elog "governor as you start the game."
	elog
}
