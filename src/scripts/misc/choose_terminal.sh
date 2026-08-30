if [ -f "$HOME"/development/environment/project/.config/force-nixgl ]; then
  logger -t "choose_terminal" "選擇 nixGL"
  /run/current-system/sw/bin/nixGL /run/current-system/sw/bin/ghostty
elif [ -f ~/.local/bin/ghostty ]; then
  ~/.local/bin/ghostty
elif [ -s /run/current-system/sw/bin/ghostty ]; then
  logger -t "choose_terminal" "選擇 root ghostty"
  /run/current-system/sw/bin/ghostty
elif [ -f "$HOME"/.nix-profile/bin/ghostty ] && [ -f "$HOME"/.nix-profile/bin/nixGL ]; then
  "$HOME"/.nix-profile/bin/nixGL "$HOME"/.nix-profile/bin/ghostty
else
  /run/current-system/sw/bin/terminator
fi
