#!/usr/bin/env bash

test_description='Test edit'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "edit" command' '
	"$QUIZ" init &&
	export PATH="$TEST_HOME:$PATH" &&
	export EDITOR="fake-editor-change-answer.sh" &&
	export FAKE_EDITOR_ANSWER="seed quiz" &&
	"$QUIZ" add -m cred1 &&
	export FAKE_EDITOR_ANSWER="big fat fake quiz" &&
	"$QUIZ" edit cred1 &&
	[[ $("$QUIZ" show cred1 | head -1) == "$FAKE_EDITOR_ANSWER" ]]
'

test_done
