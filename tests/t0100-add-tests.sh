#!/usr/bin/env bash

test_description='Test add'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "add -m" opens editor with prefilled YAML template' '
	"$QUIZ" init &&
	export PATH="$TEST_HOME:$PATH" &&
	export EDITOR="fake-editor-change-answer.sh" &&
	export FAKE_EDITOR_ANSWER="question: hello" &&
	"$QUIZ" add -m cred1 &&
	output="$("$QUIZ" show cred1)" &&
	[[ "$output" == *"question: hello"* ]] &&
	[[ "$output" == *"answer: |"* ]]
'

test_done
