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
        <link rel="icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACYAAAAqCAYAAADf/ynVAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAJkSURBVFhH7Ze/axRBFMc3ORPjQeIJBowWIQbUiDZBSBMsBVs1XKGlYOMRKy1ExVIQEkgqkyoBG4mNhfkPLEQLQxQEDRYignCnkTMXPNc87ztxZ3d+vDckW92n2e+DOfaz7w17s1GbNrtMB65BLA9evDRWHHiC0siBd7NB9wj6UXXkeowoQiIpEgsVSsMRZIl9OX7tfk9n112UO4JPzivm61LpzXQU7Smg+k/tZAXJydctwUPIGk4xl1Tp7QySH4/k2pbcUeRtOnHNUD1RWUTUKK3OiKQIz/ohXDWsHTN1y3aD+q2FaPPZS1T2da7OpfecUcwktffy2Wjf7QlULXz7yCTIlbOOMo1UiqA16XVK1jPerBhnhBypJN/HbiK1sEkl783umEIqRcTrv5D4aGLVkcorRA2S+f36Iyo5vrGZSHUsHkXI8PPKVFC3pKhxikcZAj2Q9KFyEVOQ3ObSC1RuchUj6nces7rnFAvZtFx8ct6OkdxuCtpgjzJvOdEey7N7mlhho2sZ0UnHwT4kPvRAvQs3UNlRf+SaWN/a1HlEK7Rp428/UMkonBlmd1w0SiJklCG/yYilD2zUoebKJ1QtusvjSH56n+vfMLXTk0hZ2Ocx9a5ZLz/8d1UU75VZXaA1hcF+VKD5B8GN8QRLSI7W6Zcld10S1tGa+Dx89UKxu2cJ5TYh+4WQSBHWUR75MP8UUYNuENcbqPzQR4pLqtpsPEDUsHZMYRppkpCxKWrNxuzQ+znjQq8YMbH/2KlHh8+toNwRTONLwhJT+LrHxSdFiMQUoYIcIUWQWBKfpESmTZv8iKK/G+nY5VmBi1IAAAAASUVORK5CYII=" />
    </head>
    <body>
        <textarea id="textarea" style="height: 500px; width: 100%; font-size: 24px";>
EOF
cat "$CONTENT_FILE" >> "$GENERATED_FILE"
cat >> "$GENERATED_FILE" <<"EOF"
        </textarea>
        <script>
EOF
echo "const uuid = '$NEW_UUID';" >> $GENERATED_FILE
cat >> "$GENERATED_FILE" <<"EOF"
const el = document.getElementById('textarea')

// remove last empty line if multiple
const lines = el.value.split('\n')
if (lines.length > 1) {
  el.value = lines.slice(0, lines.length - 1).join('\n')
}

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
