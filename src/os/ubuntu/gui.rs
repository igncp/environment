use std::path::Path;

use crate::base::{config::Config, system::System, Context};

pub fn run_ubuntu_gui(context: &mut Context) {
    // Black screen after boot
    // - On booting, press `Esc` to enter the GRUB screen
    // - Press `e` on the `Ubuntu` line to enter the Edit Mode
    // - Change `ro quiet splash` by `nomodeset quiet splash`
    if !Path::new(&context.system.get_home_path(".check-files/lightdm")).exists() {
        System::run_bash_command(
            r###"
sudo apt-get install -y lightdm
dkpg-reconfigure lightdm
mkdir -p ~/.check-files && touch ~/.check-files/lightdm
"###,
        );
    }

    context
        .system
        .install_system_package("build-essential", Some("make"));
    context
        .system
        .install_system_package("update-manager", None);

    if Config::has_config_file(&context.system, ".config/headless-xorg") {
        System::run_bash_command(
            r###"
if [ -n "$(sudo systemctl is-active lightdm | grep '\bactive\b' || true)" ]; then
    sudo systemctl disable --now lightdm
fi
if [ -z "$(groups | grep '\btty\b' || true)" ]; then sudo usermod -a -G tty igncp; fi
if [ -z "$(groups | grep '\bvideo\b' || true)" ]; then sudo usermod -a -G video igncp; fi
if [ -z "$(groups | grep '\baudio\b' || true)" ]; then sudo usermod -a -G audio igncp; fi

if [ ! -f ~/.check-files/headless-driver ]; then
    sudo apt-get install -y xserver-xorg-video-dummy
    sudo apt-get install -y xdg-utils # Required for browser
    touch ~/.check-files/headless-driver
fi
cat > /tmp/10-headless.conf <<"EOF"
Section "Monitor"
        Identifier "dummy_monitor"
        HorizSync 28.0-80.0
        VertRefresh 48.0-75.0
        Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
EndSection

Section "Device"
        Identifier "dummy_card"
        VideoRam 256000
        Driver "dummy"
EndSection

Section "Screen"
        Identifier "dummy_screen"
        Device "dummy_card"
        Monitor "dummy_monitor"
        SubSection "Display"
        EndSubSection
EndSection
EOF

sudo mv /tmp/10-headless.conf /etc/X11/xorg.conf.d/

cat > /tmp/Xwrapper.config <<"EOF"
allowed_users = anybody
needs_root_rights = yes
EOF

sudo mv /tmp/Xwrapper.config  /etc/X11/
"###,
        );

        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
alias HeadlessStart="startx"
alias HeadlessXRandr="DISPLAY=:0 xrandr --output default --mode 1920x1080"
"###,
        );
    }

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias WifiConnect='nmtui'
"###,
    );

    if !Path::new(&context.system.get_home_path(".check-files/adobe-font")).exists() {
        System::run_bash_command(
            r###"
sudo apt-get install -y fonts-noto
mkdir -p /tmp/adodefont
cd /tmp/adodefont
wget -q --show-progress -O source-code-pro.zip https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip
unzip -q source-code-pro.zip -d source-code-pro
fontpath="${XDG_DATA_HOME:-$HOME/.local/share}"/fonts
mkdir -p $fontpath
cp -v source-code-pro/*/OTF/*.otf $fontpath
fc-cache -f
rm -rf source-code-pro{,.zip}
touch ~/.check-files/adobe-font
"###,
        );
    }
}
