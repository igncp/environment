#!/usr/bin/env bash

set -euo pipefail

provision_setup_react_native() {
  cat >>~/.shell_aliases <<'EOF'
alias RNExpoDevBuildAndroid='npx expo run:android'
alias RNExpoResetAndroid='(cd android && ./gradlew clean) && npx expo run:android'
EOF
}
