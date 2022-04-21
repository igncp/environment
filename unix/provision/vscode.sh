# vscode START

if ! type code > /dev/null 2>&1 ; then
  if [ "$PROVISION_OS" == 'MAC' ]; then
    echo 'Install vscode for Mac manually'
  elif [ -f "$HOME"/Downloads/vscode.tar.gz ]; then
    (cd "$HOME"/Downloads \
      && sudo rm -rf /usr/bin/code /opt/visual-studio-code "$HOME"/Downloads/VSCode-* \
      && tar xf vscode.tar.gz \
      && sudo mv VSCode-* /opt/visual-studio-code \
      && sudo ln -s /opt/visual-studio-code/bin/code /usr/bin/code \
      && rm -rf vscode.tar.gz)
  else
    echo "Not installing VS Code because the file '~/Downloads/vscode.tar.gz' is missing."
    echo "  https://code.visualstudio.com/#alt-downloads"
  fi
fi

cat > /tmp/vscode-settings.json <<"EOF"
{
    "breadcrumbs.enabled": false,
    "editor.cursorBlinking": "solid",
    "editor.cursorStyle": "line",
    "editor.fontSize": 18,
    "editor.formatOnSave": false,
    "editor.lightbulb.enabled": false,
    "editor.minimap.enabled": false,
    "editor.renderIndentGuides": false,
    "editor.renderLineHighlight": "none",
    "editor.scrollbar.horizontal": "hidden",
    "editor.scrollbar.vertical": "hidden",
    "editor.occurrencesHighlight": false,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    },
    "scm.diffDecorations": "overview",
    "window.menuBarVisibility": "toggle",
    "window.zoomLevel": 1,
    "workbench.activityBar.visible": false,
    "workbench.colorCustomizations": {
        "editorCursor.foreground": "#f1345d",
        "editorCursor.background": "#000000",
        "statusBar.background": "#303030",
        "statusBar.noFolderBackground": "#222225",
        "statusBar.debuggingBackground": "#511f1f",
    },
    "workbench.colorTheme": "Default High Contrast",
    "workbench.editor.enablePreview": false,
    "workbench.startupEditor": "newUntitledFile",
    "workbench.statusBar.visible": true,
    "dart.closingLabels": false,
    "javascript.validate.enable": false,
    "eslint.validate": [
        "typescript",
        "typescriptreact"
    ],
    "[kotlin]": {
        "editor.defaultFormatter": "fwcd.kotlin"
    },
    "java.configuration.checkProjectSettingsExclusions": false,
    "editor.suggestSelection": "first",
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "telemetry.enableTelemetry": false
}
EOF
# Remove the last line-break
sed -i '$ d' /tmp/vscode-settings.json
printf '}' >> /tmp/vscode-settings.json

cat > /tmp/vscode-shortcuts.json <<"EOF"
[
    {
        "key": "ctrl+d",
        "command": "workbench.action.closeActiveEditor"
    },
    {
        "key": "ctrl+`",
        "command": "workbench.action.closePanel",
        "when": "terminalFocus"
    },
    {
        "key": "ctrl+shift+y",
        "command": "workbench.action.terminal.toggleTerminal",
        "when": "!terminalFocus"
    },
    {
        "key": "ctrl+1",
        "command": "workbench.action.openEditorAtIndex1"
    },
    {
        "key": "ctrl+2",
        "command": "workbench.action.openEditorAtIndex2"
    },
    {
        "key": "ctrl+3",
        "command": "workbench.action.openEditorAtIndex3"
    },
    {
        "key": "ctrl+4",
        "command": "workbench.action.openEditorAtIndex4"
    },
    {
        "key": "ctrl+5",
        "command": "workbench.action.openEditorAtIndex5"
    },
    {
        "key": "ctrl+6",
        "command": "workbench.action.openEditorAtIndex6"
    },
]
EOF
# Remove the last line-break
sed -i '$ d' /tmp/vscode-shortcuts.json
printf ']' >> /tmp/vscode-shortcuts.json

if [ -f ~/.config/Code/User/settings.json ]; then
  SETTINGS_DIFF="$(diff -u ~/.config/Code/User/settings.json /tmp/vscode-settings.json || true)"
  if [ -n "$SETTINGS_DIFF" ]; then
    echo "Mismatch in vscode configuration"
    echo "$SETTINGS_DIFF"
  fi
else
  cp /tmp/vscode-settings.json ~/.config/Code/User/settings.json
fi

if [ -f ~/.config/Code/User/keybindings.json ]; then
  SHORTCUTS_DIFF="$(diff ~/.config/Code/User/keybindings.json /tmp/vscode-shortcuts.json || true)"
  if [ -n "$SHORTCUTS_DIFF" ]; then
    echo "+++ Mismatch in vscode shortcuts"
    echo "$SHORTCUTS_DIFF"
  fi
else
  cp /tmp/vscode-shortcuts.json ~/.config/Code/User/keybindings.json
fi

cat >> /tmp/expected-vscode-extensions <<"EOF"
waderyan.gitblame
ms-vscode-remote.remote-ssh
ms-vscode-remote.remote-ssh-edit
GitHub.copilot
EOF

cat >> ~/.shell_aliases <<"EOF"
alias VSCodeCopySettings="cp /tmp/vscode-settings.json ~/.config/Code/User/settings.json"
alias VSCodeCopyShortcuts="cp /tmp/vscode-shortcuts.json ~/.config/Code/User/keybindings.json"
V() {
  code $(find $1 -type f | fzf) && exit
}
VSCodeCompareExtensions() {
  code --list-extensions | sort > /tmp/vscode-extensions
  sort /tmp/expected-vscode-extensions > /tmp/_tmp-sort
  mv /tmp/_tmp-sort /tmp/expected-vscode-extensions
  diff -u /tmp/expected-vscode-extensions /tmp/vscode-extensions --color=always
}
VSCodeInstallExpectedExtensions() {
  code --list-extensions | sort > /tmp/vscode-extensions
  sort /tmp/expected-vscode-extensions > /tmp/_tmp-sort
  mv /tmp/_tmp-sort /tmp/expected-vscode-extensions
  diff /tmp/expected-vscode-extensions /tmp/vscode-extensions --color=never | ag '<' \
    | sed 's|< ||' | xargs -I {} code --install-extension {}
}
EOF

[[ $(type -t add_desktop_common) == function ]] && add_desktop_common \
  '/usr/bin/code' \
  'open_vscode' \
  'Visual Studio VSCode'

# vscode END
