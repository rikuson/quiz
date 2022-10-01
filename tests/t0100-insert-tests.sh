#!/usr/bin/env bash

test_description='Test insert'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "insert" command' '
	"$QUIZ" init $KEY1 &&
	echo "Hello world" | "$QUIZ" insert -e cred1 &&
	[[ $("$QUIZ" show cred1) == "Hello world" ]]
'

test_done
