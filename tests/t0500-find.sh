#!/usr/bin/env bash

test_description='Find check'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure find resolves correct files' '
	"$QUIZ" init $KEY1 &&
	"$QUIZ" generate Something/neat 19 &&
	"$QUIZ" generate Anotherthing/okay 38 &&
	"$QUIZ" generate Fish 12 &&
	"$QUIZ" generate Fishthings 122 &&
	"$QUIZ" generate Fishies/stuff 21 &&
	"$QUIZ" generate Fishies/otherstuff 1234 &&
	[[ $("$QUIZ" find fish | sed "s/^[ \`|-]*//g;s/$(printf \\x1b)\\[[0-9;]*[a-zA-Z]//g" | tr "\\n" -) == "Search Terms: fish-Fish-Fishies-otherstuff-stuff-Fishthings-" ]]
'

test_done
