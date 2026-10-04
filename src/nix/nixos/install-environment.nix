{self}: {
  config,
  pkgs,
  ...
}: let
  user = "igncp";
  home-directory = "/home/${user}";
  environment-directory = "${home-directory}/development/environment";
  content = pkgs.runCommand "install-igncp-environment" {} ''
    mkdir -p $out
    cp -r ${self}/src $out/src
  '';
in {
  security.sudo.extraConfig = ''
    #includedir /etc/sudoers.d
  '';

  system.activationScripts.install-environment = {
    # 在其他所有啟用片段之後執行。
    deps = builtins.attrNames (
      builtins.removeAttrs config.system.activationScripts [
        "install-environment"
        "script"
      ]
    );
    text = ''
      if [ -L ${environment-directory} ]; then
        rm ${environment-directory}
      fi
      mkdir -p ${environment-directory}/project
      rm -rf ${environment-directory}/.git
      chown ${user}:users ${environment-directory} ${environment-directory}/project
      rm -rf ${environment-directory}/src
      ln -s ${content}/src ${environment-directory}/src
      cd ${environment-directory}
      (
        sudoers_file=/etc/sudoers.d/install-environment
        ${pkgs.coreutils}/bin/printf '%s\n' '${user} ALL=(ALL:ALL) NOPASSWD: ALL' \
          | ${pkgs.coreutils}/bin/install -Dm440 /dev/stdin "$sudoers_file"
        trap '${pkgs.coreutils}/bin/rm -f "$sudoers_file"' EXIT

        /run/wrappers/bin/sudo -H -u ${user} ${pkgs.coreutils}/bin/env \
          HOME=${home-directory} \
          USER=${user} \
          LOGNAME=${user} \
          PATH="/run/wrappers/bin:$systemConfig/sw/bin:$systemConfig/sw/sbin" \
          ${pkgs.bash}/bin/bash src/main.sh
      )
    '';
  };
}
