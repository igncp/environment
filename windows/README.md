# Windows Provision

## Change workspace shortcuts

Import `./main.ahk` with AutoHotKey to be able to switch workspaces numerically.

## Sleep shortcut file

Create a shortcut with the following content:

`rundll32.exe powrprof.dll,SetSuspendState 0,1,0`

In order to go to sleep, and not hibernate, hibernation must be disabled. In a
terminal, with admin privileges, run: `powercfg -hibernate off`

## References

- https://www.tutorialspoint.com/batch_script
- https://www.robvanderwoude.com/batchcommands.php
- http://www.trytoprogram.com/batch-file-commands/
- https://www.autohotkey.com/docs/AutoHotkey.htm
