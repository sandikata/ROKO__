# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit gnome2-utils

DESCRIPTION="Unofficial extensions for GNOME Shell"

HOMEPAGE=""

LICENSE="GPL-2"
SLOT="0"
IUSE="weather system-monitor mediaplayer icon-manager pidgin gpaste cpufreq arrow-selector windowoverlay-icons activity-journal"
KEYWORDS="~amd64 ~x86"

RDEPEND="weather? ( gnome-extra/gnome-shell-extensions-weather )
	 system-monitor? ( gnome-extra/gnome-shell-extensions-system-monitor )
	 mediaplayer? ( gnome-extra/gnome-shell-extensions-mediaplayer )
	 icon-manager? ( gnome-extra/gnome-shell-extensions-icon-manager )
	 pidgin? ( gnome-extra/gnome-shell-extensions-pidgin )
	 gpaste? ( gnome-extra/gnome-shell-extensions-gpaste )
	 arrow-selector? ( gnome-extra/gnome-shell-extensions-arrow-key-window-selector )
	 windowoverlay-icons? ( gnome-extra/gnome-shell-extensions-windowoverlay-icons )
	 activity-journal? ( gnome-extra/gnome-shell-extensions-activity-journal )"
