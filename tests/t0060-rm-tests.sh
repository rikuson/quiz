#!/usr/bin/env bash

test_description='Test rm'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "rm" command' '
	"$QUIZ" init &&
	"$QUIZ" add cred1 <<<"$($TEST_HOME/fake-answer.sh 43)" &&
	"$QUIZ" rm cred1 &&
	[[ ! -e $QUIZ_STORE_DIR/cred1.yml ]]
'

test_expect_success 'Test "rm" command with spaces' '
	"$QUIZ" add "hello i have spaces" <<<"$($TEST_HOME/fake-answer.sh 43)" &&
	[[ -e $QUIZ_STORE_DIR/"hello i have spaces".yml ]] &&
	"$QUIZ" rm "hello i have spaces" &&
	[[ ! -e $QUIZ_STORE_DIR/"hello i have spaces".yml ]]
'

test_expect_success 'Test "rm" of non-existent quiz' '
	test_must_fail "$QUIZ" rm does-not-exist
'

test_done
