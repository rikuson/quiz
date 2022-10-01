#!/usr/bin/env bash

test_description='Grep check'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure grep prints normal lines' '
	"$QUIZ" init $KEY1 &&
	"$QUIZ" insert -e blah1 <<<"hello" &&
	"$QUIZ" insert -e blah2 <<<"my name is" &&
	"$QUIZ" insert -e folder/blah3 <<<"I hate computers" &&
	"$QUIZ" insert -e blah4 <<<"me too!" &&
	"$QUIZ" insert -e folder/where/blah5 <<<"They are hell" &&
	results="$("$QUIZ" grep hell)" &&
	[[ $(wc -l <<<"$results") -eq 4 ]] &&
	grep -q blah5 <<<"$results" &&
	grep -q blah1 <<<"$results" &&
	grep -q "They are" <<<"$results"
'

test_expect_success 'Test passing the "-i" option to grep' '
	"$QUIZ" init $KEY1 &&
	"$QUIZ" insert -e blah1 <<<"I wonder..." &&
	"$QUIZ" insert -e blah2 <<<"Will it ignore" &&
	"$QUIZ" insert -e blah3 <<<"case when searching?" &&
	"$QUIZ" insert -e folder/blah4 <<<"Yes, it does. Wonderful!" &&
	results="$("$QUIZ" grep -i wonder)" &&
	[[ $(wc -l <<<"$results") -eq 4 ]] &&
	grep -q blah1 <<<"$results" &&
	grep -q blah4 <<<"$results"
'

test_done
