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

NEW_UUID=$(uuidgen)

cat > "$GENERATED_FILE" <<"EOF"
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width" />
        <title>Grammarly</title>
    </head>
    <body>
        <textarea id="textarea" style="height: 500px; width: 100%; font-size: 20px";>
EOF
cat "$CONTENT_FILE" >> "$GENERATED_FILE"
cat >> "$GENERATED_FILE" <<"EOF"
        </textarea>
        <script>
EOF
echo "const uuid = '$NEW_UUID';" >> $GENERATED_FILE
cat >> "$GENERATED_FILE" <<"EOF"
const el = document.getElementById('textarea')

// remove last empty line
const lines = el.value.split('\n')
el.value = lines.slice(0, lines.length - 1).join('\n')

el.addEventListener('keyup', (e) => {
  const value = JSON.stringify(e.target.value)
  localStorage.setItem('grammarly-file', value)
  localStorage.setItem('grammarly-file-uuid', JSON.stringify(uuid))
})

let prevValue = localStorage.getItem('grammarly-file')
let prevUuid = localStorage.getItem('grammarly-file-uuid')

if (prevUuid) prevUuid = JSON.parse(prevUuid);

if (prevValue && prevUuid === uuid) {
  prevValue = JSON.parse(prevValue);

  el.value = prevValue;
  console.log('TEXT MODIFIED')
}
        </script>
    </body>
</html>
EOF

echo "generated $GENERATED_FILE using $CONTENT_FILE"
