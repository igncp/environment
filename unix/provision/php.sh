# php START

# * requires
# - be placed after apache provision
# - be placed after mysql provision (if used)

install_system_package php
if type mysql > /dev/null 2>&1 ; then
  sudo sed -i 's|;extension=mysqli|extension=mysqli|' /etc/php/php.ini
  sudo sed -i 's|;extension=pdo_mysql|extension=pdo_mysql|' /etc/php/php.ini
fi
cat >> /tmp/expected-vscode-extensions <<"EOF"
felixfbecker.php-debug
EOF
cat >> ~/.vimrc <<"EOF"
" https://github.com/prettier/plugin-php#configuration
autocmd filetype php :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"

nmap <leader>ll viw"iy:silent exec "!npx open-cli https://developer.wordpress.org/reference/functions/" . '<c-r>i' . " &"<CR>
nmap <leader>lh viw"iy:silent exec "!npx open-cli https://developer.wordpress.org/reference/hooks/" . '<c-r>i' . " &"<CR>
nmap <leader>lf viw"iy:silent exec "!npx open-cli https://www.php.net/manual/en/function." . substitute("<c-r>i", "_", "-", "g") . ".php &"<CR>
EOF

if [ ! -f ~/project/.config/no-composer ]; then
  if ! type composer > /dev/null 2>&1 ; then
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
  fi
fi

if [ -f ~/project/.config/wp-cli ]; then
  if ! type wp > /dev/null 2>&1 ; then
    sudo curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    sudo chmod +x /usr/local/bin/wp
  fi
  if [ ! -f ~/.wp-completion ]; then
    curl https://raw.githubusercontent.com/wp-cli/wp-cli/v1.5.1/utils/wp-completion.bash -o ~/.wp-completion
  fi
  echo 'source_if_exists ~/.wp-completion' >> ~/.shell_sources
fi

if [ -f ~/project/.config/phpactor ]; then
  if ! type phpactor > /dev/null 2>&1 ; then
    rm -rf ~/.phpactor
    git clone https://github.com/phpactor/phpactor.git --depth 1 ~/.phpactor ; cd ~/.phpactor
    composer install
    sudo ln -s "$(pwd)/bin/phpactor" /usr/local/bin/phpactor
    cd ~
  fi
fi

# php END
