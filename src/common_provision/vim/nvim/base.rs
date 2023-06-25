use std::path::Path;

use crate::base::{
    config::{Config, Theme},
    system::System,
    Context,
};

use super::{add_special_vim_map, install_nvim_package, lua::setup_nvim_lua};

pub fn run_nvim_base(context: &mut Context) {
    if !context.system.get_has_binary("nvim") {
        // https://github.com/neovim/neovim/releases/
        System::run_bash_command(
            r###"
cd ~ ; rm -rf nvim-repo ; git clone https://github.com/neovim/neovim.git nvim-repo --depth 1 --branch release-0.9 ; cd nvim-repo
# https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
make CMAKE_BUILD_TYPE=Release
make CMAKE_INSTALL_PREFIX=$HOME/nvim install
cd ~ ; rm -rf nvim-repo
"###,
        );
    }

    if !Path::new(&context.system.get_home_path(".check-files/neovim")).exists() {
        System::run_bash_command(
            r###"
pip3 install neovim
mkdir -p ~/.config ~/.vim
touch ~/.vimrc
rm -rf ~/.config/nvim
rm -rf ~/.vim/init.vim
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim
touch ~/.check-files/neovim
"###,
        );
    }

    setup_nvim_lua(context);

    install_nvim_package(context, "airblade/vim-gitgutter", None); // https://github.com/airblade/vim-gitgutter
    install_nvim_package(context, "andrewRadev/splitjoin.vim", None); // gS, gJ
    install_nvim_package(context, "bogado/file-line", None); // https://github.com/bogado/file-line
    install_nvim_package(context, "chentoast/marks.nvim", None); // https://github.com/chentoast/marks.nvim
    install_nvim_package(context, "ctrlpvim/ctrlp.vim", None); // https://github.com/ctrlpvim/ctrlp.vim
    install_nvim_package(context, "elzr/vim-json", None); // https://github.com/elzr/vim-json
    install_nvim_package(context, "google/vim-searchindex", None); // https://github.com/google/vim-searchindex
    install_nvim_package(context, "haya14busa/incsearch.vim", None); // https://github.com/haya14busa/incsearch.vim
    install_nvim_package(context, "honza/vim-snippets", None); // ind ~/.local/share/nvim/lazy/vim-snippets/snippets/ -type f | xargs sed -i 's|:\${VISUAL}||'"
    install_nvim_package(context, "jiangmiao/auto-pairs", None); // https://github.com/jiangmiao/auto-pairs
    install_nvim_package(context, "junegunn/limelight.vim", None); // https://github.com/junegunn/limelight.vim
    install_nvim_package(context, "junegunn/vim-peekaboo", None); // https://github.com/junegunn/vim-peekaboo
    install_nvim_package(context, "liuchengxu/vista.vim", None); // https://github.com/liuchengxu/vista.vim
    install_nvim_package(context, "mbbill/undotree", None); // https://github.com/mbbill/undotree
    install_nvim_package(context, "ntpeters/vim-better-whitespace", None); // https://github.com/ntpeters/vim-better-whitespace
    install_nvim_package(context, "plasticboy/vim-markdown", None); // https://github.com/plasticboy/vim-markdown
    install_nvim_package(context, "rhysd/clever-f.vim", None); // https://github.com/rhysd/clever-f.vim
    install_nvim_package(context, "ryanoasis/vim-devicons", None); // if not supported, add in custom: rm -rf ~/.local/share/nvim/lazy/vim-devicons/*
    install_nvim_package(context, "scrooloose/nerdcommenter", None); // https://github.com/scrooloose/nerdcommenter
    install_nvim_package(context, "sindrets/diffview.nvim", None); // https://github.com/sindrets/diffview.nvim
    install_nvim_package(context, "tommcdo/vim-exchange", None); // https://github.com/tommcdo/vim-exchange
    install_nvim_package(context, "tpope/vim-eunuch", None); // https://github.com/tpope/vim-eunuch
    install_nvim_package(context, "tpope/vim-fugitive", None); // https://github.com/tpope/vim-fugitive
    install_nvim_package(context, "tpope/vim-repeat", None); // https://github.com/tpope/vim-repeat
    install_nvim_package(context, "tpope/vim-surround", None); // https://github.com/tpope/vim-surround
    install_nvim_package(context, "vim-scripts/AnsiEsc.vim", None); // https://github.com/vim-scripts/AnsiEsc.vim

    // Themes
    install_nvim_package(context, "morhetz/gruvbox", None); // https://github.com/morhetz/gruvbox
                                                            // let g:gruvbox_contrast_dark = 'hard'
    install_nvim_package(context, "cocopon/iceberg.vim", None); // https://github.com/cocopon/iceberg.vim
    install_nvim_package(context, "dracula/vim", None); // https://github.com/cocopon/iceberg.vim

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
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
alias CheckVimSnippets='nvim ~/.local/share/nvim/lazy/vim-snippets/snippets'
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

    install_nvim_package(
        context,
        "junegunn/fzf",
        Some("cd ~/.local/share/nvim/lazy/fzf && ./install --all; cd -"),
    );

    install_nvim_package(context, "junegunn/fzf.vim", None);

    System::run_bash_command(
        r###"
__add_n_completion() {
  ALL_CMDS="n sh RsyncDelete node l o GitAdd GitRevertCode nn ll"; sed -i "s|nvim $ALL_CMDS |nvim |; s|nvim |nvim $ALL_CMDS |" "$1";
  DIR_CMDS='mkdir tree'; sed -i "s|pushd $DIR_CMDS |pushd |; s|pushd |pushd $DIR_CMDS |" "$1";
}
__add_n_completion "$HOME"/.local/share/nvim/lazy/fzf/shell/completion.bash || true
__add_n_completion "$HOME"/.fzf/shell/completion.bash || true
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

    if Config::has_config_file(&context.system, ".config/copilot") {
        install_nvim_package(context, "github/copilot.vim", None);
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
