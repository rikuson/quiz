#!/usr/bin/env bash

test_description='Find check'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Make sure find resolves correct files' '
	"$QUIZ" init &&
	"$QUIZ" insert Something/neat -e <<<"$($TEST_HOME/fake-answer.sh 19)" &&
	"$QUIZ" insert Anotherthing/okay -e <<<"$($TEST_HOME/fake-answer.sh 38)" &&
	"$QUIZ" insert Fish -e <<<"$($TEST_HOME/fake-answer.sh 12)" &&
	"$QUIZ" insert Fishthings -e <<<"$($TEST_HOME/fake-answer.sh 122)" &&
	"$QUIZ" insert Fishies/stuff -e <<<"$($TEST_HOME/fake-answer.sh 21)" &&
	"$QUIZ" insert Fishies/otherstuff -e <<<"$($TEST_HOME/fake-answer.sh 1234)" &&
	echo $("$QUIZ" find fish | "$SED" "s/[^ ]* //g;s/$(printf \\x1b)\\[[0-9;]*[a-zA-Z]//g" | tr "\\n" -) &&
	[[ $("$QUIZ" find fish | "$SED" "s/[^ ]* //g;s/$(printf \\x1b)\\[[0-9;]*[a-zA-Z]//g" | tr "\\n" -) == "fish-Fish-Fishies-otherstuff-stuff-Fishthings-" ]]
'

test_done
