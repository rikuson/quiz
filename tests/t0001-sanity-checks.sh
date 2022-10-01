#!/usr/bin/env bash

test_description='Sanity checks'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure we can run quiz' '
	"$PASS" --help | grep "quiz: the standard unix quiz manager"
'

test_expect_success 'Make sure we can initialize our test store' '
	"$PASS" init $KEY1 &&
	[[ -e "$PASSWORD_STORE_DIR/.gpg-id" ]] &&
	[[ $(cat "$PASSWORD_STORE_DIR/.gpg-id") == "$KEY1" ]]
'

test_done
