#!/usr/bin/env bash

set -e

provision_setup_kotlin() {
  cat >>~/.shell_aliases <<"EOF"
if type kotlinc &>/dev/null; then
  alias KotlinScript='kotlinc -script' # e.g. KotlinScript foo.kts
fi
EOF

  if type kotlinc &>/dev/null; then
    cat >>/tmp/expected-vscode-extensions <<"EOF"
fwcd.kotlin
mathiasfrohlich.Kotlin
esafirm.kotlin-formatter
EOF
  fi
}
