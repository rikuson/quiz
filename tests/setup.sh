# This file should be sourced by all test-scripts
#
# This scripts sets the following:
#   $QUIZ	Full path to quiz-store script to test
#   $TEST_HOME	This folder


# Unset config vars
unset QUIZ_STORE_DIR
unset QUIZ_STORE_GIT
unset QUIZ_STORE_UMASK
unset QUIZ_STORE_ENABLE_EXTENSIONS
unset QUIZ_STORE_EXTENSIONS_DIR
unset EDITOR

# We must be called from tests/
TEST_HOME="$(pwd)"

. ./sharness.sh

export QUIZ_STORE_DIR="$SHARNESS_TRASH_DIRECTORY/test-store/"
rm -rf "$QUIZ_STORE_DIR"
mkdir -p "$QUIZ_STORE_DIR"
if [[ ! -d $QUIZ_STORE_DIR ]]; then
	echo "Could not create $QUIZ_STORE_DIR"
	exit 1
fi

export GIT_DIR="$QUIZ_STORE_DIR/.git"
export GIT_WORK_TREE="$QUIZ_STORE_DIR"
git config --global user.email "Pass-Automated-Testing-Suite@zx2c4.com"
git config --global user.name "Pass Automated Testing Suite"
git config --global init.defaultBranch master


QUIZ="$TEST_HOME/../src/quiz-store.sh"
if [[ ! -e $QUIZ ]]; then
	echo "Could not find quiz-store.sh"
	exit 1
fi

SED="sed"

source "$TEST_HOME/../src/platform/$(uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]').sh" 2>/dev/null # PLATFORM_FUNCTION_FILE
