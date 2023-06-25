use crate::base::{config::Config, Context};

pub fn setup_diagrams(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/diagrams") {
        return;
    }

    // https://plantuml.com/
    // Styling: https://plantuml.com/creole
    context.system.install_system_package("plantuml", None);

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias PlantUMLHelp='java -jar /usr/share/java/plantuml/plantuml.jar -help'
alias PlantUMLSVG='java -jar /usr/share/java/plantuml/plantuml.jar -darkmode -v -tsvg'
"###,
    );
}
