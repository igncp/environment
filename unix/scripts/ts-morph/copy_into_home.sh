#!/usr/bin/env bash

set -e

rm -rf ~/.ts-morph

rsync -rhv --delete ~/project/scripts/ts-morph/ ~/.ts-morph/

cd ~/.ts-morph

npm i

npm run build

npm run test
