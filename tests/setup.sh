# This file should be sourced by all test-scripts
#
# This scripts sets the following:
#   $QUIZ	Full path to quiz-store script to test
#   $GPG	Name of gpg executable
#   $KEY{1..5}	GPG key ids of testing keys
#   $TEST_HOME	This folder


# Unset config vars
unset QUIZ_STORE_DIR
unset QUIZ_STORE_KEY
unset QUIZ_STORE_GIT
unset QUIZ_STORE_GPG_OPTS
unset QUIZ_STORE_UMASK
unset QUIZ_STORE_GENERATED_LENGTH
unset QUIZ_STORE_CHARACTER_SET
unset QUIZ_STORE_CHARACTER_SET_NO_SYMBOLS
unset QUIZ_STORE_ENABLE_EXTENSIONS
unset QUIZ_STORE_EXTENSIONS_DIR
unset QUIZ_STORE_SIGNING_KEY
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


QUIZ="$TEST_HOME/../src/quiz-store.sh"
if [[ ! -e $QUIZ ]]; then
	echo "Could not find quiz-store.sh"
	exit 1
fi

# Note: the assumption is the test key is unencrypted.
export GNUPGHOME="$TEST_HOME/gnupg/"
chmod 700 "$GNUPGHOME"
GPG="gpg"
command -v gpg2 &>/dev/null && GPG="gpg2"

# We don't want any currently running agent to conflict.
unset GPG_AGENT_INFO

KEY1="D4C78DB7920E1E27F5416B81CC9DB947CF90C77B"  # quiz test key 1
KEY2="70BD448330ACF0653645B8F2B4DDBFF0D774A374"  # quiz test key 2
KEY3="62EBE74BE834C2EC71E6414595C4B715EB7D54A8"  # quiz test key 3
KEY4="9378267629F989A0E96677B7976DD3D6E4691410"  # quiz test key 4
KEY5="4D2AFBDE67C60F5999D143AFA6E073D439E5020C"  # quiz test key 5
