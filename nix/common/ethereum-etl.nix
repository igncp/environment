{pkgs}: let
  home-dir = builtins.getEnv "HOME";
  project-dir = home-dir + "/nix-dirs/python-envs/environment-ethereum-etl";
  venvDir = project-dir + "/.python-env";
  pythonPackages = pkgs.python39Packages;

  devPackages = [
    pythonPackages.pip
    pythonPackages.python
  ];
in {
  packages =
    devPackages;

  shellHook = ''
    mkdir -p ${project-dir}

    if [ ! -d ${project-dir}/ethereum-etl ]; then
      git clone https://github.com/blockchain-etl/ethereum-etl.git ${project-dir}/ethereum-etl
      (cd ${project-dir}/ethereum-etl && \
        git reset --hard  952a49ba4b53afc9b6e2c73cd42616ac1870d9c6)
    fi

    mkdir -p ${project-dir}/bin/
    mkdir -p ${venvDir}

    if [ ! -d "${venvDir}/bin" ]; then
      python -m venv "${venvDir}"
    fi

    PYTHONPATH="${venvDir}/${pythonPackages.python.sitePackages}/:\$PYTHONPATH"
    PATH="${project-dir}/bin:${venvDir}/bin:$PATH"

    source "${venvDir}/bin/activate"

    if [ ! -f "${venvDir}/bin/ethereumetl" ]; then
      (cd ${project-dir}/ethereum-etl && ${venvDir}/bin/python setup.py install)
    fi
  '';
}
