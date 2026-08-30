{base-config, ...}: let
  has-blocky = builtins.pathExists (base-config + "/blocky");
in
  if has-blocky
  then {
    services.blocky = {
      enable = true;
      settings = {
        ports.dns = 53;
        upstreams.groups.default = [
          "https://one.one.one.one/dns-query"
        ];
        blocking = {
          denylists = {
            ads = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/wildcard/pro.txt"
            ];
          };
          clientGroupsBlock = {
            default = [
              "ads"
            ];
          };
        };
      };
    };

    networking.firewall.allowedUDPPorts = [53];
    networking.firewall.allowedTCPPorts = [53];

    # # 加入 /etc/nixos/configuration.nix
    # services.blocky.settings.customDNS.mapping = {
    #   "nas.lan" = "192.168.10.10";
    # };
  }
  else {}
