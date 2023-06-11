#!/usr/bin/env bash

set -e

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

cp src/custom_template_unix.rs src/custom.rs

mkdir -p project/.config
