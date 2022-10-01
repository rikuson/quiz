#!/usr/bin/env bash

test_description='Reencryption consistency'
cd "$(dirname "$0")"
. ./setup.sh

INITIAL_QUIZ="will this quiz live? a big question indeed..."

canonicalize_gpg_keys() {
	$GPG --list-keys --with-colons "$@" | sed -n 's/sub:[^:]*:[^:]*:[^:]*:\([^:]*\):[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[a-zA-Z]*e[a-zA-Z]*:.*/\1/p' | LC_ALL=C sort -u
}
gpg_keys_from_encrypted_file() {
	$GPG -v --no-secmem-warning --no-permission-warning --decrypt --list-only --keyid-format long "$1" 2>&1 | grep "public key is" | cut -d ' ' -f 5 | LC_ALL=C sort -u
}
gpg_keys_from_group() {
	local output="$($GPG --list-config --with-colons | sed -n "s/^cfg:group:$1:\\(.*\\)/\\1/p" | head -n 1)"
	local saved_ifs="$IFS"
	IFS=";"
	local keys=( $output )
	IFS="$saved_ifs"
	canonicalize_gpg_keys "${keys[@]}"
}

test_expect_success 'Setup initial key and git' '
	"$QUIZ" init $KEY1 && "$QUIZ" git init
'

test_expect_success 'Root key encryption' '
	"$QUIZ" insert -e folder/cred1 <<<"$INITIAL_QUIZ" &&
	[[ $(canonicalize_gpg_keys "$KEY1") == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/folder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption root single key' '
	"$QUIZ" init $KEY2 &&
	[[ $(canonicalize_gpg_keys "$KEY2") == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/folder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption root multiple key' '
	"$QUIZ" init $KEY2 $KEY3 $KEY1 &&
	[[ $(canonicalize_gpg_keys $KEY2 $KEY3 $KEY1) == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/folder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption root multiple key with string' '
	"$QUIZ" init $KEY2 $KEY3 $KEY1 "pass test key 4" &&
	[[ $(canonicalize_gpg_keys $KEY2 $KEY3 $KEY1 $KEY4) == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/folder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption root group' '
	"$QUIZ" init group1 &&
	[[ $(gpg_keys_from_group group1) == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/folder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption root group with spaces' '
	"$QUIZ" init "big group" &&
	[[ $(gpg_keys_from_group "big group") == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/folder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption root group with spaces and other keys' '
	"$QUIZ" init "big group" $KEY3 $KEY1 $KEY2 &&
	[[ $(canonicalize_gpg_keys $KEY3 $KEY1 $KEY2 $(gpg_keys_from_group "big group")) == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/folder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption root group and other keys' '
	"$QUIZ" init group2 $KEY3 $KEY1 $KEY2 &&
	[[ $(canonicalize_gpg_keys $KEY3 $KEY1 $KEY2 $(gpg_keys_from_group group2)) == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/folder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption root group to identical individual with no file change' '
	oldfile="$SHARNESS_TRASH_DIRECTORY/$RANDOM.$RANDOM.$RANDOM.$RANDOM.$RANDOM" &&
	"$QUIZ" init group1 &&
	cp "$QUIZ_STORE_DIR/folder/cred1.gpg" "$oldfile" &&
	"$QUIZ" init $KEY4 $KEY2 &&
	test_cmp "$QUIZ_STORE_DIR/folder/cred1.gpg" "$oldfile"
'

test_expect_success 'Reencryption subfolder multiple keys, copy' '
	"$QUIZ" init -p anotherfolder $KEY3 $KEY1 &&
	"$QUIZ" cp folder/cred1 anotherfolder/ &&
	[[ $(canonicalize_gpg_keys $KEY1 $KEY3) == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/anotherfolder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption subfolder multiple keys, move, deinit' '
	"$QUIZ" init -p anotherfolder2 $KEY3 $KEY4 $KEY2 &&
	"$QUIZ" mv -f anotherfolder anotherfolder2/ &&
	[[ $(canonicalize_gpg_keys $KEY1 $KEY3) == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/anotherfolder2/anotherfolder/cred1.gpg")" ]] &&
	"$QUIZ" init -p anotherfolder2/anotherfolder "" &&
	[[ $(canonicalize_gpg_keys $KEY3 $KEY4 $KEY2) == "$(gpg_keys_from_encrypted_file "$QUIZ_STORE_DIR/anotherfolder2/anotherfolder/cred1.gpg")" ]]
'

test_expect_success 'Reencryption skips links' '
	ln -s "$QUIZ_STORE_DIR/folder/cred1.gpg" "$QUIZ_STORE_DIR/folder/linked_cred.gpg" &&
	[[ -L $QUIZ_STORE_DIR/folder/linked_cred.gpg ]] &&
	git add "$QUIZ_STORE_DIR/folder/linked_cred.gpg" &&
	git commit "$QUIZ_STORE_DIR/folder/linked_cred.gpg" -m "Added linked cred" &&
	"$QUIZ" init -p folder $KEY3 &&
	[[ -L $QUIZ_STORE_DIR/folder/linked_cred.gpg ]]
'

#TODO: test with more varieties of move and copy!

test_expect_success 'Password lived through all transformations' '
	[[ $("$QUIZ" show anotherfolder2/anotherfolder/cred1) == "$INITIAL_QUIZ" ]]
'

test_expect_success 'Git picked up all changes throughout' '
	[[ -z $(git status --porcelain 2>&1) ]]
'

test_done
