#!/usr/bin/env bash

echo '
_tmp_fn() {
  EXTRA_IGNORES="$1";
  TREE_OPTS="$2";
  SEQ_NUM="$3";

  for i in `seq 1 $SEQ_NUM`; do
    echo "Level: $i";
    eval "tree $TREE_OPTS -I '"'"'.git|node_modules$EXTRA_IGNORES'"'"'
      -a -C -L $i --noreport";
    printf "\n\n\n\n";
  done
};
_tmp_fn2() {
  _tmp_fn "$@" | less -r;
};
_tmp_fn2 "|foo_BaR" "-d ." 4'
