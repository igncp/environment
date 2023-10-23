#!/usr/bin/env bash

GIT_COMMAND='git commit -m '

COMMIT_TYPE=$(printf 'perf\nchore\nci\nbuild\nfeat\nfix' |
  fzf --height 100% --border --ansi)

GIT_MESSAGE_A="'$COMMIT_TYPE($(basename $PWD)): '"
GIT_MESSAGE_B="'$COMMIT_TYPE: '"
GIT_COMMAND="$GIT_COMMAND$GIT_MESSAGE_A"

printf "#!/usr/bin/env bash\n\n" > /tmp/tmp-command.sh
printf "$GIT_COMMAND\n" >> /tmp/tmp-command.sh
printf "#git commit -e -v -m $GIT_MESSAGE_A\n" >> /tmp/tmp-command.sh
printf "#git commit -e -v -m $GIT_MESSAGE_B\n\n" >> /tmp/tmp-command.sh
printf "# You can exit vim by ':cq' and it will block the command execution (not 0 exit code)\n" >> /tmp/tmp-command.sh

echo '"$EDITOR" +3 /tmp/tmp-command.sh && sh /tmp/tmp-command.sh'
