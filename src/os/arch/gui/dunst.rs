use crate::base::{system::System, Context};

pub fn setup_dunst(context: &mut Context) {
    if !context.system.is_arm() {
        if !context.system.get_has_binary("dunst") {
            println!("Installing Dust");
            System::run_bash_command(
                r###"
(cd ~ \
    && rm -rf dunst \
    && git clone https://github.com/dunst-project/dunst.git \
    && cd dunst \
    && make && sudo make install)
(mkdir -p ~/.config/dunst \
    && cp ~/dunst/dunstrc ~/.config/dunst/ \
    && rm -rf ~/dunst)
"###,
            )
        }

        System::run_bash_command(
            r###"
sed -i 's| history =|#history =|' ~/.config/dunst/dunstrc
sed -i 's|max_icon_size =.*|max_icon_size = 32|' ~/.config/dunst/dunstrc
sed -i 's|font = .*$|font = Monospace 12|' ~/.config/dunst/dunstrc
sed -i 's|geometry = .*$|geometry = "500x5-30+20"|' ~/.config/dunst/dunstrc
sed -i '1i(sleep 5s && dunst) &' ~/.xinitrc
"###,
        )
    }
}
