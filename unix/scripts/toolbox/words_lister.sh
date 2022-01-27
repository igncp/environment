#!/usr/bin/env bash

DIR=$(find . -type d ! -path "*.git*" ! -path "*node_modules*" | \
  fzf --height 100% --border -m  --ansi --header 'This can be memory intensive if the dir has many big files')


if [ -z "$DIR" ]; then
  exit 0;
fi

cat > /tmp/lister-options <<"EOF"
| grep -vP "^..?.?$"
| grep "^[A-Z]"
| grep "[A-Z]"
| grep "[^0-9]"
EOF

OPTIONS=$(fzf -m --header 'Choose the options you want' < /tmp/lister-options)

echo '
__tmp_fn() {
  DIR=$1;
  echo "$(find "$DIR" -type f | xargs cat | sed "s|[,.():'"'"'=;{}, ]|\n|g" | grep "^[A-Za-z0-9]*$" )" '"$OPTIONS"'
    | sort | uniq -c | sort -rn | less;
} && __tmp_fn '"$DIR"
