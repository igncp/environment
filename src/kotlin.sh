#!/usr/bin/env bash

set -euo pipefail

# 多平台配置: https://www.jetbrains.com/help/kotlin-multiplatform-dev/compose-multiplatform-create-first-app.html#next-step

provision_setup_kotlin() {
  cat >>~/.shell_aliases <<"EOF"
if type kotlinc &>/dev/null; then
  alias KotlinJar='kotlinc -include-runtime -d result.jar' # e.g. KotlinJar foo.kt
  alias KotlinScript='kotlinc -script' # e.g. KotlinScript foo.kts
fi
EOF

  if type kotlinc &>/dev/null; then
    add_vscode_extension fwcd.kotlin
    add_vscode_extension mathiasfrohlich.kotlin
    add_vscode_extension esafirm.kotlin-formatter
  fi
}
