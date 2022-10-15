#!/usr/bin/env bash

test_description='Test mv command'
cd "$(dirname "$0")"
. ./setup.sh

INITIAL_QUIZ="bla bla bla will we make it!!"

test_expect_success 'Basic move command' '
	"$QUIZ" init &&
	"$QUIZ" git init &&
	"$QUIZ" add -m cred1 <<<"$INITIAL_QUIZ" &&
	"$QUIZ" mv cred1 cred2 &&
	[[ -e $QUIZ_STORE_DIR/cred2.yml && ! -e $QUIZ_STORE_DIR/cred1.yml ]]
'

test_expect_success 'Directory creation' '
	"$QUIZ" mv cred2 directory/ &&
	[[ -d $QUIZ_STORE_DIR/directory && -e $QUIZ_STORE_DIR/directory/cred2.yml ]]
'

test_expect_success 'Directory creation with file rename and empty directory removal' '
	"$QUIZ" mv directory/cred2 "new directory with spaces"/cred &&
	[[ -d $QUIZ_STORE_DIR/"new directory with spaces" && -e $QUIZ_STORE_DIR/"new directory with spaces"/cred.yml && ! -e $QUIZ_STORE_DIR/directory ]]
'

test_expect_success 'Directory rename' '
	"$QUIZ" mv "new directory with spaces" anotherdirectory &&
	[[ -d $QUIZ_STORE_DIR/anotherdirectory && -e $QUIZ_STORE_DIR/anotherdirectory/cred.yml && ! -e $QUIZ_STORE_DIR/"new directory with spaces" ]]
'

test_expect_success 'Directory move into new directory' '
	"$QUIZ" mv anotherdirectory "new directory with spaces"/ &&
	[[ -d $QUIZ_STORE_DIR/"new directory with spaces"/anotherdirectory && -e $QUIZ_STORE_DIR/"new directory with spaces"/anotherdirectory/cred.yml && ! -e $QUIZ_STORE_DIR/anotherdirectory ]]
'

test_expect_success 'Multi-directory creation and multi-directory empty removal' '
	"$QUIZ" mv "new directory with spaces"/anotherdirectory/cred new1/new2/new3/new4/thecred &&
	"$QUIZ" mv new1/new2/new3/new4/thecred cred &&
	[[ ! -d $QUIZ_STORE_DIR/"new directory with spaces"/anotherdirectory && ! -d $QUIZ_STORE_DIR/new1/new2/new3/new4 && -e $QUIZ_STORE_DIR/cred.yml ]]
'

test_expect_success 'Password made it until the end' '
	[[ $("$QUIZ" show cred) == "$INITIAL_QUIZ" ]]
'

test_expect_success 'Git is consistent' '
	[[ -z $(git status --porcelain 2>&1) ]]
'

test_done
