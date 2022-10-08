#!/usr/bin/env bash

test_description='Find check'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure find resolves correct files' '
	"$QUIZ" init &&
	"$QUIZ" insert Something/neat -e <<<"$(fake-answer.sh 19)" &&
	"$QUIZ" insert Anotherthing/okay -e <<<"$(fake-answer.sh 38)" &&
	"$QUIZ" insert Fish -e <<<"$(fake-answer.sh 12)" &&
	"$QUIZ" insert Fishthings -e <<<"$(fake-answer.sh 122)" &&
	"$QUIZ" insert Fishies/stuff -e <<<"$(fake-answer.sh 21)" &&
	"$QUIZ" insert Fishies/otherstuff -e <<<"$(fake-answer.sh 1234)" &&
	[[ $("$QUIZ" find fish | sed "s/^[ \`|-]*//g;s/$(printf \\x1b)\\[[0-9;]*[a-zA-Z]//g" | tr "\\n" -) == "Search Terms: fish-Fish-Fishies-otherstuff-stuff-Fishthings-" ]]
'

test_done
