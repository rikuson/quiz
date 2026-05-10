#!/usr/bin/env bash
# Fake editor program for testing 'quiz add -m'.
# Writes content to the given file based on the filename suffix:
#   *.question.txt → $FAKE_EDITOR_Q (or $FAKE_EDITOR_CONTENT)
#   *.answer.txt   → $FAKE_EDITOR_A (or $FAKE_EDITOR_CONTENT)
#   anything else  → $FAKE_EDITOR_CONTENT
#
# Arguments: <filename>
# Returns: 0 on success, 1 on error

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <filename>"
	exit 1
fi

filename=$1
case "$filename" in
	*.question.txt) content="${FAKE_EDITOR_Q-$FAKE_EDITOR_CONTENT}" ;;
	*.answer.txt)   content="${FAKE_EDITOR_A-$FAKE_EDITOR_CONTENT}" ;;
	*)              content="$FAKE_EDITOR_CONTENT" ;;
esac

printf '%s\n' "$content" > "$filename"
exit 0
