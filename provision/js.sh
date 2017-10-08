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

install_node_modules http-server diff-so-fancy eslint babel-eslint cloc yo eslint_d flow flow-cli flow-bin

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
sed -i 's|import public|import from type public|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
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
snippet xBeforeEach
  beforeEach(() => {
    ${0}
  });
snippet xAfterEach
  afterEach(() => {
    ${0}
  });
snippet it
  it("${1:}", () => {
    ${0}
  });
snippet exp
  expect(${1:}).to${0};
snippet t
  <${1}>${2}</$1>
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
snippet xExpectToEqual
  expect(${1}).toEqual(${0});
snippet xExpectJustCallsToEqual
  expect(${1}.mock.calls).toEqual([${0}])
snippet >
  (${1}) => ${2:null}${0}
snippet xJestJustMock
  jest.mock("${0}")
snippet xJestMockWithVariable
  const mock$2 = {
    ${0}: jest.fn(),
  }
  jest.mock("${1}", () => mock${2})
snippet xJestSpyOn
  jest.spyOn(${1}, "${2}")
snippet xConstJustRequire
  const ${1} = require("${0}$1")
snippet xConstRequireDestructuring
  const {
    ${1},
  } = require("${0}")
snippet xJestMockImplementation
  ${1}.mockImplementation(() => ${0})
snippet xJestMockReturnValue
  ${1}.mockReturnValue(${0})
snippet xIstanbulIgnoreElse
   // istanbul ignore else
snippet xEnzymeShallowWrapper
  const wrapper = shallow(
    <${0} />
  )
snippet xExpectEnzymeFindLength
  expect(${1:wrapper}.find(${2})).toHaveLength(${0:1});
snippet xJestFnRaw
  jest.fn(${0})
snippet xJestFnConst
  const ${1} = jest.fn(${0})
snippet xJestFnProperty
  ${1}: jest.fn(${0}),
snippet xJestFnExisting
  ${1} = jest.fn(${0})
snippet xReactSetState
  ${1: this}.setState({
    ${2}: ${0},
  })
snippet i
  import ${1} from "${0}"
snippet ii
  import {
    ${1},
  } from "${0}"
snippet xConstObjEqual
  const ${1} = {
    ${2}: ${0},
  }
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

cat >> ~/.vim-snippets/javascript.snippets <<"EOF"
snippet XimportType
  import type { ${1} } from '${0}';
snippet XflowComment
  // @flow
  ${0}
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

  function! ToggleItOnly()
    execute "normal! ?it(\\|it.only(\<cr>\<right>\<right>"
    let current_char = nr2char(strgetchar(getline('.')[col('.') - 1:], 0))
    if current_char == "."
      execute "normal! v4l\<del>"
    else
      execute "normal! i.only\<c-c>"
    endif
    execute "normal! \<c-o>"
  endfunction
  autocmd filetype javascript :exe 'nnoremap <leader>zo :call ToggleItOnly()<cr>'
EOF

echo "./node_modules/.bin/jest">> ~/.bookmarked-commands

cat >> ~/.vimrc <<"EOF"
function! g:RunCtrlPWithFilterInNewTab(query)
  let g:ctrlp_default_input=a:query
  execute '-tabnew'
  execute 'CtrlP'
  let g:ctrlp_default_input=''
endfunction
EOF

add_special_vim_map "cpfat" $':call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr>test\')<cr>' 'ctrlp filename adding test'
add_special_vim_map "cpfrt" $':call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr><bs><bs><bs><bs><bs>\')<cr>' 'ctrlp filename removing test'
add_special_vim_map "ctit" $'? it(<cr>V$%y$%o<cr><c-c>Vpf\'<right>ci\'' 'test copy it test case content'
add_special_vim_map "ctde" $'? describe(<cr>V$%y$%o<cr><c-c>Vpf\'<right>ci\'' 'test copy describe test content'
add_special_vim_map "eeq" $'iXexpectEqual<c-o>:call feedkeys("<c-l>", "t")<cr>' 'test expect toEqual'
add_special_vim_map "sjsfun" "v/[^,] {<cr><right>%" "select js function"
add_special_vim_map "djsfun" "v/[^,] {<cr><right>%d" "cut js function"
add_special_vim_map "jsjmi" "a.mockImplementation(() => )<left>" "jest mock implementation"
add_special_vim_map "jrct" "gv:<c-u>%s/\%V\C+//ge<cr>:<c-u>%s/\%V\CObject //ge<cr>:<c-u>%s/\%V\CArray //ge<cr>" \
  "jest replace copied text from terminal"
add_special_vim_map 'tjmvs' 'I<c-right><right><c-c>viwy?describe(<cr>olet <c-c>pa;<c-c><c-o><left>v_<del>' \
  'jest move variable outside of it'
add_special_vim_map "titr" $'_ciwconst<c-c>/from<cr>ciw= require(<del><c-c>$a)<c-c>V:<c-u>%s/\%V\C;//g<cr>' \
  'transform import to require'
add_special_vim_map "jimc" "a.mock.calls<c-c>" "jest instert mock calls"
add_special_vim_map "jimi" "a.mockImplementation(() => )<left>" "jest instert mock implementation"
add_special_vim_map "jirv" "a.mockReturnValue()<left>" "jest instert mock return value"

cat >> ~/.vim-macros <<"EOF"

" Convert jsx prop to object property
_f=i\<del>: \<c-c>\<right>%s,\<c-c>``s\<c-c>``j

" Create test property
_f:v$\<left>\<del>A: \<c-c>_viwyA''\<c-c>\<left>paValue\<c-c>A,\<c-c>_\<down>

" wrap type object in tag
i<\<c-c>\<right>%a>\<c-c>\<left>%\<left>
EOF

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

# import js
  install_node_modules import-js
  install_vim_package galooshi/vim-import-js
  add_special_vim_map 'impjswor' ':ImportJSWord<cr>' 'import js word'
  add_special_vim_map 'impjswor' ':ImportJSFix<cr>' 'import js file'

# js-extras END
