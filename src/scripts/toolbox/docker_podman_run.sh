#!/usr/bin/env bash

COMMAND="$(cat ~/development/environment/src/containers_commands.txt | fzf | sed 's|^[^:]*: ||')"

if type podman >/dev/null 2>&1; then
  COMMAND="$(echo "$COMMAND" | sed 's|^docker |podman |')"
fi

echo "# $COMMAND"
