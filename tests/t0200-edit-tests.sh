#!/usr/bin/env bash

test_description='Test edit'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "edit" command' '
	"$QUIZ" init $KEY1 &&
	"$QUIZ" generate cred1 90 &&
	export FAKE_EDITOR_QUIZ="big fat fake quiz" &&
	export PATH="$TEST_HOME:$PATH"
	export EDITOR="fake-editor-change-quiz.sh" &&
	"$QUIZ" edit cred1 &&
	[[ $("$QUIZ" show cred1) == "$FAKE_EDITOR_QUIZ" ]]
'

test_done
