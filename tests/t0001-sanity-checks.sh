#!/usr/bin/env bash

test_description='Sanity checks'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure we can run quiz' '
	"$QUIZ" --help | grep "quiz: the standard unix quiz manager"
'

test_expect_success 'Make sure we can initialize our test store' '
	"$QUIZ" init $KEY1 &&
	[[ -e "$QUIZ_STORE_DIR/.gpg-id" ]] &&
	[[ $(cat "$QUIZ_STORE_DIR/.gpg-id") == "$KEY1" ]]
'

test_done
