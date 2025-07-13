#!/usr/bin/env bash

set -euo pipefail

provision_setup_general_diagrams() {
  if [ ! -f "$PROVISION_CONFIG"/diagrams ]; then
    return
  fi

  # https://plantuml.com/
  # Styling: https://plantuml.com/creole
  install_system_package "plantuml"

  cat >>~/.shell_aliases <<"EOF"
alias PlantUMLHelp='java -jar /usr/share/java/plantuml/plantuml.jar -help'
alias PlantUMLSVG='java -jar /usr/share/java/plantuml/plantuml.jar -darkmode -v -tsvg'
EOF
}
