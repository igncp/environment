use std::path::Path;

use crate::base::{config::Config, system::System, Context};

pub fn setup_docker(context: &mut Context) {
    if Config::has_config_file(&context.system, ".config/docker-skip") {
        return;
    }

    context.system.install_system_package("docker", None);

    context.files.append(&context.system.get_home_path(".shell_aliases"), r###"
alias DockerAttachLastContainer='docker start  `docker ps -q -l`; docker attach `docker ps -q -l`'
alias DockerCleanAll='docker stop $(docker ps -aq); docker rm $(docker ps -aq); docker rmi $(docker images -q)'
alias DockerCleanContainers='docker stop $(docker ps -aq); docker rm $(docker ps -aq)'
alias DockerInfo='docker info | less -S'

DComposeConvertJson(){ docker compose "$@" convert --format json; } # DComposeConvertJson -f ./foo.yml
DComposeTop(){ docker compose "$@" top | less -S; } # DComposeTop -f ./foo.yml
DComposeLogs(){ docker compose "$@" logs -f; } # DComposeLogs -f ./foo.yml
DComposeLogsNew(){ docker compose "$@" logs -f --since 0s; } # DComposeLogsNew -f ./foo.yml
DComposeFullRestart(){
  docker compose "${@: 2}" stop "$1"
  docker compose "${@: 2}" rm "$1" --force
  docker compose "${@: 2}" up "$1" -d --build
}

alias DComposeConfig='docker compose config' # Prints the config after pre-processing
alias DockerCommit='docker commit -m'
alias DockerPruneAll='docker system prune --volumes --all'
alias DockerSystemSpace='docker system df --verbose'

DockerBashExec() { docker exec -it $1 /bin/bash; }
DockerBashRun() { docker run -it $1 /bin/bash; }
DockerHistory() { docker history --no-trunc $1 | less -S; }

# DockerContainerPortainer 9123
DockerContainerPortainer() { docker run --rm -d -p $1:9000 --name portainer \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/misc/portainer_data:/data \
  portainer/portainer-ce:latest; }

# Only AMD for now
alias DockerDive='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest'
"###);

    context.files.appendln(
        &context.system.get_home_path(".vimrc"),
        r#"call add(g:coc_global_extensions, 'coc-yaml')"#,
    );

    context.files.appendln(
        &context.system.get_home_path(".shellrc"),
        r#"export PATH=$PATH:/usr/local/lib/docker/bin"#,
    );

    context.files.appendln(
        &context.system.get_home_path(".shell_sources"),
        r#"source_if_exists ~/.docker-completion.sh"#,
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

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
# AWSDocker -v "$(pwd):/var/foo"
AWSDocker() {
  docker run --rm -it --entrypoint '' \
    -v "$HOME"/.aws/credentials.json:/root/.aws/credentials.json \
    $@ \
    amazon/aws-cli /bin/bash
}
"###,
    );
}
