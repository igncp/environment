# https://www.reddit.com/r/NixOS/comments/q71v0e/what_is_the_correct_way_to_setup_pip_with_nix_to/
{pkgs}: let
  pythonPackages = pkgs.python311Packages;

  devPackages = [
    pkgs.poetry
    pkgs.rye
    pkgs.ruff
    pythonPackages.pip
    pythonPackages.python
  ];
in {
  python = pkgs.mkShell {
    packages = devPackages;

    shellHook = ''
      PROJECT_DIR="$HOME/nix-dirs/python-envs/python-base";

      mkdir -p $PROJECT_DIR

      if [ ! -d "$PROJECT_DIR/bin" ]; then
        python -m venv "$PROJECT_DIR"
      fi

      source "$PROJECT_DIR/bin/activate"

      # For matplotlib
      echo 'LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib" python "$@"' > "$PROJECT_DIR/bin/python_cc"
      chmod +x "$PROJECT_DIR/bin/python_cc"

      # This is to expose the venv in PYTHONPATH so that pylint can see venv packages
      export PYTHONPATH="$PROJECT_DIR/${pythonPackages.python.sitePackages}/:\$PYTHONPATH"
      export PATH="$PROJECT_DIR/bin:$PATH"
    '';
  };

  pyenv = pkgs.mkShell {
    packages = with pkgs; [
      bzip2
      gcc13
      gnumake
      libffi
      libgcc
      ncurses
      openssl
      pyenv
      readline
      xz
      zlib
    ];

    shellHook = ''
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/bin:$PATH"

      eval "$(pyenv init -)"
    '';
  };
}
