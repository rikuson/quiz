#!/usr/bin/env bash

test_description='Test rm'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "rm" command' '
	"$QUIZ" init $KEY1 &&
	"$QUIZ" generate cred1 43 &&
	"$QUIZ" rm cred1 &&
	[[ ! -e $QUIZ_STORE_DIR/cred1.gpg ]]
'

test_expect_success 'Test "rm" command with spaces' '
	"$QUIZ" generate "hello i have spaces" 43 &&
	[[ -e $QUIZ_STORE_DIR/"hello i have spaces".gpg ]] &&
	"$QUIZ" rm "hello i have spaces" &&
	[[ ! -e $QUIZ_STORE_DIR/"hello i have spaces".gpg ]]
'

test_expect_success 'Test "rm" of non-existent quiz' '
	test_must_fail "$QUIZ" rm does-not-exist
'

test_done
