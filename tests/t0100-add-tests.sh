#!/usr/bin/env bash

test_description='Test add'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "add" command' '
	"$QUIZ" init &&
	echo "Hello world" | "$QUIZ" add cred1 &&
	[[ $("$QUIZ" show cred1) == "Hello world" ]]
'

test_done
