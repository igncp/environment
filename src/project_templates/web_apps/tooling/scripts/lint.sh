#!/usr/bin/env bash

set -e

./node_modules/.bin/eslint --ext .ts,.tsx,.js .

./node_modules/.bin/prettier --check .

./node_modules/.bin/stylelint "**/*.{css,scss}"

./node_modules/.bin/ts-unused-exports tsconfig.json \
  --excludePathsFromReport='next.config' \
  --excludePathsFromReport='.*/app/.*' \
  --excludePathsFromReport='.*/styleMock' \
  --excludePathsFromReport='playwright.config' \
  --excludePathsFromReport='.*\.next\.*'

echo "Linting complete! 🎉"
