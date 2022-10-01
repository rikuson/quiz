#!/usr/bin/env bash

test_description='Test generate'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test "generate" command' '
	"$QUIZ" init $KEY1 &&
	"$QUIZ" generate cred 19 &&
	[[ $("$QUIZ" show cred | wc -m) -eq 20 ]]
'

test_expect_success 'Test replacement of first line' '
	"$QUIZ" insert -m cred2 <<<"$(printf "this is a big\\nquiz\\nwith\\nmany\\nlines\\nin it bla bla")" &&
	"$QUIZ" generate -i cred2 23 &&
	[[ $("$QUIZ" show cred2) == "$(printf "%s\\nquiz\\nwith\\nmany\\nlines\\nin it bla bla" "$("$QUIZ" show cred2 | head -n 1)")" ]]
'

test_done
