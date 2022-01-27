#!/usr/bin/env bash

if ! type asdf > /dev/null 2>&1 ; then
  echo 'echo ffmpeg missing'
fi

FILE_PATH=$(
  find . -type f -name '*.mp4' |
  fzf --height 100% --border -m --ansi \
    --multi --tac \
    --preview-window right:70%
)

if [ -z "$FILE_PATH" ]; then
  exit
fi

cat > /tmp/create_gif.sh <<"EOF"
ffmpeg \
  -y \
  -ss 2 \
EOF

echo "  -i $FILE_PATH \\" >> /tmp/create_gif.sh

cat >> /tmp/create_gif.sh <<"EOF"
  -t 3 \
  -vf "fps=10,scale=720:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 \
  /tmp/output.gif

# loop : 0 yes, -1 no
# -ss : skip seconds
# -t  : duration
# scale : width:height , -1 means to keep the aspect ration
# exit without run: `:cq`
EOF

echo '"$EDITOR" /tmp/create_gif.sh && sh /tmp/create_gif.sh'
