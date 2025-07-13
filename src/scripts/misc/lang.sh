#!/usr/bin/env bash

set -euo pipefail

USAGE='lang [SUBCOMMAND] [OPTIONS]
Subcommands:
  doctor: Checks that all dependencies are present in the current system
    -f: Try to fix issues before displaying result
  filter-chars: Reads from stdin and keeps only chinese characters
  help: Prints help information
  jp: Add jyutping to text
    -u: Do not filter out non-chinese characters
  py: Add pinyin to text
    -u: Do not filter out non-chinese characters
  sub <video-url>: Download subtitles from a youtube video (requires yt-dlp)'

if [ -z "$1" ]; then
  echo "$USAGE"
  exit 1
fi

SUBCOMMAND=$1
shift

if [ "$SUBCOMMAND" = "help" ]; then
  echo "$USAGE"
  exit 0
fi

JYUTPING_DICT_PATH="$HOME/misc/rime-cantonese/jyut6ping3.chars.dict.yaml"
JYUTPING_REPO="https://github.com/rime/rime-cantonese.git"
PINYIN_DICT_PATH="$HOME/misc/rime-terra-pinyin/terra_pinyin.dict.yaml"
PINYIN_REPO="https://github.com/rime/rime-terra-pinyin.git"
REPO_NAME_SED='s|https://github.com/rime/\(.*\).git|\1|'

if [ "$SUBCOMMAND" = "doctor" ]; then
  FIX_ISSUES=false
  while (($#)); do
    case $1 in
    -f)
      FIX_ISSUES=true
      ;;
    esac
    shift
  done

  if [ "$FIX_ISSUES" = "true" ]; then
    mkdir -p ~/misc && cd ~/misc
    if [ ! -f "$JYUTPING_DICT_PATH" ]; then git clone --depth 1 "$JYUTPING_REPO"; fi
    if [ ! -f "$PINYIN_DICT_PATH" ]; then git clone --depth 1 "$PINYIN_REPO"; fi
  fi

  IS_YT_DLP_INSTALLED="$(which yt-dlp)"
  if [ -z "$IS_YT_DLP_INSTALLED" ]; then
    echo "❌ yt-dlp is not installed"
  else
    echo "✅ yt-dlp is installed"
  fi

  if [ ! -f "$JYUTPING_DICT_PATH" ]; then
    echo "❌ the dictionary file does not exist: $JYUTPING_DICT_PATH"
    echo "   - Clone the repo: $JYUTPING_REPO into ~/misc/$(echo "$JYUTPING_REPO" | sed "$REPO_NAME_SED")"
  else
    echo "✅ the jyutping dictionary file exists"
  fi

  if [ ! -f "$PINYIN_DICT_PATH" ]; then
    echo "❌ the dictionary file does not exist: $PINYIN_DICT_PATH"
    echo "   - Clone the repo: $PINYIN_REPO into ~/misc/$(echo "$PINYIN_REPO" | sed "$REPO_NAME_SED")"
  else
    echo "✅ the pinyin dictionary file exists"
  fi

  exit 0
fi

if [ "$SUBCOMMAND" = "sub" ]; then
  VIDEO_URL=$1
  if [ -z "$VIDEO_URL" ]; then
    echo "Please provide a video url"
    exit 1
  fi

  set -x
  (mkdir -p /tmp/subs &&
    cd /tmp/subs &&
    yt-dlp --all-subs --skip-download "$VIDEO_URL" &&
    mv ./*.vtt subs.vtt)
  set +x

  echo "Subtitles downloaded into /tmp/subs/subs.vtt"
  exit 0
fi

filter_text() {
  PIPE_CONTENT="$(cat - 2>/dev/null || true)"
  if [ "$FILTER_TEXT" = "true" ]; then
    # The last `tr` is to avoid a warning: https://stackoverflow.com/a/64551685/3244654
    echo "$PIPE_CONTENT" | grep -oPz '([\x{4e00}-\x{9fa5}\r]|\s)' | tr -d '\0' | grep -v '^\s*$' || true
  else
    echo "$PIPE_CONTENT"
  fi
}

if [ "$SUBCOMMAND" = "filter-chars" ]; then
  filter_text
  exit 0
fi

display_pronunciation() {
  FILTER_TEXT=true
  while (($#)); do
    case $1 in
    -u)
      FILTER_TEXT=false
      ;;
    esac
    shift
  done

  DICT_CONTENT="$(sort -V <"$DICT_PATH" || true)"
  CONTENT=$(FILTER_TEXT=$FILTER_TEXT filter_text)

  declare -A DICT_MAP
  declare -A PERCS_MAP

  LINES="$(echo "$DICT_CONTENT" | grep -P '^.\t' | sed 's|\t| |' | sed 's|\s\+|:|g' | sed 's|%||' || true)"

  if [ ! -f /tmp/$DICT_NAME-cache ]; then
    while IFS= read -r LINE; do
      if [ -z "$LINE" ]; then continue; fi
      IFS=: read -ra FIELDS <<<"$LINE"
      KEY="${FIELDS[0]}" && VALUE="${FIELDS[1]}" && PERC="${FIELDS[2]}"
      if [ -z "$PERC" ]; then PERC="100"; fi
      EXISTING_PERC="${PERCS_MAP[$KEY]}"
      if [ -n "$EXISTING_ITEM" ] && [ "$EXISTING_PERC" -gt "$PERC" ]; then
        continue
      fi
      DICT_MAP[$KEY]="$VALUE"
      PERCS_MAP[$KEY]="$PERC"
    done <<<"$LINES"
    for KEY in "${!DICT_MAP[@]}"; do
      echo "$KEY:${DICT_MAP[$KEY]}" >>"/tmp/$DICT_NAME-cache"
    done
  else
    FILE_CONTENT="$(cat /tmp/$DICT_NAME-cache)"
    while IFS= read -r LINE; do
      if [ -z "$LINE" ]; then continue; fi
      IFS=: read -ra FIELDS <<<"$LINE"
      KEY="${FIELDS[0]}" && VALUE="${FIELDS[1]}"
      DICT_MAP[$KEY]="$VALUE"
    done <<<"$FILE_CONTENT"
  fi

  if [ "$LANG_DEBUG" = "true" ]; then echo "Dictionary loaded" >&2; fi

  FULL_TEXT="" && COUNTER=0
  while IFS='' read -r -d '' -n 1 CHAR; do
    JYUTPING_ITEM="${DICT_MAP[$CHAR]}"
    if [ -z "$JYUTPING_ITEM" ]; then
      FULL_TEXT+="$CHAR"
      continue
    fi
    COUNTER=$((COUNTER + 1))
    FULL_TEXT+="$CHAR""[$JYUTPING_ITEM] "
  done <<<"$CONTENT"

  echo "$FULL_TEXT"
  echo "Total characters: $COUNTER" >&2
}

if [ "$SUBCOMMAND" = "jp" ]; then
  DICT_PATH="$JYUTPING_DICT_PATH" \
    DICT_NAME="jyutping" \
    display_pronunciation "$@"
  exit 0
fi

if [ "$SUBCOMMAND" = "py" ]; then
  DICT_PATH="$PINYIN_DICT_PATH" \
    DICT_NAME="pinyin" \
    display_pronunciation "$@"
  exit 0
fi

echo "$USAGE"
exit 1
