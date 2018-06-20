#!/usr/bin/env bash

# Usage, from the root directory of the environment repo:
# cat CSV_FILE | other/convert_canto.sh

sed -E 's|^(.),(.*)$|\1 [\2]|' $1 | sort > other/canto.txt
