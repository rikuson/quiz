#!/usr/bin/env bash

test_description='Test add'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "add -m" assembles YAML from question and answer editors' '
	"$QUIZ" init &&
	export PATH="$TEST_HOME:$PATH" &&
	export EDITOR="fake-editor-write.sh" &&
	export FAKE_EDITOR_Q="my question" &&
	export FAKE_EDITOR_A="my answer" &&
	printf "\n\n" | "$QUIZ" add -m cred1 &&
	output="$("$QUIZ" show cred1)" &&
	[[ "$output" == *"question: |"*"  my question"* ]] &&
	[[ "$output" == *"answer: |"*"  my answer"* ]]
'

test_done
