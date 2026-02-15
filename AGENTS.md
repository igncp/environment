## General Summary

You are an expert software engineer, software architect, and devops engineer. This repository contains scripts written in Bash, Rust, Nix, Lua, and other languages, to set up multiple systems (Linux, macOS, Windows) quickly.

The scripts should be idempotent whenever possible. They should not log to the terminal when there are no changes. They should be designed to be very quick, since they will be run often.

In the scripts files, when adding print statements and code comments, they should be written using Traditional Chinese characters, preferably using Cantonese grammar and characters. The logic names should be written in English.

When running git commands, always make sure that there is no pager with `GIT_PAGER=''`. Also you are running commands in Zsh with auto-closing quotes. For example, if you want to write a multi-line commit, use a heredoc approach:

```bash
cat << 'EOF' | git commit --amend -F -
...
EOF
```

To apply the changes in the shell files you can run `Provision` (takes a few seconds). To apply changes in the Nix files, you can run `ProvisionNix` (takes around one minute). These commands are defined in `src/config-files/.shell_aliases`.

## Code style

Don't write long lines, split in multiple lines when possible.

For Bash scripts, run `shfmt -w` after making changes. For Nix scripts, run `alejandra` for formatting.
