use std::path::Path;

use crate::base::{
    config::{Config, Theme},
    system::System,
    Context,
};

use super::{add_special_vim_map, install_vim_package};

pub fn run_nvim_base(context: &mut Context) {
    std::fs::create_dir_all(context.system.get_home_path(".vim/autoload")).unwrap();
    std::fs::create_dir_all(context.system.get_home_path(".vim/bundle")).unwrap();

    if !Path::new(&context.system.get_home_path(".vim/autoload/pathogen.vim")).exists() {
        System::run_bash_command(
"curl https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim > ~/.vim/autoload/pathogen.vim"
        );
    }

    context
        .system
        .install_system_package("neovim", Some("nvim"));

    if !Path::new(&context.system.get_home_path(".check-files/neovim")).exists() {
        System::run_bash_command(
            r###"
pip3 install neovim
mkdir -p ~/.config
rm -rf ~/.config/nvim
rm -rf ~/.vim/init.vim
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim
touch ~/.check-files/neovim
"###,
        );
    }

    // Faster than sed
    System::run_bash_command("git config --global core.editor nvim");

    install_vim_package(context, "airblade/vim-gitgutter", None); // https://github.com/airblade/vim-gitgutter
    install_vim_package(context, "andrewRadev/splitjoin.vim", None); // gS, gJ
    install_vim_package(context, "bogado/file-line", None); // https://github.com/bogado/file-line
    install_vim_package(context, "ctrlpvim/ctrlp.vim", None); // https://github.com/ctrlpvim/ctrlp.vim
    install_vim_package(context, "elzr/vim-json", None); // https://github.com/elzr/vim-json
    install_vim_package(context, "google/vim-searchindex", None); // https://github.com/google/vim-searchindex
    install_vim_package(context, "haya14busa/incsearch.vim", None); // https://github.com/haya14busa/incsearch.vim
    install_vim_package(context, "honza/vim-snippets", None); // ind ~/.vim/bundle/vim-snippets/snippets/ -type f | xargs sed -i 's|:\${VISUAL}||'"
    install_vim_package(context, "jiangmiao/auto-pairs", None); // https://github.com/jiangmiao/auto-pairs
    install_vim_package(context, "junegunn/limelight.vim", None); // https://github.com/junegunn/limelight.vim
    install_vim_package(context, "junegunn/vim-peekaboo", None); // https://github.com/junegunn/vim-peekaboo
    install_vim_package(context, "liuchengxu/vista.vim", None); // https://github.com/liuchengxu/vista.vim
    install_vim_package(context, "mbbill/undotree", None); // https://github.com/mbbill/undotree
    install_vim_package(context, "ntpeters/vim-better-whitespace", None); // https://github.com/ntpeters/vim-better-whitespace
    install_vim_package(context, "plasticboy/vim-markdown", None); // https://github.com/plasticboy/vim-markdown
    install_vim_package(context, "rhysd/clever-f.vim", None); // https://github.com/rhysd/clever-f.vim
    install_vim_package(context, "ryanoasis/vim-devicons", None); // if not supported, add in custom: rm -rf ~/.vim/bundle/vim-devicons/*
    install_vim_package(context, "scrooloose/nerdcommenter", None); // https://github.com/scrooloose/nerdcommenter
    install_vim_package(context, "terryma/vim-expand-region", None); // https://github.com/terryma/vim-expand-region
    install_vim_package(context, "tommcdo/vim-exchange", None); // https://github.com/tommcdo/vim-exchange
    install_vim_package(context, "tpope/vim-eunuch", None); // https://github.com/tpope/vim-eunuch
    install_vim_package(context, "tpope/vim-fugitive", None); // https://github.com/tpope/vim-fugitive
    install_vim_package(context, "tpope/vim-repeat", None); // https://github.com/tpope/vim-repeat
    install_vim_package(context, "tpope/vim-surround", None); // https://github.com/tpope/vim-surround
    install_vim_package(context, "vim-scripts/AnsiEsc.vim", None); // https://github.com/vim-scripts/AnsiEsc.vim

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
execute pathogen#infect()
lua require("extra_beginning")

" ctrlp
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_show_hidden = 1
  nnoremap <leader>p :CtrlP %:p:h<cr> " CtrlP in file's dir
  nnoremap <leader>P :CtrlPMRUFiles<cr>
  nnoremap <leader>kpk :CtrlPClearAllCaches<cr>
  let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
  let g:ctrlp_user_command = 'ag %s -l --hidden --ignore "\.git/*" --nocolor -g ""'
  nnoremap <leader>O :let g:CustomZPDir='<c-r>=expand(getcwd())<cr>'
  nnoremap <leader>o :CtrlP <c-r>=expand(g:CustomZPDir)<cr><cr>
  if exists("g:CustomZPDir") == 0
    let g:CustomZPDir=getcwd()
  endif

" lines in files
  nnoremap <leader>kr :-tabnew\|te ( F(){ find $1 -type f \| xargs wc -l \| sort -rn \|
  \ sed "s\|$1\|\|" \| sed "1i _" \| sed "1i $1" \| sed "1i _" \| sed '4d' \| less; }
  \ && F <c-R>=expand("%:p:h")<cr>/ )<left><left>

" don't have to press the extra key when exiting the terminal (nvim)
  augroup terminal
    autocmd!
    autocmd TermClose * close
  augroup end
  autocmd TermOpen * startinsert

" from fzf.vim
function! s:key_sink(line)
  let key = matchstr(a:line, '^\S*')
  redraw
  call feedkeys(substitute(key, '<[^ >]\+>', '\=eval("\"\\".submatch(0)."\"")', 'g'))
endfunction
function! SpecialMaps()
  let file_content = system('cat ~/.special-vim-maps-from-provision.txt')
  let source_list = split(file_content, '\n')
  let options_dict = {
    \ 'options': ' --prompt "Maps (n)> " --ansi --no-hscroll --query "<Space>zm" --nth 1,..',
    \ 'source': source_list,
    \ 'sink': function('s:key_sink'),
    \ 'name': 'maps'}

  call fzf#run(options_dict)
endfunction

nnoremap <c-f> :call SpecialMaps()<cr>
inoremap <c-f> <c-c>:call SpecialMaps()<cr>

function XDisplayColor(color)
  let displaycommand = "display -size 300x300 xc:'" . a:color . "'"
  execute "!" . displaycommand . " 2>&1 >/dev/null &"
  :redraw!
endfunction

function ShowHexColorUnderCursor()
  let wordundercursor = expand("<cword>")
  let parsed_word = substitute(wordundercursor, "#", "", "")
  :call XDisplayColor('\#'.parsed_word)
endfunction

map <leader>cf :call ShowHexColorUnderCursor()<CR>
"###,
    );

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export EDITOR=nvim
export TERM=xterm-256color
source "$HOME"/.shell_aliases # some aliases depend on $EDITOR
"###,
    );

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias nn='nvim -n -u NONE -i NONE -N' # nvim without vimrc, plugins, syntax, etc
alias nb='nvim -n -u ~/.base-vimrc -i NONE -N' # nvim with base vimrc
alias XargsNvim='xargs nvim -p'
alias CheckVimSnippets='nvim ~/.vim/bundle/vim-snippets/snippets'
# https://vi.stackexchange.com/a/277
NProfile() {
  nvim --startuptime /tmp/nvim-profile-log.txt "$@"
  cat /tmp/nvim-profile-log.txt  | grep '^[0-9]' | sort -r -k 2 | less
}
"###,
    );

    add_special_vim_map(
        context,
        [
            "renameexisting",
            r#":Rename <c-r>=expand("%:t")<cr>"#,
            "rename existing file",
        ],
    );
    add_special_vim_map(
        context,
        [
            "showabsolutepath",
            r#":echo expand("%:p")<cr>"#,
            "show absolute path of file",
        ],
    );
    add_special_vim_map(
        context,
        [
            "showrelativepath",
            r#":echo @%<cr>"#,
            "show relative path of file",
        ],
    );

    std::fs::create_dir_all(context.system.get_home_path(".vim/lua")).unwrap();

    context.files.append(
        &context.system.get_home_path(".vim/lua/extra_beginning.lua"),
        r###"
vim.api.nvim_set_keymap("i", "<C-_>", "<Plug>(copilot-next)", {silent = true, nowait = true})
vim.api.nvim_set_keymap("i", "<C-\\>", "<Plug>(copilot-previous)", {silent = true, nowait = true})

-- Undo tree
vim.api.nvim_set_keymap("n", "<leader>mm", ":UndotreeShow<cr><c-w><left>", { noremap = true })

-- vim-expand-region
vim.api.nvim_set_keymap("v", "v", "<Plug>(expand_region_expand)", {})
vim.api.nvim_set_keymap("v", "<c-v>", "<Plug>(expand_region_shrink)", {})

-- fzf maps
vim.api.nvim_set_keymap("n", "<leader>ja", ":Ag!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jb", ":Buffers!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jc", ":Commands!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jg", ":GFiles!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jh", ":History!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jj", ":BLines!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jl", ":Lines!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jm", ":Marks!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jM", ":Maps!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jt", ":Tags!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jw", ":Windows!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jf", ":Filetypes!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>je", ":AnsiEsc!<cr>", { noremap = true })

-- Vista
vim.g.vista_default_executive = 'coc'
vim.g.vista_sidebar_width = 100

-- limelight
vim.g.limelight_conceal_ctermfg = 'LightGray'
vim.g.limelight_bop = '^'
vim.g.limelight_eop = '$'
vim.api.nvim_set_keymap("n", "<leader>zl", ":Limelight!!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>zL", ":let g:limelight_paragraph_span = <left><right>", { noremap = true })

-- auto-pairs
vim.g.AutoPairsMultilineClose = 0

-- incsearch.vim
vim.api.nvim_set_keymap("n", "/", "<Plug>(incsearch-forward)", {})
vim.api.nvim_set_keymap("n", "?", "<Plug>(incsearch-backward)", {})
vim.api.nvim_set_keymap("n", "g/", "<Plug>(incsearch-stay)", {})

-- nerdcommenter
vim.g.NERDSpaceDelims = 1

-- vim fugitive
vim.cmd('set diffopt+=vertical')
vim.cmd('command Gb Git blame')

-- vim-json
vim.g.vim_json_syntax_conceal = 0

-- save file shortcuts
vim.api.nvim_set_keymap("n", "<leader>ks", ':silent exec "!mkdir -p <c-R>=expand("%:p:h")<cr>"<cr>:w<cr>:silent exec ":CtrlPClearAllCaches"<cr>', { noremap = true })

-- markdown
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0
vim.g.vim_markdown_conceal = 0
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_folding_disabled = 1
vim.cmd 'autocmd Filetype markdown set conceallevel=0'

-- format json
vim.cmd 'command! -range -nargs=0 -bar JsonTool <line1>,<line2>!python -m json.tool'
vim.api.nvim_set_keymap("n", "<leader>kz", ':JsonTool<cr>', { noremap = true })
vim.api.nvim_set_keymap("v", "<leader>kz", ":'<,'>JsonTool<cr>", { noremap = true })

vim.g.peekaboo_window='vert bo new'
"###,
    );

    std::fs::create_dir_all(context.system.get_home_path(".vim")).unwrap();

    context.files.append(
        &context.system.get_home_path(".vim/colors.vim"),
        r###"
" http://vim.wikia.com/wiki/File:Xterm-color-table.png
  hi DiffAdd     ctermbg=22
  hi DiffChange  ctermbg=52
  hi DiffText    ctermbg=red
  hi NonText     ctermfg=white
  hi Error       ctermbg=white      ctermfg=red
  hi ErrorMsg    ctermbg=white      ctermfg=darkred
  hi Folded      ctermfg=darkgrey   ctermbg=NONE
  hi IncSearch   cterm=NONE         ctermbg=lightcyan   ctermfg=black
  hi MatchParen  ctermfg=red        ctermbg=lightgrey
  hi Search      cterm=NONE         ctermfg=white       ctermbg=black
  hi SpellBad    ctermbg=lightred   ctermfg=white
  hi TabLine     ctermfg=gray       ctermbg=white
  hi TabLineFill ctermfg=white      ctermbg=white
  " better completion menu colors
    hi Pmenu ctermfg=black ctermbg=lightgrey
    hi PmenuSel ctermfg=black ctermbg=lightcyan
  hi link TabNum Special
  hi Visual ctermfg=black ctermbg=lightgrey

  hi shTodo ctermfg=white ctermbg=black
  hi rustTodo ctermfg=white ctermbg=black
  hi typescriptCommentTodo ctermfg=white ctermbg=black
  hi javaScriptCommentTodo ctermfg=white ctermbg=black

  hi Comment    cterm=NONE ctermfg=darkcyan  ctermbg=NONE
  hi LineNr     cterm=NONE ctermfg=gray  ctermbg=NONE
  hi String     cterm=NONE ctermfg=darkgreen ctermbg=NONE
  hi StatusLine cterm=NONE ctermfg=black ctermbg=NONE
  hi Todo       cterm=NONE ctermfg=white ctermbg=NONE

  hi SignColumn cterm=NONE ctermfg=black ctermbg=NONE
  hi Identifier cterm=NONE ctermfg=black ctermbg=NONE
  hi Type       cterm=NONE ctermfg=black ctermbg=NONE
  hi Constant   cterm=NONE ctermfg=black ctermbg=NONE
  hi Special    cterm=NONE ctermfg=black ctermbg=NONE
  hi Statement  cterm=NONE ctermfg=black ctermbg=NONE
  hi PreProc    cterm=NONE ctermfg=black ctermbg=NONE

  hi CursorLineNr ctermfg=grey
"###,
    );

    context.files.append(
        &context.system.get_home_path(".vim-macros"),
        r###"
Macros file.
This file is automatically generated. For custom macros, add them in ~/development/environment/project/vim-macros-custom
You can open this file with <leader>ee and that one with <leader>eE
"###,
    );

    std::fs::create_dir_all(context.system.get_home_path(".vim-snippets")).unwrap();

    install_vim_package(
        context,
        "junegunn/fzf",
        Some("cd ~/.vim/bundle/fzf && ./install --all; cd -"),
    );

    install_vim_package(context, "junegunn/fzf.vim", None);

    System::run_bash_command(
        r###"
__add_n_completion() {
  ALL_CMDS="n sh RsyncDelete node l o GitAdd GitRevertCode nn ll"; sed -i "s|nvim $ALL_CMDS |nvim |; s|nvim |nvim $ALL_CMDS |" "$1";
  DIR_CMDS='mkdir tree'; sed -i "s|pushd $DIR_CMDS |pushd |; s|pushd |pushd $DIR_CMDS |" "$1";
}
__add_n_completion "$HOME"/.vim/bundle/fzf/shell/completion.bash
__add_n_completion "$HOME"/.fzf/shell/completion.bash
"###,
    );

    if !Path::new(
        &context
            .system
            .get_home_path("development/environment/project/vim-macros-custom"),
    )
    .exists()
    {
        System::run_bash_command("touch ~/development/environment/project/vim-macros-custom");
    }

    System::run_bash_command(
        "bash ~/development/environment/unix/scripts/misc/create_vim_snippets.sh",
    );

    context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
alias VimSnippetsModify='nvim ~/development/environment/unix/scripts/misc/create_vim_snippets.sh && Provision'
alias VimCustomSnippetsModify='nvim ~/development/environment/project/custom_create_vim_snippets.sh && Provision'
"###,
        );

    // LOCAL: current branch, BASE: original file, REMOTE: file in opposite branch
    context.files.append(
        &context.system.get_home_path(".gitconfig"),
        r###"
[merge]
  tool = vimdiff
[mergetool]
  prompt = true
  keepBackup = false
[mergetool "vimdiff"]
  cmd = "$EDITOR" -p $MERGED $LOCAL $BASE $REMOTE
"###,
    );

    if Config::has_config_file(&context.system, "copilot") {
        install_vim_package(context, "github/copilot.vim", None);
        context.files.appendln(
            &context.system.get_home_path(".vim/colors.vim"),
            "hi CopilotSuggestion guifg=#ff8700 ctermfg=208",
        );

        // This is due to the screen not cleaned when dismissing a suggestion
        context.files.append(
            &context.system.get_home_path(".vimrc"),
            r###"
function! CustomDismiss() abort
  unlet! b:_copilot_suggestion b:_copilot_completion
  call copilot#Clear()
  redraw!
  echo "Dismissed"
  return ''
endfunction

imap <silent><script><nowait><expr> <C-]> CustomDismiss() . "\<C-]>"
nmap <silent><script><nowait><expr> <C-]> CustomDismiss() . "\<C-]>"
"###,
        );
    }

    if context.config.theme == Theme::Dark {
        context.files.replace(
            &context.system.get_home_path(".vim/lua/extra_beginning.lua"),
            r#"vim.g.limelight_conceal_ctermfg = 'LightGray'"#,
            r#"vim.g.limelight_conceal_ctermfg = 'DarkGray'"#,
        );
    }
}
