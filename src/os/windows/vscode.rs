use crate::base::Context;

use super::utils::append_json_into_vs_code;

pub fn run_windows_vscode(context: &mut Context) {
    append_json_into_vs_code(
        context,
        "User\\settings.json",
        r###"
{
    // Disabled for now:
    // "workbench.colorTheme": "Default High Contrast",

    "breadcrumbs.enabled": false,
    "terminal.integrated.defaultProfile.windows": "Git Bash",
    "editor.formatOnSave": true,
    "editor.minimap.enabled": false,
    "editor.renderLineHighlight": "none",
    "editor.scrollbar.horizontal": "hidden",
    "editor.scrollbar.vertical": "hidden",
    "editor.occurrencesHighlight": false,
    "scm.diffDecorations": "overview",
    "window.menuBarVisibility": "toggle",
    "window.zoomLevel": 1,
    "workbench.activityBar.visible": false,
    "editor.cursorBlinking": "solid",
    "workbench.colorCustomizations": {
        "editorCursor.foreground": "#f1345d",
        "editorCursor.background": "#000000",
        "statusBar.background": "#303030",
        "statusBar.noFolderBackground": "#222225",
        "statusBar.debuggingBackground": "#511f1f",
    },
    "workbench.editor.enablePreview": false,
    "workbench.startupEditor": "newUntitledFile",
    "workbench.statusBar.visible": true,
    "dart.closingLabels": false,
    "javascript.validate.enable": false,
    "eslint.validate": [
        "typescript",
        "typescriptreact"
    ],
    "java.configuration.checkProjectSettingsExclusions": false,
    "editor.suggestSelection": "first",
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "editor.guides.indentation": false,
    "telemetry.telemetryLevel": "off",
    "vim.vimrc.enable": true,
    "vim.vimrc.path": "C:\\Users\\Ignacio\\.vimrc",
    "vim.normalModeKeyBindings": [
        {"before": ["<c-e>"],"after": [":","w","<CR>"]},
    ],
    "vim.insertModeKeyBindingsNonRecursive": [
        {"before": ["<c-e>"],"after": ["<ESC>",":","w","<CR>"]},
    ],
    "vim.leader": "<space>"
}
"###,
    );

    append_json_into_vs_code(
        context,
        "User\\keybindings.json",
        r###"
[
    {
        "key": "ctrl+d",
        "command": "workbench.action.closeActiveEditor"
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
    {
        "key": "ctrl+z",
        "command": "workbench.action.terminal.focus"
    },
    {
        "key": "ctrl+s",
        "command": "-workbench.action.files.save"
    },
    {
        "key": "ctrl+e",
        "command": "-workbench.action.quickOpen"
    },
]
"###,
    );
}
