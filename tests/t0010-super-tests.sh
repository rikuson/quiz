#!/usr/bin/env bash

test_description='Test super command'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test super command' '
	"$QUIZ" init &&
	answer1=$($TEST_HOME/fake-answer.sh 153) &&
	answer2=$($TEST_HOME/fake-answer.sh 24) &&
	answer3=$($TEST_HOME/fake-answer.sh 888) &&
	printf "question1\n${answer1}" | "$QUIZ" add quiz1 &&
	printf "question2\n${answer2}" | "$QUIZ" add quiz2 &&
	printf "question3\n${answer3}" | "$QUIZ" add quiz3 &&
	expected="Q) question1-OK--Q) question2-${answer2}--Q) question3-${answer3}--" &&
	actual="$(printf "$answer1\nfakeanswer\n" | "$QUIZ" | "$SED" "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g" | tr "\\n" -)" &&
	[[ $actual == $expected ]]
'

test_expect_success 'Test case insentive' '
	"$QUIZ" init &&
	answer1=answer1 &&
	answer2=AnSwEr2 &&
	answer3=ANSWER3 &&
	printf "question1\n${answer1}" | "$QUIZ" add quiz1 &&
	printf "question2\n${answer2}" | "$QUIZ" add quiz2 &&
	printf "question3\n${answer3}" | "$QUIZ" add quiz3 &&
	expected="Q) question1-OK--Q) question2-OK--Q) question3-OK--" &&
	actual="$(printf "ANSWER1\naNsWeR2\nanswer3" | "$QUIZ" | "$SED" "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g" | tr "\\n" -)" &&
	[[ $actual == $expected ]]
'

test_expect_failure 'Test empty quiz store' '
	"$QUIZ"
'

test_expect_failure 'Test no question' '
	"$QUIZ" init &&
	printf "answer: fakeanswer" | "$QUIZ" add -m quiz1 &&
	"$QUIZ"
'

test_expect_failure 'Test no answer' '
	"$QUIZ" init &&
	printf "question: fakequestion" | "$QUIZ" add -m quiz1 &&
	"$QUIZ"
'

test_expect_failure 'Test invalid schema' '
	"$QUIZ" init &&
	printf "question: fakequestion\nanswer: fakeanswer:" | "$QUIZ" add -m quiz1 &&
	"$QUIZ"
'

test_done
