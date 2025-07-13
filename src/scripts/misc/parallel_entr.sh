#!/usr/bin/env bash

set -euo pipefail

COLOR_GREEN="\e[32m"
COLOR_BLUE="\e[34m"
COLOR_RESET="\e[0m"

run_entr_task() {
  while true; do
    eval "find $1" | \
      entr -r sh -c \
      "$2"
    # when creating a new file, entr will exit
    sleep 1
  done
}

prefix_with_text_and_color() {
  TEXT="$1"; COLOR="$2"

  sed -E "s|^(.*)$|$(printf $COLOR)$TEXT$(printf $COLOR_RESET)\1|"
}

run_entr_task \
  '~/FOO -type f' \
  'date; echo foo' | \
    prefix_with_text_and_color "foo prefix: " "$COLOR_GREEN" \
    &

run_entr_task \
  '~/BAR -type f' \
  '(sleep 1 && rsync -rhv --delete BAZ/ BAM/)' | \
    prefix_with_text_and_color "cat: " "$COLOR_BLUE" \
    &

run_entr_task \
  '~/BAX -type f' \
  'echo baz' \
  &

# This will not end the script till all the rest have ended. If the script is
# stopped, the rest of the parallel scripts will be stopped. More on `man bash`
wait
