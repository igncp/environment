use crate::base::{config::Config, system::System, Context};

pub fn setup_vnc(context: &mut Context) {
    if Config::has_config_file(&context.system, ".config/headless-xorg") {
        System::run_bash_command(
            r###"
  if [ ! -f ~/.check-files/xf86-video-dummy ]; then sudo pacman -S xf86-video-dummy; touch ~/.check-files/xf86-video-dummy; fi
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
EOF
  sudo mv /tmp/Xwrapper.config  /etc/X11/
"###,
        );

        context.home_append(
            ".shell_aliases",
            r###"
alias HeadlessXRandrLarge="DISPLAY=:0 xrandr --output DUMMY0 --mode 1920x1080"
alias HeadlessXRandrMedium="DISPLAY=:0 xrandr --output DUMMY0 --mode 1280x720"

HeadlessStart() {
    startx &
    x11vnc -usepw &
    sleep 10 && DISPLAY=:0 xrandr --output DUMMY0 --mode 1280x720

    wait
}
"###,
        );
    }

    context.system.install_system_package("x11vnc", None);
}
