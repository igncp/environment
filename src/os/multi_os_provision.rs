pub fn get_vim_multi_os_provision() -> String {
    String::from(
        r###"
" Don't copy when using del
vnoremap <Del> "_d
nnoremap <Del> "_d

nnoremap r gt
nnoremap R gT
nnoremap <c-t> :tabnew<cr>:e <left><right>

nnoremap Q @q

" Replace with selection. To replace by current register, use <c-r>0 to paste it
vmap <leader>g "ay:%s/\C\<<c-r>a\>//g<left><left>
vmap <leader>G "ay:%s/\C<c-r>a//g<left><left>

" Fill the search bar with current text and allow to edit it
vnoremap <leader>/ y/<c-r>"
nnoremap <leader>/ viwy/<c-r>"

" Folding
set foldlevelstart=20
set foldmethod=indent
set fml=0
nnoremap <leader>fr :set foldmethod=manual<cr>
nnoremap <leader>fR :set foldmethod=indent<cr>
vnoremap <leader>ft <c-c>:set foldmethod=manual<cr>mlmk`<kmk`>jmlggvG$zd<c-c>'kVggzf'lVGzfgg<down>
nnoremap <leader>; za
onoremap <leader>; <C-C>za
vnoremap <leader>; zf

" Quickly move to lines
nnoremap <Enter> G
nnoremap <BS> gg

nnoremap <leader>a ggVG$
cnoremap <c-A> <Home>
cnoremap <c-E> <End>
"###,
    )
}

pub fn get_vscode_settings_multi_os() -> String {
    String::from(
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
    )
}

pub fn get_vscode_keybindings_multi_os() -> String {
    String::from(
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
    )
}
