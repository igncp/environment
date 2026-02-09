{pkgs, ...}: {
  config = {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
    };
    services.open-webui.enable = true;
    environment.systemPackages = with pkgs; [
      python3Packages.chromadb
    ];
  };
}
