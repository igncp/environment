use crate::base::Context;

pub fn setup_unalias(context: &mut Context) {
    let zsh_file = context.system.get_home_path(".zshrc");

    // These are set by: `~/.oh-my-zsh/plugins/git/git.plugin.zsh`
    let removed_aliases = vec![
        "g",
        "ggpur",
        "ggpull",
        "ggpush",
        "ggsup",
        "gpsup",
        "ghh",
        "gignore",
        "gignored",
        "gk",
        "gke",
        "gl",
        "glg",
        "glgp",
        "glgg",
        "glgga",
        "glgm",
        "glo",
        "glol",
        "glols",
        "glod",
        "glods",
        "glola",
        "glog",
        "gloga",
        "glp",
        "gm",
        "gmom",
        "gmtl",
        "gmtlvim",
        "gmum",
        "gma",
        "gms",
        "gp",
        "gpd",
        "gpf!",
        "gpoat",
        "gpod",
        "gpr",
        "gpu",
        "gpv",
        "gr",
        "gra",
        "grb",
        "grba",
        "grbc",
        "grbd",
        "grbi",
        "grbm",
        "grbom",
        "grbo",
        "grbs",
        "grev",
        "grh",
        "grhh",
        "groh",
        "grm",
        "grmc",
        "grmv",
        "grrm",
        "grs",
        "grset",
        "grss",
        "grst",
        "grt",
        "gru",
        "grup",
        "grv",
        "gsb",
        "gsd",
        "gsh",
        "gsi",
        "gsps",
        "gsr",
        "gss",
        "gst",
        "gstaa",
        "gstc",
        "gstd",
        "gstl",
        "gstp",
        "gsts",
        "gstu",
        "gstall",
        "gsu",
        "gsw",
        "gswc",
        "gswm",
        "gswd",
        "gts",
        "gtv",
        "gtl",
        "gunignore",
        "gunwip",
        "gup",
        "gupv",
        "gupa",
        "gupav",
        "gupom",
        "gupomi",
        "glum",
        "gluc",
        "gwch",
        "gwip",
        "gwt",
        "gwta",
        "gwtls",
        "gwtmv",
        "gwtrm",
        "gam",
        "gamc",
        "gams",
        "gama",
        "gamscp",
    ];
    let unalias_str = removed_aliases
        .iter()
        .map(|alias| format!("unalias -m '{}'", alias))
        .collect::<Vec<String>>()
        .join("\n");

    context.files.append(&zsh_file, &unalias_str);
}
