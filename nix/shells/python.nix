# https://www.reddit.com/r/NixOS/comments/q71v0e/what_is_the_correct_way_to_setup_pip_with_nix_to/
{pkgs}: let
  venvDir = "./.python-env";
  pythonPackages = pkgs.python311Packages;

  devPackages = [
    pkgs.poetry
    pkgs.rye
    pythonPackages.pip
    pythonPackages.python
  ];
in {
  python-base = pkgs.mkShell {
    packages = devPackages;
  };
  python-env = pkgs.mkShell {
    inherit venvDir;
    packages =
      devPackages
      // pythonPackages.venvShellHook;

    # **Important**: This shell creates a `.python-env` directory
    postShellHook = ''
      # This is to expose the venv in PYTHONPATH so that pylint can see venv packages
      PYTHONPATH="\$PWD/${venvDir}/${pythonPackages.python.sitePackages}/:\$PYTHONPATH"
      PATH="\$PWD/${venvDir}/bin:$PATH"
    '';
  };
}
