use crate::base::{files::Files, system::System, Context};

pub fn run_htop(context: &mut Context) {
    // https://www.thegeekstuff.com/2011/09/linux-htop-examples
    // C: configuration, w: see command wrapped
    context.system.install_system_package("htop", None);
    let htop_file = context
        .system
        .get_home_path("development/environment/unix/config-files/htoprc");
    Files::assert_it_exists(&htop_file);

    System::run_bash_command(&format!(
        r###"
mkdir -p ~/.config/htop
cp {htop_file} ~/.config/htop/htoprc
"###,
    ));

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias HTopCPU='htop -s PERCENT_CPU -d 6000'
alias HTopMem='htop -s PERCENT_MEM -d 6000'
"###,
    );
}
