use crate::base::{system::System, Context};

pub fn run_asdf(context: &mut Context) {
    if context.system.is_nixos() {
        return;
    }
    let shellrc_file = &context.system.get_home_path(".shellrc");

    context.files.append(
        shellrc_file,
        r###"
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
"###,
    );

    if !context.system.get_has_binary("asdf") {
        context.write_file(shellrc_file, false);

        System::run_bash_command(
            r###"
rm -rf ~/.asdf
LAST_TAG=$(git ls-remote --tags https://github.com/asdf-vm/asdf | awk '{ print $2 }' \
| grep -v {} | sed 's|refs/tags/||' | sort -Vr | head -n 1)
# list all versions of language: asdf list all PLUGIN_NAME
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "$LAST_TAG"
"###,
        );
    }
}
