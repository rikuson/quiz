# Copyright (C) 2012 - 2014 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
# This file is licensed under the GPLv2+. Please see COPYING for more information.

tmpdir() {
	[[ -n $SECURE_TMPDIR ]] && return
	SECURE_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/$PROGRAM.XXXXXXXXXXXXX")"
	remove_tmpfile() {
		rm -rf "$SECURE_TMPDIR"
	}
	trap remove_tmpfile EXIT
}

GETOPT="$({ test -x /usr/local/opt/gnu-getopt/bin/getopt && echo /usr/local/opt/gnu-getopt; } || brew --prefix gnu-getopt 2>/dev/null || { command -v port &>/dev/null && echo /opt/local; } || echo /usr/local)/bin/getopt"
SHRED="srm -f -z"
BASE64="openssl base64"
SED="gsed"
