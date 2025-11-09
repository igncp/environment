if [ -f ~/.local/bin/ghostty ]; then
  ~/.local/bin/ghostty
elif [ -s /run/current-system/sw/bin/ghostty ]; then
  /run/current-system/sw/bin/ghostty
elif [ -f "$HOME"/.nix-profile/bin/ghostty ] && [ -f "$HOME"/.nix-profile/bin/nixGL ]; then
  "$HOME"/.nix-profile/bin/nixGL "$HOME"/.nix-profile/bin/ghostty
else
  /run/current-system/sw/bin/terminator
fi
