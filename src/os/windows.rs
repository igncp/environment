use std::path::Path;

use crate::base::Context;

fn install_windows_package(context: &mut Context, package: &str, name: &str) {
    if !Path::new(&context.system.get_home_path(&format!(
        "AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\{}",
        name
    )))
    .exists()
        && !Path::new(&format!(
            "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\{}",
            name
        ))
        .exists()
    {
        context.system.install_system_package(package, None);
    }
}

pub fn run_windows(context: &mut Context) {
    let current_shell = std::env::var_os("SHELL");
    if current_shell.is_none() {
        println!("Windows provision is only supported in Git Bash");
        std::process::exit(1);
    }

    let current_shell = current_shell.unwrap().to_str().unwrap_or("_").to_string();
    if !current_shell.contains("bash") {
        println!("Windows provision is only supported in Git Bash");
        std::process::exit(1);
    }

    context.files.append_json(
        &context
            .system
            .get_home_path("AppData\\Roaming\\Code\\User\\settings.json"),
        r###"
{
    // Disabled for now:
    // "workbench.colorTheme": "Default High Contrast",

    "breadcrumbs.enabled": false,
    "workbench.startupEditor": "none",
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
    "[kotlin]": {
        "editor.defaultFormatter": "fwcd.kotlin"
    },
    "java.configuration.checkProjectSettingsExclusions": false,
    "editor.suggestSelection": "first",
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "telemetry.enableTelemetry": false,
    "editor.guides.indentation": false,
    "telemetry.telemetryLevel": "off"
}
"###,
    );

    context.files.append_json(
        &context
            .system
            .get_home_path("AppData\\Roaming\\Code\\User\\keybindings.json"),
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
]
"###,
    );

    context
        .system
        .install_system_package("Neovim.Neovim", Some("nvim.exe"));

    install_windows_package(context, "RARLab.WinRAR", "WinRAR");
    install_windows_package(context, "AutoHotkey.AutoHotkey", "AutoHotkey.lnk");
    install_windows_package(context, "tailscale.tailscale", "Tailscale.lnk");
    install_windows_package(context, "AgileBits.1Password", "1Password.lnk");

    context.files.append(
        &context.system.get_home_path(".bash_profile"),
        r###"
alias n='nvim'
GitAdd() { git add -A $@; git status -u; }
GitCommit() { eval "git commit -m '$@'"; }
"###,
    );

    std::fs::create_dir_all(context.system.get_home_path("AppData\\Local\\nvim")).unwrap();

    context.files.append(
        &context
            .system
            .get_home_path("AppData\\Local\\nvim\\init.vim"),
        r###"
syntax off

" tabs
nnoremap r gt
nnoremap R gT
nnoremap <c-t> :tabnew<cr>:e <left><right>
"###,
    );
}
