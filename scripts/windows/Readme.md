# Windows host utilities

## Change workspace shortcuts

Import `./main.ahk` with AutoHotKey to be able to switch workspaces numerically.

## Sleep shortcut file

Create a shortcut with the following content: `rundll32.exe powrprof.dll,SetSuspendState 0,1,0`. In order to go to sleep, and not hibernate, hibernation must be disabled. In a terminal, with admin privileges, run: `powercfg -hibernate off`
