#!/usr/bin/env bash

CURRENT_BRANCH_CMD='printf $(git rev-parse --abbrev-ref HEAD) | '

echo "$CURRENT_BRANCH_CMD ~/.local/bin/clipboard_ssh send"
