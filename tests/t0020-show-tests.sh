#!/usr/bin/env bash

test_description='Test show'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "show" command' '
	"$QUIZ" init $KEY1 &&
	"$QUIZ" generate cred1 20 &&
	"$QUIZ" show cred1
'

test_expect_success 'Test "show" command with spaces' '
	"$QUIZ" insert -e "I am a cred with lots of spaces"<<<"BLAH!!" &&
	[[ $("$QUIZ" show "I am a cred with lots of spaces") == "BLAH!!" ]]
'

test_expect_success 'Test "show" command with unicode' '
	"$QUIZ" generate 🏠 &&
	"$QUIZ" show | grep -q '🏠'
'

test_expect_success 'Test "show" of nonexistant quiz' '
	test_must_fail "$QUIZ" show cred2
'

test_done
