use std::path::Path;

use crate::base::{config::Config, system::System, Context};

use super::install_nvim_package;

// ctrl-w,ctrl-p: move to floating window
// - To remove an extension after installed, comment lines and then: :CocUninstall coc-name
// - To open multiple references at once: enter in visual mode inside the quickfix window and select multiple
//   - Press `t` to open each case in new tab, press `enter` to open each file (unless already opened) in new tab

pub fn run_nvim_coc(context: &mut Context) {
    install_nvim_package(context, "neoclide/coc.nvim", None);
    install_nvim_package(context, "josa42/coc-sh", None);
    install_nvim_package(context, "neoclide/coc-snippets", None);
    install_nvim_package(context, "neoclide/coc-git", None);
    install_nvim_package(context, "neoclide/coc-lists", None);
    install_nvim_package(context, "xiyaowong/coc-sumneko-lua", None);

    install_nvim_package(context, "neoclide/coc-json", None);

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
let g:coc_global_extensions = []
nnoremap <silent> K :call CocAction('doHover')<CR>

inoremap <silent><expr> <C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <silent><expr> <C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)

nnoremap <silent> <leader>dd :<C-u>CocList diagnostics<cr>
nnoremap <leader>dc :CocList commands<cr>
nnoremap <leader>de :CocEnable<cr>
nnoremap <leader>dE :CocDisable<cr>
nnoremap <leader>ds :CocCommand<cr>
nnoremap <leader>dl <Plug>(coc-codelens-action)
nnoremap <leader>do <Plug>(coc-codeaction)
nnoremap <leader>dr <Plug>(coc-rename)
command! -nargs=? Fold :call CocAction('fold', <f-args>)

call add(g:coc_global_extensions, 'coc-snippets')
call add(g:coc_global_extensions, 'coc-sh')
call add(g:coc_global_extensions, 'coc-git')
call add(g:coc_global_extensions, 'coc-lists')
call add(g:coc_global_extensions, 'coc-sumneko-lua')

let g:coc_snippet_next = '<c-d>'

nnoremap <nowait><expr> <C-g> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-g> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

call add(g:coc_global_extensions, 'coc-json')
"###,
    );

    if !Path::new(
        &context
            .system
            .get_home_path(".local/share/nvim/lazy/coc.nvim/node_modules"),
    )
    .exists()
    {
        System::run_bash_command("(cd ~/.local/share/nvim/lazy/coc.nvim && yarn)");
    }

    install_nvim_package(context, "neoclide/coc-html", None);
    install_nvim_package(context, "neoclide/coc-css", None);
    install_nvim_package(context, "neoclide/coc-tsserver", None);

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
call add(g:coc_global_extensions, 'coc-html')
call add(g:coc_global_extensions, 'coc-css')

" https://github.com/neoclide/coc-css#install
autocmd FileType scss setl iskeyword+=@-@

call add(g:coc_global_extensions, 'coc-tsserver')

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
"###,
    );

    context.files.append_json(
        &context.system.get_home_path(".vim/coc-settings.json"),
        r###"
{
  "suggest.noselect": true,
  "coc.preferences.jumpCommand": "tab drop",
  "diagnostic.enableHighlightLineNumber": false,
  "diagnostic.errorSign": "E",
  "diagnostic.infoSign": "I",
  "diagnostic.warningSign": "W",
  "git.enableGutters": false,
  "list.normalMappings": {
    "<C-j>": "command:CocNext",
    "<C-k>": "command:CocPrev"
  },
  "snippets.userSnippetsDirectory": "$HOME/.vim-snippets",
  "snippets.ultisnips.pythonPrompt": false
}
"###,
    );

    // coc-eslint can be disabled due performance
    // To remove: `CocUninstall coc-eslint`
    // Confirm with: `CocList`
    if !context.config.without_coc_eslint {
        install_nvim_package(context, "neoclide/coc-eslint", None);

        context.files.appendln(
            &context.system.get_home_path(".vimrc"),
            "call add(g:coc_global_extensions, 'coc-eslint')",
        );
    }

    context.files.append(
        &context.system.get_home_path(".vim/lua/extra_beginning.lua"),
        r###"
vim.api.nvim_set_keymap("i", "<c-l>", "<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])<CR>", {})
vim.api.nvim_set_keymap("s", "<c-l>", "<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])<CR>", {})

vim.api.nvim_set_keymap("n", "<leader>da", "<Plug>(coc-codeaction-cursor)", {silent = true, nowait = true})
vim.api.nvim_set_keymap("v", "<leader>da", "<Plug>(coc-codeaction-selected)", {silent = true, nowait = true})
"###,
    );

    context.files.append(
        &context.system.get_home_path(".vim/colors.vim"),
        r###"
highlight CocErrorFloat ctermfg=black
highlight CocMenuSel ctermbg=white
highlight CocFloating ctermbg=lightcyan
highlight CocInfoFloat ctermfg=black
highlight CocWarningFloat ctermfg=black
highlight CocHighlightRead ctermfg=black ctermbg=none
highlight CocHighlightWrite ctermfg=black ctermbg=none
highlight CocErrorLine ctermfg=black ctermbg=none
highlight CocWarningLine ctermfg=black ctermbg=none
highlight CocInfoLine ctermfg=black ctermbg=none
highlight CocErrorSign ctermfg=white ctermbg=darkred
highlight CocWarningSign ctermfg=white ctermbg=darkred
"###,
    );

    // To try:
    // - https://github.com/tjdevries/coc-zsh
    // - https://github.com/iamcco/coc-diagnostic
    // - https://github.com/neoclide/coc-jest

    if Config::has_config_file(&context.system, ".config/coc-prettier") {
        install_nvim_package(context, "neoclide/coc-prettier", None);
        context.files.appendln(
            &context.system.get_home_path(".vimrc"),
            "call add(g:coc_global_extensions, 'coc-prettier')",
        );

        context.files.append_json(
            &context.system.get_home_path(".vim/coc-settings.json"),
            r###""coc.preferences.formatOnSaveFiletypes": ["typescriptreact", "typescript", "javascript"]"###
        );
    }

    context.files.append_json(
        &context.system.get_home_path(".vim/coc-settings.json"),
        r###"
"eslint.filetypes": ["javascript", "javascriptreact", "typescript", "typescriptreact", "vue"],
"eslint.probe": ["javascript", "javascriptreact", "typescript", "typescriptreact", "vue"],
"javascript.suggestionActions.enabled": false,
"prettier.disableSuccessMessage": true
"###,
    );

    let with_autofix =
        if Config::has_config_file(&context.system, ".config/coc-eslint-no-fix-on-save") {
            "true"
        } else {
            "false"
        };

    context.files.append_json(
        &context.system.get_home_path(".vim/coc-settings.json"),
        &format!(
            r###"
"eslint.autoFixOnSave": {with_autofix}
"###
        ),
    );

    context.files.append_json(
        &context.system.get_home_path(".vim/coc-settings.json"),
        r###"
"typescript.suggestionActions.enabled": false
"###,
    );

    if context.system.get_has_binary("rustc") {
        install_nvim_package(context, "neoclide/coc-rls", None);
        context.files.append(
            &context.system.get_home_path(".vimrc"),
            r###"
" TODO: Fix
" call add(g:coc_global_extensions, 'coc-rls')
"###,
        );

        context.files.append_json(
            &context.system.get_home_path(".vim/coc-settings.json"),
            r###"
"rust.clippy_preference": "on"
"###,
        );
    }

    context.files.append_json(
        &context.system.get_home_path(".vim/coc-settings.json"),
        r###"
"sumneko-lua.enableNvimLuaDev": true,
"Lua.telemetry.enable": false
"###,
    );
}
