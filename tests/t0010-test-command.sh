#!/usr/bin/env bash

test_description='Test the test command'
cd "$(dirname "$0")"
. ./setup.sh

test_expect_success 'Test command (interactive default)' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	answer1=$($TEST_HOME/fake-answer.sh 153) &&
	answer2=$($TEST_HOME/fake-answer.sh 24) &&
	answer3=$($TEST_HOME/fake-answer.sh 888) &&
	printf "question1\n${answer1}" | "$QUIZ" add quiz1 &&
	printf "question2\n${answer2}" | "$QUIZ" add quiz2 &&
	printf "question3\n${answer3}" | "$QUIZ" add quiz3 &&
	expected="Q) question1-OK--Q) question2-${answer2}--Q) question3-${answer3}--" &&
	actual="$(printf "$answer1\nfakeanswer\n" | "$QUIZ" test | "$SED" "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g" | tr "\\n" -)" &&
	[[ $actual == $expected ]]
'

test_expect_success 'Bare quiz invocation also runs the test' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question1\nanswer1" | "$QUIZ" add quiz1 &&
	actual="$(printf "answer1" | "$QUIZ" | "$SED" "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g" | tr "\\n" -)" &&
	[[ $actual == "Q) question1-OK--" ]]
'

test_expect_success 'Test command is case insensitive' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	answer1=answer1 &&
	answer2=AnSwEr2 &&
	answer3=ANSWER3 &&
	printf "question1\n${answer1}" | "$QUIZ" add quiz1 &&
	printf "question2\n${answer2}" | "$QUIZ" add quiz2 &&
	printf "question3\n${answer3}" | "$QUIZ" add quiz3 &&
	expected="Q) question1-OK--Q) question2-OK--Q) question3-OK--" &&
	actual="$(printf "ANSWER1\naNsWeR2\nanswer3" | "$QUIZ" test | "$SED" "s/\x1B\[[0-9;]\{1,\}[A-Za-z]//g" | tr "\\n" -)" &&
	[[ $actual == $expected ]]
'

test_expect_success '--non-interactive exits 0 when all answers correct' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question1\nanswer1" | "$QUIZ" add quiz1 &&
	printf "question2\nanswer2" | "$QUIZ" add quiz2 &&
	printf "answer1\nanswer2\n" | "$QUIZ" test --non-interactive
'

test_expect_success '--non-interactive exits 1 when any answer wrong' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question1\nanswer1" | "$QUIZ" add quiz1 &&
	printf "question2\nanswer2" | "$QUIZ" add quiz2 &&
	test_must_fail bash -c "printf \"answer1\nwrong\n\" | \"$QUIZ\" test --non-interactive"
'

test_expect_success '--non-interactive emits no ANSI color codes' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question1\nanswer1" | "$QUIZ" add quiz1 &&
	out="$(printf "answer1\n" | "$QUIZ" test --non-interactive)" &&
	! printf "%s" "$out" | grep -q $"\x1B"
'

test_expect_success '-n short flag works' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question1\nanswer1" | "$QUIZ" add quiz1 &&
	printf "answer1\n" | "$QUIZ" test -n
'

test_expect_success '--filter restricts the quiz set' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question1\nanswer1" | "$QUIZ" add quiz1 &&
	printf "question2\nanswer2" | "$QUIZ" add quiz2 &&
	printf "question3\nanswer3" | "$QUIZ" add quiz3 &&
	mkdir -p "$QUIZ_STORE_DIR/.filters" &&
	printf "#!/usr/bin/env bash\nhead -n 1\n" > "$QUIZ_STORE_DIR/.filters/onlyfirst.bash" &&
	expected="Q) question1-OK--" &&
	actual="$(printf "answer1\n" | "$QUIZ" test --non-interactive --filter onlyfirst | tr "\\n" -)" &&
	[[ $actual == $expected ]]
'

test_expect_success '--filter errors when filter is missing' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question1\nanswer1" | "$QUIZ" add quiz1 &&
	test_must_fail "$QUIZ" test --filter nope
'

test_expect_success '.quizrc supplies default filter' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question1\nanswer1" | "$QUIZ" add quiz1 &&
	printf "question2\nanswer2" | "$QUIZ" add quiz2 &&
	mkdir -p "$QUIZ_STORE_DIR/.filters" &&
	printf "#!/usr/bin/env bash\nhead -n 1\n" > "$QUIZ_STORE_DIR/.filters/onlyfirst.bash" &&
	printf "QUIZ_FILTER=onlyfirst\n" > "$QUIZ_STORE_DIR/.quizrc" &&
	expected="Q) question1-OK--" &&
	actual="$(printf "answer1\n" | "$QUIZ" test --non-interactive | tr "\\n" -)" &&
	[[ $actual == $expected ]]
'

test_expect_success 'Empty quiz store fails' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	test_must_fail "$QUIZ" test
'

test_expect_success 'Missing question fails' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "answer: fakeanswer" | "$QUIZ" add -m quiz1 &&
	test_must_fail "$QUIZ" test
'

test_expect_success 'Missing answer fails' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question: fakequestion" | "$QUIZ" add -m quiz1 &&
	test_must_fail "$QUIZ" test
'

test_expect_success 'Invalid YAML schema fails' '
	rm -rf "$QUIZ_STORE_DIR" &&
	"$QUIZ" init &&
	printf "question: fakequestion\nanswer: fakeanswer:" | "$QUIZ" add -m quiz1 &&
	test_must_fail "$QUIZ" test
'

test_done
