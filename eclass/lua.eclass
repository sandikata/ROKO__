# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: lua.eclass
# @MAINTAINER:
# hawking@gentoo.org
#
# @BLURB:
# A Utility Eclass that should be inherited by anything that deals with Lua or Lua modules.
# @DESCRIPTION:
# Some useful functions for dealing with Lua.

inherit multilib

# @FUNCTION: lua_version
# @DESCRIPTION:
# Run without arguments, it sets LUAVER
lua_version() {
	local luaver=
	luaver="$(lua -v 2>&1| cut -d' ' -f2)"
	export LUAVER="${luaver%.*}"
}

# @FUNCTION: lua_get_sharedir
# Run without arguments, returns the share dir where lua modules are installed.
lua_get_sharedir() {
	lua_version
	echo -n /usr/share/lua/${LUAVER}/
}

# @FUNCTION: lua_get_libdir
# Run without arguments, returns the library dir where lua C modules are
# installed.
lua_get_libdir() {
	lua_version
	echo -n /usr/$(get_libdir)/lua/${LUAVER}
}

# @FUNCTION: lua_install_module
# @DESCRIPTION:
# Install a lua module
lua_install_module() {
	lua_version

	insinto /usr/share/lua/${LUAVER}
	doins $@ || die "doins failed"
}

# @FUNCTION: lua_install_cmodule
# @DESCRIPTION:
# Install a Lua module which is a .so file.
lua_install_cmodule() {
	lua_version

	insinto /usr/$(get_libdir)/lua/${LUAVER}
	doins $@ || die "doins failed"
}

