#!/usr/bin/env bash

set -e

provision_setup_php() {
  cat >>~/.vimrc <<"EOF"
if executable('php')
  " https://github.com/prettier/plugin-php#configuration
  autocmd filetype php :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"

  nmap <leader>ll viw"iy:silent exec "!npx open-cli https://developer.wordpress.org/reference/functions/" . '<c-r>i' . " &"<CR>
  nmap <leader>lh viw"iy:silent exec "!npx open-cli https://developer.wordpress.org/reference/hooks/" . '<c-r>i' . " &"<CR>
  nmap <leader>lf viw"iy:silent exec "!npx open-cli https://www.php.net/manual/en/function." . substitute("<c-r>i", "_", "-", "g") . ".php &"<CR>

  nmap <leader>lp :!php -l %<cr>

  call add(g:coc_global_extensions, 'coc-phpls')
  call add(g:coc_global_extensions, '@yaegassy/coc-phpstan')
endif
EOF

  cat >>~/.shell_sources <<"EOF"
if type php >/dev/null 2>&1; then
  export PATH="$HOME/.config/composer/vendor/bin:$PATH"

  if [ -d ~/.local/share/nvim/lazy/coc-phpstan ] && [ ! -d ~/.local/share/nvim/lazy/coc-phpstan/node_modules ]; then
    echo "Installing coc-phpstan modules"
    (cd ~/.local/share/nvim/lazy/coc-phpstan && yarn install --frozen-lockfile)
  fi
fi
if type wp >/dev/null 2>&1; then
  if [ ! -f ~/.wp-completion ]; then
    echo "Downloading wp-completion"
    curl https://raw.githubusercontent.com/wp-cli/wp-cli/v1.5.1/utils/wp-completion.bash \
      -o ~/.wp-completion
  fi

  source_if_exists ~/.wp-completion
fi
EOF

  cat >>~/.shell_aliases <<"EOF"
if type php >/dev/null 2>&1; then
  alias LaravelServe='php artisan serve'
fi
EOF
}
