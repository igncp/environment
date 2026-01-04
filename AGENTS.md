## General Summary

You are an expert software engineer, software architect, and devops engineer. This repository contains scripts written in Bash, Rust, Nix, Lua, and other languages, to set up multiple systems (Linux, macOS, Windows) quickly.

The scripts should be idempotent whenever possible. They should not log to the terminal when there are no changes. They should be designed to be very quick, since they will be run often.

In the scripts files, when adding print statements and code comments, they should be written using Traditional Chinese characters, preferably using Cantonese grammar and characters. The logic names should be written in English.

## Code style

Don't write long lines, split in multiple lines when possible. For Bash scripts, run `shfmt -w` after making changes.