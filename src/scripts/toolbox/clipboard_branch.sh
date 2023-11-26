#!/usr/bin/env bash

CURRENT_BRANCH_CMD='printf $(git rev-parse --abbrev-ref HEAD) | '

echo "$CURRENT_BRANCH_CMD ~/.scripts/cargo_target/release/clipboard_ssh send"
