{
  config,
  lib,
  base-config,
  is-rp5,
  ...
}: let
  has-kodi = builtins.pathExists (base-config + "/kodi");
in
  if has-kodi
  then
    (lib.mkMerge [
      {
        services.xserver = {
          enable = true;
          desktopManager.kodi.enable = true;
          displayManager.lightdm.enable = true;
        };
        # kodi-rpi 將附加元件和 GLSL 著色器安裝在 share/kodi。
        environment.sessionVariables.KODI_HOME = "${config.services.xserver.desktopManager.kodi.package}/share/kodi";
        # 讓 Kodi 的媒體執行緒可以使用即時排程。
        security.rtkit.enable = true;
        services.displayManager.autoLogin = {
          enable = true;
          user = "igncp";
        };
        services.displayManager.defaultSession = "kodi";
        users.users.igncp = {
          extraGroups = ["input" "video" "audio"];
        };
      }
      (lib.mkIf is-rp5 {
        services.xserver = {
          videoDrivers = ["modesetting"];
          # Pi 5 的 V3D 是 card0，HDMI/KMS 顯示控制器是 card1。
          deviceSection = ''
            Option "kmsdev" "/dev/dri/card1"
          '';
        };
        hardware.raspberry-pi.config = {
          all = {
            options = {
              # Enables 4K at 60 Hz output over HDMI for smoother high-resolution playback.
              hdmi_enable_4kp60 = {
                enable = true;
                value = 1;
              };

              # Enables KMS VC4 graphics with 512 MiB contiguous memory, helping 4K video decoding and rendering.
              dt-overlays.vc4-kms-v3d = {
                enable = true;
                params.cma-512.enable = true;
              };
            };

            # 將 USB-C 控制器設為周邊設備的主機模式。
            dt-overlays.dwc2 = {
              enable = true;
              params.dr_mode-host.enable = true;
            };
          };
        };
      })
    ])
  else {}
