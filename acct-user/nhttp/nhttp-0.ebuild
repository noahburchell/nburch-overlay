# Copyright 2026 Noah Burchell
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit acct-user

DESCRIPTION="user app-misc/nhttp serves files as"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( nhttp )

acct-user_add_deps
