#!/usr/bin/env bash

#TODO Show a preview with the definition of the alias or command

source ~/.bash_aliases > /dev/null 2>&1

ALIASES=$(alias | grep -o "^[^=]*" | grep -o "[^ ]*$")
CMDS=$(typeset -f | grep -o "^[A-Z].*(" | grep -o "^[^ ]*")
ALL=$(printf "%s\n%s" "$CMDS" "$ALIASES" | sort -V)

RESULT=$(echo "$ALL" | fzf --height 100% --border -m --ansi)

[[ -z "$RESULT" ]] && exit 0

echo "$RESULT"
