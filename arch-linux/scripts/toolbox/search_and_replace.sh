#!/usr/bin/env bash

# depends on highlighter in: ~/hhighlighter/h.sh

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

if [ $# -eq 0 ]; then
  DIR=$(find . -type d ! -path "*.git*" ! -path "*node_modules*" |
    fzf --height 100% --border -m  --ansi)

  [[ -z "$DIR" ]] && exit 0

  echo "$ABSOLUTE_PATH $DIR"
  exit 0
fi

source ~/hhighlighter/h.sh

ask_with_default() {
  NAME="$1"; DEFAULT="$2"
  printf "$NAME [$DEFAULT]: " > /dev/stderr
  read -r VAR
  if [[ -z $VAR ]]; then VAR=$DEFAULT; fi
  echo "$VAR"
}

DIR_TO_FIND=${1:-.}
echo "src: $DIR_TO_FIND"

if [ -z "$2" ]; then
  SEARCH_REGEX="$(ask_with_default "search regexp" "foo")"
else
  SEARCH_REGEX="$2"
  echo "search regexp: '$SEARCH_REGEX'"
fi

if [ -z "$3" ]; then
  REPLACEMENT_STR=$(ask_with_default "replacement str" "")
else
  REPLACEMENT_STR="$3"
  echo "replacement str: '$REPLACEMENT_STR'"
fi

EXTRA_FIND_ARGS=$(ask_with_default "extra find arguments" "-name '*'")
CASE_SENSITIVE=$(ask_with_default "case sensitive" "yes")

GREP_OPTS=""; SED_OPTS="g"
if [ "$CASE_SENSITIVE" != "yes" ]; then
  GREP_OPTS=" -i "; SED_OPTS="I"
fi

CMD_SEARCH="find $DIR_TO_FIND -type f $EXTRA_FIND_ARGS | xargs grep --color=always $GREP_OPTS -E "'"'"$SEARCH_REGEX"'"'" | less -R"

CMD_REPLACE="find $DIR_TO_FIND -type f $EXTRA_FIND_ARGS | xargs grep $GREP_OPTS -El "'"'"$SEARCH_REGEX"'"'
CMD_REPLACE="$CMD_REPLACE | xargs -I {} sed -i 's|$SEARCH_REGEX|$REPLACEMENT_STR|$SED_OPTS' {}"

eval "$CMD_SEARCH"

echo ""
echo "$ABSOLUTE_PATH $DIR_TO_FIND '$SEARCH_REGEX' '$REPLACEMENT_STR'"
echo ""
echo "$CMD_SEARCH"
echo ""
echo "$CMD_REPLACE"

printf "\nIf you want to replace with the previous command, type: yes\n" | h yes

read -r RESPONSE

if ! echo $RESPONSE | grep -q "^yes$"; then
  exit 0
fi

eval "$CMD_REPLACE"

echo "Done."
