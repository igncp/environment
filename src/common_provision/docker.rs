use std::path::Path;

use crate::base::{config::Config, system::System, Context};

pub fn setup_docker(context: &mut Context) {
    if Config::has_config_file(&context.system, ".config/docker-skip") {
        return;
    }

    if context.system.is_mac() {
        return;
    }

    if Config::has_config_file(&context.system, ".config/nix-only")
        && context.system.is_linux()
        && !context.system.get_has_binary("docker")
    {
        System::run_bash_command(
            r###"
curl -fsSL https://get.docker.com  | sh
sudo usermod -a -G docker igncp
"###,
        );
    }

    context.system.install_system_package("docker", None);

    context.files.appendln(
        &context.system.get_home_path(".shellrc"),
        r#"export PATH=$PATH:/usr/local/lib/docker/bin"#,
    );

    std::fs::create_dir_all(context.system.get_home_path(".docker/cli-plugins")).unwrap();

    if !Path::new(&context.system.get_home_path(".check-files/docker")).exists()
        && !context.system.is_nixos()
    {
        // TODO: option to set up https://github.com/chaifeng/ufw-docker
        context
            .system
            .install_system_package("docker-compose", None);

        System::run_bash_command(
            r###"
sudo usermod -a -G docker "$USER" # may need reboot
sudo systemctl enable --now docker
"###,
        );

        let regctl_arch = if context.system.is_arm() {
            "arm64"
        } else {
            "amd64"
        };
        let regctl_os = if context.system.is_mac() {
            "darwin"
        } else {
            "linux"
        };

        System::run_bash_command(&format!(
            r###"
curl -L "https://github.com/regclient/regclient/releases/latest/download/regctl-{regctl_os}-{regctl_arch}" \
    > /tmp/regctl
sudo mv /tmp/regctl /usr/bin/regctl
sudo chmod +x /usr/bin/regctl

touch ~/.check-files/docker
"###,
        ));
    }

    if !Path::new(
        &context
            .system
            .get_home_path(".docker/cli-plugins/docker-compose"),
    )
    .exists()
    {
        let compose_arch = if context.system.is_arm() {
            "aarch64"
        } else {
            "x86_64"
        };
        let compose_os = if context.system.is_mac() {
            "darwin"
        } else {
            "linux"
        };

        System::run_bash_command(&format!(
            r###"
wget "https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-{compose_os}-{compose_arch}" \
    -O "$HOME"/.docker/cli-plugins/docker-compose
sudo chmod +x "$HOME"/.docker/cli-plugins/docker-compose
"###
        ));
    }

    if Config::has_config_file(&context.system, ".config/docker-buildx") {
        if !Path::new(
            &context
                .system
                .get_home_path(".docker/cli-plugins/docker-buildx"),
        )
        .exists()
        {
            let buildx_arch = if context.system.is_arm() {
                "arm64"
            } else {
                "amd64"
            };
            let buildx_os = if context.system.is_mac() {
                "darwin"
            } else {
                "linux"
            };

            System::run_bash_command(&format!(
                r###"
wget "https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.{buildx_os}-{buildx_arch}" \
    -O ~/.docker/cli-plugins/docker-buildx
sudo chmod +x ~/.docker/cli-plugins/docker-buildx
"###
            ));
        }

        if !Path::new(&context.system.get_home_path(".check-files/docker-buildx")).exists() {
            System::run_bash_command(
                r###"
docker run --privileged --rm tonistiigi/binfmt --install all
touch ~/.check-files/docker-buildx
"###,
            );
        }

        context.files.appendln(
            &context.system.get_home_path(".shellrc"),
            "export DOCKER_BUILDKIT=1",
        );

        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
alias DockerBuildXInstall='docker run --privileged --rm tonistiigi/binfmt --install all'
# Just run once, for allowing the `--push` flag on `docker buildx build`
alias DockerBuildXDriver='docker buildx create --use --name build --node build --driver-opt network=host'
"###
        );
    }
}
