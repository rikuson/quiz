#!/usr/bin/env bash

test_description='Find check'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure find resolves correct files' '
	"$QUIZ" init &&
	"$QUIZ" add Something/neat <<<"$($TEST_HOME/fake-answer.sh 19)" &&
	"$QUIZ" add Anotherthing/okay <<<"$($TEST_HOME/fake-answer.sh 38)" &&
	"$QUIZ" add Fish <<<"$($TEST_HOME/fake-answer.sh 12)" &&
	"$QUIZ" add Fishthings <<<"$($TEST_HOME/fake-answer.sh 122)" &&
	"$QUIZ" add Fishies/stuff <<<"$($TEST_HOME/fake-answer.sh 21)" &&
	"$QUIZ" add Fishies/otherstuff <<<"$($TEST_HOME/fake-answer.sh 1234)" &&
	[[ $("$QUIZ" find fish | "$SED" "s/^[ \`|-]*//g;s/$(echo -ne "\u251C\|\u2500\|\u2502\|\u2514")//g;s/$(printf \\x1b)\\[[0-9;]*[a-zA-Z]//g" | tr "\\n" -) == "Search Terms: fish-Fish-Fishies-otherstuff-stuff-Fishthings-" ]]
'

test_done
