use std::path::Path;

use crate::base::{config::Config, system::System, Context};

pub fn run_mac_beginning(context: &mut Context) {
    std::fs::create_dir_all(context.system.get_home_path("Library/KeyBindings")).unwrap();

    context.files.append(
        &context
            .system
            .get_home_path("Library/KeyBindings/DefaultKeyBinding.dict"),
        r###"
{
  /* Map # to § key*/
  "§" = ("insertText:", "#");
}
"###,
    );

    if !context.system.get_has_binary("brew") {
        System::run_bash_command(
            r###"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
"###,
        )
    }

    if !Path::new(&context.system.get_home_path(".check-files/coreutils")).exists() {
        System::run_bash_command(
            r###"
brew install coreutils
brew install gnu-sed # sed with same options as in linux
brew install diffutils # for diff
touch ~/.check-files/coreutils
"###,
        );
    }

    // Rime - Squirrel
    //   I can't remember the location, but it may be from:
    //     https://github.com/rime/squirrel/releases
    //     https://github.com/rime/squirrel/issues/471#issuecomment-748751617
    //   Use `~/Library/Rime/default.custom.yaml``
    //   The `patch` in the top level, above `schemas`, is necessary

    if Config::has_config_file(&context.system, "network-analysis") {
        if !context.system.get_has_binary("wireshark") {
            System::run_bash_command(
                r###"
brew install --cask wireshark
"###,
            );
        }

        context.system.install_system_package("mitmproxy", None);
    }

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r#"
umask 027

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
"#,
    );

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r#"
alias MacDisks='diskutil list'
alias MacFeatures='system_profiler > /tmp/features.txt && echo "/tmp/features.txt written" && less /tmp/features.txt'
alias BrewListPackages='brew list'

# Edit this file: `/etc/pf.conf`
# For example: `pass in proto tcp from any to any port 3000`
alias MacRestartFirewallConfig='sudo pfctl -f /etc/pf.conf'
"#,
    );

    context.files.append(
        &context.system.get_home_path(".zshrc"),
        r#"
# For chinese characters
export LANG="en_US.UTF-8"
export LC_ALL=en_US.utf-8
"#,
    );

    context
        .system
        .install_system_package("pinentry", Some("pinentry-tty"));

    std::fs::create_dir_all(context.system.get_home_path(".gnupg")).unwrap();

    context.files.append(
        &context.system.get_home_path(".gnupg/gpg-agent.conf"),
        r#"
pinentry-program /opt/homebrew/bin/pinentry-tty
"#,
    );

    if !Path::new(&context.system.get_home_path(".check-files/init-apps")).exists() {
        System::run_bash_command(
            r###"
brew install iterm2 || true
brew install mysqlworkbench || true

# Reduce transparency
defaults write com.apple.universalaccess reduceTransparency -bool true || true

# Safari debug
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true && \
defaults write com.apple.Safari IncludeDevelopMenu -bool true && \
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true && \
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true && \
defaults write -g WebKitDeveloperExtras -bool true || true

# Xcode command-line tools
xcode-select --install || true

# Disable automatic arrangement of spaces
defaults write com.apple.dock mru-spaces -bool false && killall Dock
# Autohide dock
defaults write com.apple.dock autohide -bool true && killall Dock
# Disable icon bounce on notification
defaults write com.apple.dock no-bouncing -bool false && killall Dock
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles true
# Show hidden dir
chflags nohidden ~/Library
# Hide desktop icons
defaults write com.apple.finder CreateDesktop -bool false && killall Finder
# Show pathbar at the bottom
defaults write com.apple.finder ShowPathbar -bool true

cat >> ~/.shell_aliases <<"EOF"
alias MacListAppsAppStore='mdfind kMDItemAppStoreHasReceipt=1'
alias MacEjectAll="osascript -e 'tell application "'"Finder"'" to eject (every disk whose ejectable is true)'"
EOF

touch ~/.check-files/init-apps
"###,
        );
    }
}

pub fn run_mac_end(context: &mut Context) {
    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r#"
set backspace=indent,eol,start
"#,
    );
}
