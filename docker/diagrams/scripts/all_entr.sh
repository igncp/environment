#!/usr/bin/env bash

cd /home/ubuntu/scripts

sh dot_entr.sh &
sh mermaid_entr.sh &
sh plantuml_entr.sh &

# This will not end the script till all the rest have ended. If the script is
# stopped, the rest of the parallel scripts will be stopped. More on `man bash`
wait
