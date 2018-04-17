#!/usr/bin/env bash

FIND_CMD='find . -type f ! -path "*.git*" ! -path "*node_modules*" | fzf --height 100% --border -m  --ansi'

if [ $# -eq 0 ]; then
  CONTENT_FILE=$(eval "$FIND_CMD")
  ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  echo "$ABSOLUTE_PATH "'`# _ to search again`'" $CONTENT_FILE"
  exit 0
else
  if [ $1 == '_' ]; then
    CONTENT_FILE=$(eval "$FIND_CMD")
  else
    CONTENT_FILE="$1"
  fi
fi

if [ -z "$TOOLBOX_SCRIPTS_GRAMMARLY_FILE" ]; then
  GENERATED_FILE="/tmp/grammarly.html"
else
  GENERATED_FILE="$TOOLBOX_SCRIPTS_GRAMMARLY_FILE"
fi

cat > "$GENERATED_FILE" <<"EOF"
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width" />
        <title>Grammarly</title>
    /head>
    <body>
        <textarea style="height: 500px; width: 100%; font-size: 20px";>
EOF
cat "$CONTENT_FILE" >> "$GENERATED_FILE"
cat >> "$GENERATED_FILE" <<"EOF"
        </textarea>
    </body>
</html>
EOF

echo "generated $GENERATED_FILE using $CONTENT_FILE"
