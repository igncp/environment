use std::path::Path;

use crate::base::{config::Config, system::System, Context};

use super::vim::install_nvim_package;

pub fn setup_php(context: &mut Context) {
    if !Config::has_config_file(&context.system, "php") {
        return;
    }

    context.system.install_system_package("php", None);

    context.files.append(
        &context.system
            .get_home_path(".vimrc"),
        r###"
" https://github.com/prettier/plugin-php#configuration
autocmd filetype php :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"

nmap <leader>ll viw"iy:silent exec "!npx open-cli https://developer.wordpress.org/reference/functions/" . '<c-r>i' . " &"<CR>
nmap <leader>lh viw"iy:silent exec "!npx open-cli https://developer.wordpress.org/reference/hooks/" . '<c-r>i' . " &"<CR>
nmap <leader>lf viw"iy:silent exec "!npx open-cli https://www.php.net/manual/en/function." . substitute("<c-r>i", "_", "-", "g") . ".php &"<CR>

nmap <leader>lp :!php -l %<cr>

call add(g:coc_global_extensions, 'coc-phpls')
call add(g:coc_global_extensions, '@yaegassy/coc-phpstan')
"###
    );

    install_nvim_package(
        context,
        "yaegassy/coc-phpstan",
        Some("cd ~/.local/share/nvim/lazy/coc-phpstan && yarn install --frozen-lockfile"),
    );

    if !Config::has_config_file(&context.system, "php-no-composer")
        && !context.system.get_has_binary("composer")
    {
        System::run_bash_command(
            r###"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
"###,
        );
    }

    if Config::has_config_file(&context.system, "phpactor")
        && !context.system.get_has_binary("phpactor")
    {
        System::run_bash_command(
            r###"
rm -rf ~/.phpactor
git clone https://github.com/phpactor/phpactor.git --depth 1 ~/.phpactor ; cd ~/.phpactor
composer install
sudo ln -s "$(pwd)/bin/phpactor" /usr/local/bin/phpactor
cd ~
"###,
        );
    }

    if Config::has_config_file(&context.system, "php-mysql") {
        System::run_bash_command(
            r###"
sudo sed -i 's|;extension=mysqli|extension=mysqli|' /etc/php/php.ini
sudo sed -i 's|;extension=pdo_mysql|extension=pdo_mysql|' /etc/php/php.ini
"###,
        );
    }

    context.files.append(
        "/tmp/expected-vscode-extensions",
        r###"
felixfbecker.php-debug
"###,
    );

    if Config::has_config_file(&context.system, "wp-cli") {
        if !context.system.get_has_binary("wp") {
            System::run_bash_command(
                r###"
sudo curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x /usr/local/bin/wp
sudo chown $USER /usr/local/bin/wp
"###,
            );
        }

        if !Path::new(&context.system.get_home_path(".wp-completion")).exists() {
            System::run_bash_command(
                "curl https://raw.githubusercontent.com/wp-cli/wp-cli/v1.5.1/utils/wp-completion.bash -o ~/.wp-completion"
            );
        }

        context.files.append(
            &context.system.get_home_path(".shell_sources"),
            r###"
source_if_exists ~/.wp-completion
"###,
        );
    }
}
