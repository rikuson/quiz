#!/usr/bin/env bash

test_description='Grep check'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure grep prints normal lines' '
	"$QUIZ" init &&
	"$QUIZ" add blah1 <<<"hello" &&
	"$QUIZ" add blah2 <<<"my name is" &&
	"$QUIZ" add folder/blah3 <<<"I hate computers" &&
	"$QUIZ" add blah4 <<<"me too!" &&
	"$QUIZ" add folder/where/blah5 <<<"They are hell" &&
	results="$("$QUIZ" grep hell)" &&
	[[ $(wc -l <<<"$results") -eq 4 ]] &&
	grep -q blah5 <<<"$results" &&
	grep -q blah1 <<<"$results" &&
	grep -q "They are" <<<"$results"
'

test_expect_success 'Test passing the "-i" option to grep' '
	"$QUIZ" init &&
	"$QUIZ" add blah1 <<<"I wonder..." &&
	"$QUIZ" add blah2 <<<"Will it ignore" &&
	"$QUIZ" add blah3 <<<"case when searching?" &&
	"$QUIZ" add folder/blah4 <<<"Yes, it does. Wonderful!" &&
	results="$("$QUIZ" grep -i wonder)" &&
	[[ $(wc -l <<<"$results") -eq 4 ]] &&
	grep -q blah1 <<<"$results" &&
	grep -q blah4 <<<"$results"
'

test_done
