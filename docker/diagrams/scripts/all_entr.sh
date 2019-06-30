#!/usr/bin/env bash

sh /home/ubuntu/scripts/dot_entr.sh &
sh /home/ubuntu/scripts/mermaid_entr.sh &

# This will not end the script till all the rest have ended. If the script is
# stopped, the rest of the parallel scripts will be stopped. More on `man bash`
wait
