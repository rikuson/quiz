#!/usr/bin/env bash

test_description='Test edit'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "edit" command' '
	"$QUIZ" init &&
	"$QUIZ" add cred1 <<<"$($TEST_HOME/fake-answer.sh 90)" &&
	export FAKE_EDITOR_ANSWER="big fat fake quiz" &&
	export PATH="$TEST_HOME:$PATH"
	export EDITOR="fake-editor-change-answer.sh" &&
	"$QUIZ" edit cred1 &&
	[[ $("$QUIZ" show cred1) == "$FAKE_EDITOR_ANSWER" ]]
'

test_done
