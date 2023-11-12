#!/usr/bin/env bash

ROOT_UNITS=$(systemctl list-units | awk '{ print $1 }' | grep -E '\.(service|socket)' | sed 's|$| [root]|')
USER_UNITS=$(systemctl --user list-units | awk '{ print $1 }' | grep -E '\.(service|socket)' | sed 's|$| [user]|')

UNIT_ITEM=$(echo -e "$ROOT_UNITS\n$USER_UNITS" | sort -V | fzf)

if [ -z "$UNIT_ITEM" ]; then
  exit 0
fi

ACTION=$(echo -e "journal\nstatus\nstart\nstop\nrestart\nreload\nenable\ndisable" | fzf)

if [ -z "$ACTION" ]; then
  exit 0
fi

UNIT=$(echo "$UNIT_ITEM" | awk '{ print $1 }')
TYPE=$(echo "$UNIT_ITEM" | awk '{ print $2 }')

if [ "$ACTION" = "journal" ]; then
  if [ "$TYPE" = "[user]" ]; then
    CMD="journalctl --user-unit"
  else
    CMD="sudo journalctl --unit"
  fi
else
  if [ "$TYPE" = "[user]" ]; then
    CMD="systemctl --user $ACTION"
  else
    CMD="sudo systemctl $ACTION"
  fi

  if [ "$ACTION" = "enable" ]; then
    CMD="$CMD --now"
  fi
fi

echo "$CMD $UNIT"
