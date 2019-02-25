#!/usr/bin/env bash

GIT_COMMAND='git commit -m '

COMMIT_TYPE=$(printf 'perf\nchore\nci\nbuild\nfeat\nfix' |
  fzf --height 100% --border --ansi)

GIT_MESSAGE="'$COMMIT_TYPE($(basename $PWD)): '"
GIT_COMMAND="$GIT_COMMAND$GIT_MESSAGE"

printf "#!/usr/bin/env bash\n\n" > /tmp/tmp-command.sh
printf "$GIT_COMMAND\n" >> /tmp/tmp-command.sh
printf "#git commit -e -v -m $GIT_MESSAGE\n" >> /tmp/tmp-command.sh

# You can exit vim by `:cq` and it will block the command execution (not 0 exit
# code)
echo '"$EDITOR" +3 /tmp/tmp-command.sh && sh /tmp/tmp-command.sh'
