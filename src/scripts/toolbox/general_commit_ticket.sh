#!/usr/bin/env bash

git add -A .

printf "#!/usr/bin/env bash\n\n" > /tmp/tmp-command.sh
printf "git commit -m ''\n" >> /tmp/tmp-command.sh

printf "# You can exit vim by ':cq' and it will block the command execution (not 0 exit code)\n" >> /tmp/tmp-command.sh
printf "# Press Control+s in INSERT mode to exit\n" >> /tmp/tmp-command.sh

printf '"$EDITOR" -u NONE -c "imap <C-s> <C-c>:x<cr>" -c "call cursor(3,16)" -c "startinsert"' > /tmp/tmp-git-command.sh
printf ' -c "set guicursor="' >> /tmp/tmp-git-command.sh
printf ' /tmp/tmp-command.sh && sh /tmp/tmp-command.sh' >> /tmp/tmp-git-command.sh

echo  'sh /tmp/tmp-git-command.sh'
