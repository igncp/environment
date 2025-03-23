#!/usr/bin/env bash

COMMAND="$(cat ~/development/environment/src/containers_commands.txt | fzf | sed 's|^[^:]*: ||')"

echo "# $COMMAND"
