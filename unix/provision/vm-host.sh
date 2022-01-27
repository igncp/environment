# vm-host START

# this script is intended watch a file, so when sending text from a guest to it,
# the clipboard would be updated. The file is hardcoded to reuse in the vm-guest
echo 'ClipboardWatch() { ls "$1/clipboard.txt" | entr sh /tmp/clipboard-cmd.sh /_; }' >> ~/.shell_aliases
cat > /tmp/clipboard-cmd.sh <<"EOF"
#!/usr/bin/env bash
echo "[$(date)] $1 updated"
cat "$1" | xclip -sel clip
EOF

# vm-host END
