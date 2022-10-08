#!/usr/bin/env bash

# Copyright (C) 2012 - 2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
# This file is licensed under the GPLv2+. Please see COPYING for more information.

umask "${QUIZ_STORE_UMASK:-077}"
set -o pipefail

PREFIX="${QUIZ_STORE_DIR:-$HOME/.quiz-store}"
EXTENSIONS="${QUIZ_STORE_EXTENSIONS_DIR:-$PREFIX/.extensions}"

unset GIT_DIR GIT_WORK_TREE GIT_NAMESPACE GIT_INDEX_FILE GIT_INDEX_VERSION GIT_OBJECT_DIRECTORY GIT_COMMON_DIR
export GIT_CEILING_DIRECTORIES="$PREFIX/.."

#
# BEGIN helper functions
#

set_git() {
	INNER_GIT_DIR="${1%/*}"
	while [[ ! -d $INNER_GIT_DIR && ${INNER_GIT_DIR%/*}/ == "${PREFIX%/}/"* ]]; do
		INNER_GIT_DIR="${INNER_GIT_DIR%/*}"
	done
	[[ $(git -C "$INNER_GIT_DIR" rev-parse --is-inside-work-tree 2>/dev/null) == true ]] || INNER_GIT_DIR=""
}
git_add_file() {
	[[ -n $INNER_GIT_DIR ]] || return
	git -C "$INNER_GIT_DIR" add "$1" || return
	[[ -n $(git -C "$INNER_GIT_DIR" status --porcelain "$1") ]] || return
	git_commit "$2"
}
git_commit() {
	local sign=""
	[[ -n $INNER_GIT_DIR ]] || return
	[[ $(git -C "$INNER_GIT_DIR" config --bool --get quiz.signcommits) == "true" ]] && sign="-S"
	git -C "$INNER_GIT_DIR" commit $sign -m "$1"
}
yesno() {
	[[ -t 0 ]] || return 0
	local response
	read -r -p "$1 [y/N] " response
	[[ $response == [yY] ]] || exit 1
}
die() {
	echo "$@" >&2
	exit 1
}
check_sneaky_paths() {
	local path
	for path in "$@"; do
		[[ $path =~ /\.\.$ || $path =~ ^\.\./ || $path =~ /\.\./ || $path =~ ^\.\.$ ]] && die "Error: You've attempted to quiz a sneaky path to quiz. Go home."
	done
}

#
# END helper functions
#

#
# BEGIN platform definable
#

tmpdir() {
	[[ -n $SECURE_TMPDIR ]] && return
	local warn=1
	[[ $1 == "nowarn" ]] && warn=0
	local template="$PROGRAM.XXXXXXXXXXXXX"
	if [[ -d /dev/shm && -w /dev/shm && -x /dev/shm ]]; then
		SECURE_TMPDIR="$(mktemp -d "/dev/shm/$template")"
		remove_tmpfile() {
			rm -rf "$SECURE_TMPDIR"
		}
		trap remove_tmpfile EXIT
	else
		[[ $warn -eq 1 ]] && yesno "$(cat <<-_EOF
		Your system does not have /dev/shm, which means that it may
		be difficult to entirely erase the temporary quiz file
		after editing.

		Are you sure you would like to continue?
		_EOF
		)"
		SECURE_TMPDIR="$(mktemp -d "${TMPDIR:-/tmp}/$template")"
		shred_tmpfile() {
			find "$SECURE_TMPDIR" -type f -exec $SHRED {} +
			rm -rf "$SECURE_TMPDIR"
		}
		trap shred_tmpfile EXIT
	fi

}
GETOPT="getopt"
SHRED="shred -f -z"
BASE64="base64"

source "$(dirname "$0")/platform/$(uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]').sh" 2>/dev/null # PLATFORM_FUNCTION_FILE

#
# END platform definable
#


#
# BEGIN subcommand functions
#

cmd_version() {
	cat <<-_EOF
	============================================
	= quiz: the standard unix quiz manager =
	=                                          =
	=                  v1.7.4                  =
	=                                          =
	=             Jason A. Donenfeld           =
	=               Jason@zx2c4.com            =
	=                                          =
	=      https://github.com/rikuson/quiz     =
	============================================
	_EOF
}

cmd_usage() {
	cmd_version
	echo
	cat <<-_EOF
	Usage:
	    $PROGRAM init
	        Initialize new quiz storage.
	    $PROGRAM [ls] [subfolder]
	        List quizzes.
	    $PROGRAM find quiz-names...
	    	List quizzes that match quiz-names.
	    $PROGRAM [show] quiz-name
	        Show existing quiz.
	    $PROGRAM grep [GREPOPTIONS] search-string
	        Search for quiz files containing search-string when decrypted.
	    $PROGRAM insert [--echo,-e | --multiline,-m] [--force,-f] quiz-name
	        Insert new quiz. Optionally, echo the quiz back to the console
	        during entry. Or, optionally, the entry may be multiline. Prompt before
	        overwriting existing quiz unless forced.
	    $PROGRAM edit quiz-name
	        Insert a new quiz or edit an existing quiz using ${EDITOR:-vi}.
	    $PROGRAM rm [--recursive,-r] [--force,-f] quiz-name
	        Remove existing quiz or directory, optionally forcefully.
	    $PROGRAM mv [--force,-f] old-path new-path
	        Renames or moves old-path to new-path, optionally forcefully.
	    $PROGRAM cp [--force,-f] old-path new-path
	        Copies old-path to new-path, optionally forcefully.
	    $PROGRAM git git-command-args...
	        If the quiz store is a git repository, execute a git command
	        specified by git-command-args.
	    $PROGRAM help
	        Show this text.
	    $PROGRAM version
	        Show version information.

	More information may be found in the quiz(1) man page.
	_EOF
}

cmd_init() {
	[[ $# -ne 0 ]] && die "Usage: $PROGRAM $COMMAND"
	mkdir -v "$PREFIX"
}

cmd_show() {
	[[ $# -gt 1 ]] && die "Usage: $PROGRAM $COMMAND [quiz-name]"

	local quiz
	local path="$1"
	local quizfile="$PREFIX/$path.txt"
	check_sneaky_paths "$path"
	if [[ -f $quizfile ]]; then
    quiz="$(cat "$quizfile" | $BASE64)" || exit $?
    echo "$quiz" | $BASE64 -d
	elif [[ -d $PREFIX/$path ]]; then
		if [[ -z $path ]]; then
			echo "Quiz Store"
		else
			echo "${path%\/}"
		fi
		tree -N -C -l --noreport "$PREFIX/$path" 3>&- | tail -n +2 | sed -E 's/\.txt(\x1B\[[0-9]+m)?( ->|$)/\1\2/g' # remove .txt at end of line, but keep colors
	elif [[ -z $path ]]; then
		die "Error: quiz store is empty. Try \"quiz init\"."
	else
		die "Error: $path is not in the quiz store."
	fi
}

cmd_find() {
	[[ $# -eq 0 ]] && die "Usage: $PROGRAM $COMMAND quiz-names..."
	IFS="," eval 'echo "Search Terms: $*"'
	local terms="*$(printf '%s*|*' "$@")"
	tree -N -C -l --noreport -P "${terms%|*}" --prune --matchdirs --ignore-case "$PREFIX" 3>&- | tail -n +2 | sed -E 's/\.txt(\x1B\[[0-9]+m)?( ->|$)/\1\2/g'
}

cmd_grep() {
	[[ $# -lt 1 ]] && die "Usage: $PROGRAM $COMMAND [GREPOPTIONS] search-string"
	local quizfile grepresults
	while read -r -d "" quizfile; do
		grepresults="$(cat "$quizfile" | grep --color=always "$@")"
		[[ $? -ne 0 ]] && continue
		quizfile="${quizfile%.txt}"
		quizfile="${quizfile#$PREFIX/}"
		local quizfile_dir="${quizfile%/*}/"
		[[ $quizfile_dir == "${quizfile}/" ]] && quizfile_dir=""
		quizfile="${quizfile##*/}"
		printf "\e[94m%s\e[1m%s\e[0m:\n" "$quizfile_dir" "$quizfile"
		echo "$grepresults"
	done < <(find -L "$PREFIX" -path '*/.git' -prune -o -path '*/.extensions' -prune -o -iname '*.txt' -print0)
}

cmd_insert() {
	local opts multiline=0 noecho=1 force=0
	opts="$($GETOPT -o mef -l multiline,echo,force -n "$PROGRAM" -- "$@")"
	local err=$?
	eval set -- "$opts"
	while true; do case $1 in
		-m|--multiline) multiline=1; shift ;;
		-e|--echo) noecho=0; shift ;;
		-f|--force) force=1; shift ;;
		--) shift; break ;;
	esac done

	[[ $err -ne 0 || ( $multiline -eq 1 && $noecho -eq 0 ) || $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND [--echo,-e | --multiline,-m] [--force,-f] quiz-name"
	local path="${1%/}"
	local quizfile="$PREFIX/$path.txt"
	check_sneaky_paths "$path"
	set_git "$quizfile"

	[[ $force -eq 0 && -e $quizfile ]] && yesno "An entry already exists for $path. Overwrite it?"

	mkdir -p -v "$PREFIX/$(dirname -- "$path")"

	if [[ $multiline -eq 1 ]]; then
		echo "Enter contents of $path and press Ctrl+D when finished:"
		echo
    local quiz=$(cat)
		echo "$quiz" > "$quizfile" || exit 1
	elif [[ $noecho -eq 1 ]]; then
		local quiz
		while true; do
			read -r -p "Enter answer for $path: " -s quiz || exit 1
			echo
			echo "$quiz" > "$quizfile" || exit 1
			break
		done
	else
		local quiz
		read -r -p "Enter answer for $path: " -e quiz
		echo "$quiz" > "$quizfile" || exit 1
	fi
	git_add_file "$quizfile" "Add given answer for $path to store."
}

cmd_edit() {
	[[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND quiz-name"

	local path="${1%/}"
	check_sneaky_paths "$path"
	mkdir -p -v "$PREFIX/$(dirname -- "$path")"
	local quizfile="$PREFIX/$path.txt"
	set_git "$quizfile"

	tmpdir #Defines $SECURE_TMPDIR
	local tmp_file="$(mktemp -u "$SECURE_TMPDIR/XXXXXX")-${path//\//-}.txt"

	local action="Add"
	if [[ -f $quizfile ]]; then
    cat "$quizfile" > "$tmp_file"
		action="Edit"
	fi
	${EDITOR:-vi} "$tmp_file"
	[[ -f $tmp_file ]] || die "New quiz not saved."
	cat "$quizfile" 2>/dev/null | diff - "$tmp_file" &>/dev/null && die "Quiz unchanged."
  mv "$tmp_file" "$quizfile" || exit 1
	git_add_file "$quizfile" "$action quiz for $path using ${EDITOR:-vi}."
}

cmd_delete() {
	local opts recursive="" force=0
	opts="$($GETOPT -o rf -l recursive,force -n "$PROGRAM" -- "$@")"
	local err=$?
	eval set -- "$opts"
	while true; do case $1 in
		-r|--recursive) recursive="-r"; shift ;;
		-f|--force) force=1; shift ;;
		--) shift; break ;;
	esac done
	[[ $# -ne 1 ]] && die "Usage: $PROGRAM $COMMAND [--recursive,-r] [--force,-f] quiz-name"
	local path="$1"
	check_sneaky_paths "$path"

	local quizdir="$PREFIX/${path%/}"
	local quizfile="$PREFIX/$path.txt"
	[[ -f $quizfile && -d $quizdir && $path == */ || ! -f $quizfile ]] && quizfile="${quizdir%/}/"
	[[ -e $quizfile ]] || die "Error: $path is not in the quiz store."
	set_git "$quizfile"

	[[ $force -eq 1 ]] || yesno "Are you sure you would like to delete $path?"

	rm $recursive -f -v "$quizfile"
	set_git "$quizfile"
	if [[ -n $INNER_GIT_DIR && ! -e $quizfile ]]; then
		git -C "$INNER_GIT_DIR" rm -qr "$quizfile"
		set_git "$quizfile"
		git_commit "Remove $path from store."
	fi
	rmdir -p "${quizfile%/*}" 2>/dev/null
}

cmd_copy_move() {
	local opts move=1 force=0
	[[ $1 == "copy" ]] && move=0
	shift
	opts="$($GETOPT -o f -l force -n "$PROGRAM" -- "$@")"
	local err=$?
	eval set -- "$opts"
	while true; do case $1 in
		-f|--force) force=1; shift ;;
		--) shift; break ;;
	esac done
	[[ $# -ne 2 ]] && die "Usage: $PROGRAM $COMMAND [--force,-f] old-path new-path"
	check_sneaky_paths "$@"
	local old_path="$PREFIX/${1%/}"
	local old_dir="$old_path"
	local new_path="$PREFIX/$2"

	if ! [[ -f $old_path.txt && -d $old_path && $1 == */ || ! -f $old_path.txt ]]; then
		old_dir="${old_path%/*}"
		old_path="${old_path}.txt"
	fi
	echo "$old_path"
	[[ -e $old_path ]] || die "Error: $1 is not in the quiz store."

	mkdir -p -v "${new_path%/*}"
	[[ -d $old_path || -d $new_path || $new_path == */ ]] || new_path="${new_path}.txt"

	local interactive="-i"
	[[ ! -t 0 || $force -eq 1 ]] && interactive="-f"

	set_git "$new_path"
	if [[ $move -eq 1 ]]; then
		mv $interactive -v "$old_path" "$new_path" || exit 1

		set_git "$new_path"
		if [[ -n $INNER_GIT_DIR && ! -e $old_path ]]; then
			git -C "$INNER_GIT_DIR" rm -qr "$old_path" 2>/dev/null
			set_git "$new_path"
			git_add_file "$new_path" "Rename ${1} to ${2}."
		fi
		set_git "$old_path"
		if [[ -n $INNER_GIT_DIR && ! -e $old_path ]]; then
			git -C "$INNER_GIT_DIR" rm -qr "$old_path" 2>/dev/null
			set_git "$old_path"
			[[ -n $(git -C "$INNER_GIT_DIR" status --porcelain "$old_path") ]] && git_commit "Remove ${1}."
		fi
		rmdir -p "$old_dir" 2>/dev/null
	else
		cp $interactive -r -v "$old_path" "$new_path" || exit 1
		git_add_file "$new_path" "Copy ${1} to ${2}."
	fi
}

cmd_git() {
	set_git "$PREFIX/"
	if [[ $1 == "init" ]]; then
		INNER_GIT_DIR="$PREFIX"
		git -C "$INNER_GIT_DIR" "$@" || exit 1
		git_add_file "$PREFIX" "Add current contents of quiz store."
	elif [[ -n $INNER_GIT_DIR ]]; then
		tmpdir nowarn
		export TMPDIR="$SECURE_TMPDIR"
		git -C "$INNER_GIT_DIR" "$@"
	else
		die "Error: the quiz store is not a git repository. Try \"$PROGRAM git init\"."
	fi
}

cmd_extension_or_show() {
	if ! cmd_extension "$@"; then
		COMMAND="show"
		cmd_show "$@"
	fi
}

SYSTEM_EXTENSION_DIR=""
cmd_extension() {
	check_sneaky_paths "$1"
	local user_extension system_extension extension
	[[ -n $SYSTEM_EXTENSION_DIR ]] && system_extension="$SYSTEM_EXTENSION_DIR/$1.bash"
	[[ $QUIZ_STORE_ENABLE_EXTENSIONS == true ]] && user_extension="$EXTENSIONS/$1.bash"
	if [[ -n $user_extension && -f $user_extension && -x $user_extension ]]; then
		extension="$user_extension"
	elif [[ -n $system_extension && -f $system_extension && -x $system_extension ]]; then
		extension="$system_extension"
	else
		return 1
	fi
	shift
	source "$extension" "$@"
	return 0
}

#
# END subcommand functions
#

PROGRAM="${0##*/}"
COMMAND="$1"

case "$1" in
	init) shift;			cmd_init "$@" ;;
	help|--help) shift;		cmd_usage "$@" ;;
	version|--version) shift;	cmd_version "$@" ;;
	show|ls|list) shift;		cmd_show "$@" ;;
	find|search) shift;		cmd_find "$@" ;;
	grep) shift;			cmd_grep "$@" ;;
	insert|add) shift;		cmd_insert "$@" ;;
	edit) shift;			cmd_edit "$@" ;;
	delete|rm|remove) shift;	cmd_delete "$@" ;;
	rename|mv) shift;		cmd_copy_move "move" "$@" ;;
	copy|cp) shift;			cmd_copy_move "copy" "$@" ;;
	git) shift;			cmd_git "$@" ;;
	*)				cmd_extension_or_show "$@" ;;
esac
exit 0
