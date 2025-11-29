# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

ACCT_USER_ID=-1
ACCT_USER_GROUPS=( angie )
ACCT_USER_HOME="/var/lib/angie"
ACCT_USER_HOME_OWNER="angie:angie"

IUSE="icingaweb2 mgraph"

acct-user_add_deps

RDEPEND+="
	icingaweb2? ( acct-group/icingacmd
		acct-group/icingaweb2 )
	mgraph? ( acct-group/mgraph )"

pkg_setup() {
	# www-apps/icingaweb2
	use icingaweb2 && ACCT_USER_GROUPS+=( icingacmd icingaweb2 )

	# net-mail/mailgraph
	use mgraph && ACCT_USER_GROUPS+=( mgraph )
}
