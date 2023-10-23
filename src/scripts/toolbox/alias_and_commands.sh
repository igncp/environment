#!/usr/bin/env bash

# requires node.js

cat > /tmp/preview.js <<"EOF"
const {exec} = require('child_process')
const {readFileSync} = require('fs')

const {stdin} = process

function getPreview(entry) {
  const aliasContent = readFileSync('/tmp/alias', 'utf8')

  const aliasReg = new RegExp('^alias ' + entry.trim())
  const aliasPreview = aliasContent.split('\n').find(l => l.match(aliasReg))

  if (aliasPreview) {
    return aliasPreview
  }

  const commandsContent = readFileSync('/tmp/commands', 'utf8')
  const commandReg = new RegExp('^' + entry.trim())
  const lines = commandsContent.split('\n')
  const line = lines.find(l => l.match(commandReg))

  if (!line) {
    return 'not found'
  }

  const startIdx = lines.indexOf(line)
  const finalIdx = lines.slice(startIdx, lines.length).reduce((acc, nextLine, nextLineIdx) => {
    if (acc) return acc

    if (nextLine === '}') return nextLineIdx
  }, null)

  return lines.slice(startIdx, finalIdx + startIdx + 1).join('\n')
}

const execute = (command, callback) => {
  exec(command, function(error, stdout, stderr){ callback(stdout); })
}

let ret = ''

stdin.setEncoding('utf8');

stdin.on('readable', () => {
  let chunk;

  while (chunk = stdin.read()) {
    ret += chunk;
  }
});

stdin.on('end', () => {
  const preview = getPreview(ret)

  console.log(preview)
});
EOF

source ~/.shell_aliases > /dev/null 2>&1;
alias > /tmp/alias;
typeset -f > /tmp/commands

ALIASES=$(grep -o "^[^=]*" /tmp/alias | grep -o "[^ ]*$")
CMDS=$(grep -o "^[A-Z].*(" /tmp/commands | grep -o "^[^ ]*")
ALL=$(printf "%s\n%s" "$CMDS" "$ALIASES" | sort -V)

RESULT=$(echo "$ALL" | fzf --height 100% --border -m --ansi \
  --preview 'node /tmp/preview.js <<< {}' --preview-window right:wrap)

[[ -z "$RESULT" ]] && exit 0

echo "$RESULT"

