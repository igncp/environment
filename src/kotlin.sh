#!/usr/bin/env bash

set -e

provision_setup_kotlin() {
  if [ ! -f "$PROVISION_CONFIG"/kotlin ]; then
    return
  fi

  install_system_package kotlin
  install_nvim_package udalov/kotlin-vim

  cat >>~/.shell_aliases <<"EOF"
alias KotlinScript='kotlinc -script' # e.g. KotlinScript foo.kts
EOF

  cat >>/tmp/expected-vscode-extensions <<"EOF"
fwcd.kotlin
mathiasfrohlich.Kotlin
esafirm.kotlin-formatter
EOF
}
