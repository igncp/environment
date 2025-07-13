#!/usr/bin/env bash

set -euo pipefail

if [ -z "$1" ]; then
  echo 'b ~/development/environment/src/scripts/toolbox/nix_garbage_collector_roots.sh -'
  exit 0
fi

ROOTS=$(nix-store --gc --print-roots 2>&1 | ag -v removing | ag -v censored | awk '{ print $1; }')

echo "$ROOTS" >/tmp/nix-gcroots-environment.txt

node <<"EOF"
const fileContent = require('fs').readFileSync('/tmp/nix-gcroots-environment.txt', 'utf8');

const maxRootsMap = {};

const parseLines = (fn) => {
  fileContent.split('\n').forEach((line) => {
    if (line.length === 0) {
      return;
    }

    const cleanedLine = line.replace(/-link$/, '');
    const baseLine = cleanedLine.replace(/-[0-9]*$/, '');

    if (cleanedLine === baseLine) {
      return;
    }

    const number = parseInt(cleanedLine.replace(baseLine, '').replace('-', ''), 10);

    fn(line, baseLine, number);
  });
}

parseLines((line, baseLine, number) => {
  maxRootsMap[baseLine] = Math.max(maxRootsMap[baseLine] || 0, number);
});

parseLines((line, baseLine, number) => {
  if (!maxRootsMap[baseLine] || maxRootsMap[baseLine] === number) {
    return;
  }

  require('child_process').execSync(`sudo rm -rf ${line}`);
  console.log(`已刪除 ${line}`);
});
EOF
