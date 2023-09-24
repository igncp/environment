# ctv START

# lg webos
#   Important: Ubuntu 14/16 is required (5Gb for VM is enough)
#   Download installation from: http://webostv.developer.lge.com/sdk/installation
#   Unzip and follow GUI installation
cat >>~/.shellrc <<"EOF"
export PATH="$PATH:/usr/local/share/webOS_TV_SDK/CLI/bin"
EOF

# tizen studio: THIS DOES NOT DEPLOY CORRECTLY IN UBUNTU - USE WINDOWS IDE
#   Download Ubuntu IDE version from: https://developer.tizen.org/development/tizen-studio/download
#   Install JDK and dependencies (TODO: Automate)
#   sudo add-apt-repository ppa:webupd8team/java ; sudo apt update; sudo apt install -y oracle-java8-installer
#   sudo apt-get install -y rpm2cpio libwebkitgtk-1.0-0 expect gettext ruby

cat >>~/.shellrc <<"EOF"
export PATH="$PATH:/home/igncp/tizen-studio/ide"
export PATH="$PATH:/home/igncp/tizen-studio/tools"
export PATH="$PATH:/home/igncp/tizen-studio/tools/ide/bin/"
EOF

cat >>~/.shell_aliases <<"EOF"
# i: installed (doesn't need update)
# u: needs update
# ni: not installed
TizenPM() { /home/igncp/tizen-studio/package-manager/package-manager-cli.bin "$@" ; }

# useful e.g. TizenListNotInstalledPkgs | grep -i tv
alias TizenListNotInstalledPkgs='TizenPM show-pkgs | grep -E "^ni"'
# Example: tizen create web-project -n foo -p tv-samsung-5.0 -t BasicBasicProject
alias TizenListWebTemplates='tizen list web-project'
# Couldn't find how to create these files without UI, although seems OpenSSL could do it
alias TizenListAuthorCertificates='find tizen-studio-data | grep p12'
alias TizenSeeCliLog='less -SN /home/igncp/tizen-studio-data/cli/logs/cli.log'
EOF

# Tizen Studio 3.x has an issue in Ubuntu with the Certificate Manager
# https://developer.tizen.org/forums/sdk-ide/certificate-manager-doesnt-store-passwords
# To download a previous version (2.5)
# http://download.tizen.org/sdk/Installer/

# ctv END
