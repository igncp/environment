#!/usr/bin/env bash

set -e

provision_setup_php() {
  if [ ! -f "$PROVISION_CONFIG"/php ]; then
    return
  fi

  install_system_package php

  cat >>~/.vimrc <<"EOF"
" https://github.com/prettier/plugin-php#configuration
autocmd filetype php :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"

nmap <leader>ll viw"iy:silent exec "!npx open-cli https://developer.wordpress.org/reference/functions/" . '<c-r>i' . " &"<CR>
nmap <leader>lh viw"iy:silent exec "!npx open-cli https://developer.wordpress.org/reference/hooks/" . '<c-r>i' . " &"<CR>
nmap <leader>lf viw"iy:silent exec "!npx open-cli https://www.php.net/manual/en/function." . substitute("<c-r>i", "_", "-", "g") . ".php &"<CR>

nmap <leader>lp :!php -l %<cr>

call add(g:coc_global_extensions, 'coc-phpls')
call add(g:coc_global_extensions, '@yaegassy/coc-phpstan')
EOF

  install_nvim_package yaegassy/coc-phpstan \
    "cd ~/.local/share/nvim/lazy/coc-phpstan && yarn install --frozen-lockfile"

  if [ ! -f "$PROVISION_CONFIG"/php-no-composer ]; then
    if ! type composer >/dev/null 2>&1; then
      curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    fi
  fi

  if [ -f "$PROVISION_CONFIG"/php-no-composer ]; then
    if ! type composer >/dev/null 2>&1; then
      rm -rf ~/.phpactor
      git clone https://github.com/phpactor/phpactor.git --depth 1 ~/.phpactor
      cd ~/.phpactor
      composer install
      sudo ln -s "$(pwd)/bin/phpactor" /usr/local/bin/phpactor
      cd ~
    fi
  fi

  if [ -f "$PROVISION_CONFIG"/php-mysql ]; then
    sudo sed -i 's|;extension=mysqli|extension=mysqli|' /etc/php/php.ini
    sudo sed -i 's|;extension=pdo_mysql|extension=pdo_mysql|' /etc/php/php.ini
  fi

  cat >>/tmp/expected-vscode-extensions <<"EOF"
felixfbecker.php-debug
EOF

  if [ -f "$PROVISION_CONFIG"/wp-cli ]; then
    if ! type wp >/dev/null 2>&1; then
      sudo curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
      sudo chmod +x /usr/local/bin/wp
      sudo chown $USER /usr/local/bin/wp
    fi

    if [ ! -f !/.wp-completion ]; then
      curl https://raw.githubusercontent.com/wp-cli/wp-cli/v1.5.1/utils/wp-completion.bash -o ~/.wp-completion
    fi

    cat >>~/.shell_aliases <<"EOF"
source_if_exists ~/.wp-completion
EOF
  fi
}
