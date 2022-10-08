#!/usr/bin/env bash
# Fake answer
# Generates random strings in given length
#
# Intended use:
#   "$QUIZ" insert cred1 -e <<<"$(fake-answer.sh 43)" &&
#
# Arguments: [length]
# Returns: 0 on success, 1 on error

if [[ $# -gt 1 ]]; then
	echo "Usage: $0 [length]"
	exit 1
fi

GENERATED_LENGTH="${1:-25}"

printf "$(openssl rand $GENERATED_LENGTH | base64 | fold -w $GENERATED_LENGTH | head -n 1)"

exit 0
