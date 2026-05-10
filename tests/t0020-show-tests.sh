#!/usr/bin/env bash

test_description='Test show'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "show" command' '
	"$QUIZ" init &&
	"$QUIZ" add cred1 <<<"$($TEST_HOME/fake-answer.sh 20)" &&
	"$QUIZ" show cred1
'

test_expect_success 'Test "show" command with spaces' '
	export PATH="$TEST_HOME:$PATH" &&
	export EDITOR="fake-editor-write.sh" &&
	export FAKE_EDITOR_CONTENT="BLAH!!" &&
	"$QUIZ" add -m "I am a cred with lots of spaces" &&
	[[ "$("$QUIZ" show "I am a cred with lots of spaces")" == *"BLAH!!"* ]]
'

test_expect_success 'Test "show" command with unicode' '
	"$QUIZ" add 🏠 <<<"$(printf "fakeanswer")" &&
	"$QUIZ" show | grep -q '🏠'
'

test_expect_success 'Test "show" of nonexistant quiz' '
	test_must_fail "$QUIZ" show cred2
'

test_done
