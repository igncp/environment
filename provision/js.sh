# js START

NODE_VERSION=6.11.1
if [ ! -f ~/.check-files/node ]; then
  echo "setup node with nodenv"
  cd ~
  if [ ! -d ~/.nodenv ]; then git clone https://github.com/nodenv/nodenv.git ~/.nodenv && cd ~/.nodenv && src/configure && make -C src; fi && \
    export PATH=$PATH:/home/$USER/.nodenv/bin && \
    eval "$(nodenv init -)" && \
    if [ ! -d ~/.nodenv/plugins/node-build ]; then git clone https://github.com/nodenv/node-build.git $(nodenv root)/plugins/node-build; fi && \
    if [ ! -d .nodenv/versions/$NODE_VERSION ]; then nodenv install $NODE_VERSION; fi && \
    nodenv global $NODE_VERSION && \
    mkdir -p ~/.check-files && touch ~/.check-files/node
  rm -f ~/install.sh
fi

install_node_modules() {
  for MODULE_NAME in "$@"; do
    if [ ! -d ~/.nodenv/versions/$NODE_VERSION/lib/node_modules/$MODULE_NAME ]; then
      echo "doing: npm i -g $MODULE_NAME"
      npm i -g $MODULE_NAME
    fi
  done
}

install_node_modules http-server diff-so-fancy eslint babel-eslint cloc yo eslint_d flow flow-cli

cat >> ~/.bashrc <<"EOF"
export PATH=$PATH:/home/$USER/.nodenv/bin
export PATH=$PATH:/home/$USER/.nodenv/versions/6.11.1/bin/
eval "$(nodenv init -)"
source <(npm completion)
EOF

cat >> ~/.bash_aliases <<"EOF"
alias Serve="http-server -c-1 -p 9000"
GitDiff() { git diff --color $@; }
GitsShow() { git show --color $@; }
# Fix coloring of mocha in some windows terminals
alias Mocha="./node_modules/.bin/mocha -c $@ > >(perl -pe 's/\x1b\[90m/\x1b[92m/g') 2> >(perl -pe 's/\x1b\[90m/\x1b[92m/g' 1>&2)"
EOF

git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global color.diff-highlight.oldNormal "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

cat > /tmp/clean-vim-js-syntax.sh <<"EOF"
sed -i 's|const |async await |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|let var |let var const |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|export from|export|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|import public|import from public|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
echo "Changed vim javascript syntax"
EOF

# not installing vim-javascript as it doesn't work with rainbow
install_vim_package ternjs/tern_for_vim "cd ~/.vim/bundle/tern_for_vim; npm i"
install_vim_package quramy/tsuquyomi
install_vim_package leafgarland/typescript-vim
install_vim_package kchmck/vim-coffee-script
install_vim_package flowtype/vim-flow
install_vim_package jelera/vim-javascript-syntax "sh /tmp/clean-vim-js-syntax.sh"
install_vim_package samuelsimoes/vim-jsx-utils

cat >> ~/.vimrc <<"EOF"
" quick console.log
  let ConsoleMappingA="vnoremap <leader>kk yOconsole.log('a', a);<C-c>6hvpvi'yf'lllvp"
  let ConsoleMappingB='nnoremap <leader>kj iconsole.log("LOG POINT - <C-r>=fake#gen("nonsense")<CR>");<cr><c-c>'
  autocmd filetype javascript :exe ConsoleMappingA
  autocmd filetype javascript :exe ConsoleMappingB
  autocmd FileType typescript :exe ConsoleMappingA
  autocmd FileType typescript :exe ConsoleMappingB

" grep same indent props
  execute 'nnoremap <leader>ki ^hv0y' . g:GrepCF_fn . ' -o "^<c-r>"\w*:"<left>'

" term
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR><Paste>

" run eslint over file
  autocmd filetype javascript :exe "nnoremap <silent> <leader>kb :!eslint_d --fix %<cr>:e<cr>"

" js linters
  let g:syntastic_javascript_checkers = ['flow', 'eslint']
  let g:syntastic_javascript_eslint_exec = 'eslint_d'
  let g:syntastic_typescript_checkers = ['tsc', 'tslint']
  let g:flow#enable = 0

 autocmd BufNewFile,BufRead *.js
	\ call neosnippet#commands#_source("/home/vagrant/.vim/bundle/vim-snippets/snippets/javascript.es6.react.snippets")

" jsx utils
  nnoremap <leader>jx $i<left><space><cr><up><c-c>:call JSXEachAttributeInLine()<CR>:%s/\s\+$<CR><c-o>A<cr><tab>
EOF

cat > /tmp/js-and-ts-snippets <<"EOF"
snippet ide
  if (${0}) {
    debugger;
  }
snippet ck
  console.log("${0:}", $0);
snippet cj
  console.log("LOG POINT - ${0:}");
snippet des
  describe("${1:}", () => {
    it("${2:}", () => {
      ${0}
    });
  });
snippet xdescribeFunction
  describe("${1:}", function() {
    ${0}
  });
snippet XbeforeEach
  beforeEach(() => {
    ${0}
  });
snippet XafterEach
  afterEach(() => {
    ${0}
  });
snippet it
  it("${1:}", () => {
    ${0}
  });
snippet exp
  expect(${1:}).to${0};
snippet i
  import {
    ${1},
  } from "${2}";
snippet t
  <${1}${3}>${2}</$1>
snippet T
  <${1} ${2}/>
snippet TT
  <${1}
  />
snippet tt
  <${1}
  >
    ${2}
  </$1>
snippet XexpectToEqual
  expect(${1}).toEqual(${0});
snippet XexpectJustCallsToEqual
  expect(${1}.mock.calls).toEqual([${0}])
snippet XexpectCallsLengthToEqual
  expect(${1}.mock.calls.length).toEqual(${2:0})${0}
snippet >
  (${1}) => ${2:null}${0}
EOF
cat /tmp/js-and-ts-snippets > ~/.vim-snippets/javascript.snippets
cat /tmp/js-and-ts-snippets > ~/.vim-snippets/typescript.snippets

install_node_modules markdown-toc
cat >> ~/.bash_aliases <<"EOF"
alias MarkdownTocRecursive='find . ! -path "*.git*" -name "*.md" | xargs -I {} markdown-toc -i {}'
EOF
cat > ~/.vim-snippets/markdown.snippets <<"EOF"
snippet toc
  <!-- toc -->
EOF

install_node_modules yarn yarn-completions

install_node_modules gnomon

install_node_modules node-inspector
cat >> ~/.bash_aliases <<"EOF"
alias NI='node-inspector -p 9001'
alias ND='node-debug --debug-brk'
EOF

cat > ~/.js-tests-specs-displayer <<"EOF"
#!/usr/bin/env bash
# this file is generated from the provision, changes will be overwritten
FILE_PATH="$1";
source ~/hhighlighter/h.sh
export H_COLORS_FG="green,blue"
grep -E "it\(|describe\(|it\.only\(|describe\.only\(" "$FILE_PATH" |
  sed -r 's| \(\) => \{$||; s| async$||; s|,$||; s|it.only\(|it(|; s|describe\.only\(|describe(|' |
  h "describe\((.*)" "it\((.*)" |
  sed "s|describe(||; s|it(||;" > /tmp/tests-specs
sed -i '1i'"$FILE_PATH\n" /tmp/tests-specs
echo "" >> /tmp/tests-specs
less -R /tmp/tests-specs
EOF
chmod +x ~/.js-tests-specs-displayer
cat >> ~/.vimrc <<"EOF"
  autocmd filetype javascript :exe 'nnoremap <leader>zt :-tabnew\|te ~/.js-tests-specs-displayer <c-r>=expand("%:p")<cr><cr>'
EOF

echo "./node_modules/.bin/jest">> ~/.bookmarked-commands

# js END

# js-extras START

# reason: https://github.com/facebook/reason
  echo 'eval $(opam config env)' >> ~/.bashrc
  if ! type opam > /dev/null 2>&1; then
    wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin
    opam update
    opam switch 4.03.0
    eval $(opam config env)
    cd ~
    git clone git@github.com:facebook/reason.git
    cd reason
    opam pin add -y reason-parser reason-parser
    opam pin add -y reason .
    npm install -g git://github.com/reasonml/reason-cli.git
  fi
  install_vim_package reasonml/vim-reason-loader
  cat >> ~/.vimrc <<"EOF"
  let g:deoplete#omni_patterns = {}
  let g:deoplete#omni_patterns.reason = '[^. *\t]\.\w*\|\h\w*|#'
  let g:deoplete#sources = {}
  let g:deoplete#sources.reason = ['omni', 'buffer']
  let g:syntastic_reason_checkers=['merlin']
  autocmd FileType reason nmap <buffer> <leader>kb :ReasonPrettyPrint<Cr>
EOF

install_node_modules import-js
install_vim_package galooshi/vim-import-js

cat >> ~/.vimrc <<"EOF"
function! g:RunCtrlPWithFilterInNewTab(query)
  let g:ctrlp_default_input=a:query
  execute '-tabnew'
  execute 'CtrlP'
  let g:ctrlp_default_input=''
endfunction
EOF

_add_special_vim_map "cpfat" $':call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr>test\')<cr>' 'ctrlp filename adding test'
_add_special_vim_map "cpfrt" $':call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr><bs><bs><bs><bs><bs>\')<cr>' 'ctrlp filename removing test'
add_special_vim_map "ct" $'? it(<cr>V$%y$%o<cr><c-c>Vpf\'<right>ci\'' 'test copy it test case content'
add_special_vim_map "ee" $'iXexpectEqual<c-o>:call feedkeys("<c-l>", "t")<cr>' 'test expect toEqual'

cat >> ~/.vim-macros <<"EOF"

" Convert jsx prop to object property
_f=i\<del>: \<c-c>\<right>%s,\<c-c>``s\<c-c>``j
EOF

# js-extras END
