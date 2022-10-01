# This file should be sourced by all test-scripts
#
# This scripts sets the following:
#   $PASS	Full path to quiz-store script to test
#   $GPG	Name of gpg executable
#   $KEY{1..5}	GPG key ids of testing keys
#   $TEST_HOME	This folder


# Unset config vars
unset PASSWORD_STORE_DIR
unset PASSWORD_STORE_KEY
unset PASSWORD_STORE_GIT
unset PASSWORD_STORE_GPG_OPTS
unset PASSWORD_STORE_X_SELECTION
unset PASSWORD_STORE_CLIP_TIME
unset PASSWORD_STORE_UMASK
unset PASSWORD_STORE_GENERATED_LENGTH
unset PASSWORD_STORE_CHARACTER_SET
unset PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS
unset PASSWORD_STORE_ENABLE_EXTENSIONS
unset PASSWORD_STORE_EXTENSIONS_DIR
unset PASSWORD_STORE_SIGNING_KEY
unset EDITOR

# We must be called from tests/
TEST_HOME="$(pwd)"

. ./sharness.sh

export PASSWORD_STORE_DIR="$SHARNESS_TRASH_DIRECTORY/test-store/"
rm -rf "$PASSWORD_STORE_DIR"
mkdir -p "$PASSWORD_STORE_DIR"
if [[ ! -d $PASSWORD_STORE_DIR ]]; then
	echo "Could not create $PASSWORD_STORE_DIR"
	exit 1
fi

export GIT_DIR="$PASSWORD_STORE_DIR/.git"
export GIT_WORK_TREE="$PASSWORD_STORE_DIR"
git config --global user.email "Pass-Automated-Testing-Suite@zx2c4.com"
git config --global user.name "Pass Automated Testing Suite"


PASS="$TEST_HOME/../src/quiz-store.sh"
if [[ ! -e $PASS ]]; then
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
