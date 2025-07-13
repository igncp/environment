#!/usr/bin/env bash

set -euo pipefail

# If the path is absolute, return it. Otherwise, try to find the path relative
# to the current working directory. If the path is not found, try to find it
# relative to the parent directory. Repeat this process until the path is found
# or the parent directory is the root directory.

find_correct_path() {
  local CHECKED_PATH="$1"
  local IS_ABSOLUTE=false
  if [ "${CHECKED_PATH:0:1}" == "/" ]; then
    IS_ABSOLUTE=true
  fi
  local LEVELS_UP=0

  while true; do
    local PREFIX=""
    local i=0

    for ((i = 0; i < LEVELS_UP; i++)); do
      PREFIX="../$PREFIX"
    done

    local FULL_PATH="$PREFIX$CHECKED_PATH"
    if [ -e "$FULL_PATH" ]; then
      echo "$FULL_PATH"
      return
    fi

    if [ "$IS_ABSOLUTE" == true ] || [ "$LEVELS_UP" -gt 100 ]; then
      return
    else
      LEVELS_UP=$((LEVELS_UP + 1))
    fi
  done
}

main() {
  local FIRST_ARG="$1"
  local RESOLVED_PATH="${FIRST_ARG:-.}"

  if [ "${RESOLVED_PATH:0:2}" == "a/" ] || [ "${RESOLVED_PATH:0:2}" == "b/" ]; then
    echo "Path starts with a/ or b/, removing prefix, asumming it is from a diff"
    RESOLVED_PATH="${RESOLVED_PATH:2}"
  fi

  local CORRECT_PATH="$(find_correct_path "$RESOLVED_PATH")"
  local FULL_PATH="$CORRECT_PATH"
  if [ -z "$FULL_PATH" ]; then
    FULL_PATH="$RESOLVED_PATH"
  fi

  local CMD_ARGS=("-s" "-c" "tab drop $FULL_PATH")

  nvr "${CMD_ARGS[@]}" "${@:2}"
}

main "$@"
