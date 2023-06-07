# Windows Provision

- PowerToys: https://learn.microsoft.com/en-us/windows/powertoys/#current-powertoy-utilities

## Change workspace shortcuts

Import `./switch-desktop.ahk` with AutoHotKey to be able to switch workspaces numerically.

## Sleep shortcut file

Create a shortcut with the following content:

`rundll32.exe powrprof.dll,SetSuspendState 0,1,0`

In order to go to sleep, and not hibernate, hibernation must be disabled. In a
terminal, with admin privileges, run: `powercfg -hibernate off`

## Windows Terminal

- To change the cursor's color, can change the settings.json file for the used theme (e.g. Campbell): `"cursorColor": "#C20064",`
- To be able to run Sublime Text, add it to the `Path` environment variable:
    - Search in settings for "Environment Variables"
    - Update the user's one with the path (e.g. `C:\Program Files\Sublime Text`)
    - Close the whole Windows Terminal program and open again
    - To confirm, run: `echo $Env:Path`
- Edit the `hosts` file:
    - Open an admin shell: `Start-Process powershell -Verb runAs`
    - Open the file: `subl.exe C:\Windows\System32\Drivers\etc\hosts`

## Useful keyboard shortcuts

- https://support.microsoft.com/en-us/windows/keyboard-shortcuts-in-windows-dcc61a57-8ff0-cffe-9796-cb9706c75eec

- Alt + space: Open the window menu (useful for maximized terminal)
- LWin + d: Display desktop
- LWin + e: Open files on the home dir
- LWin + i: Open settings
- LWin + l: Lock the PC
- LWin + tab: Open the Task View (virtual desktops), where can drag programs to other desktops
- LWin + v: Built-in clipboard manager
- Long press of "ImprPa": Take screenshot of area
- Shift + left click in explorer: Additional options like copy file path to clipboard

### Windows Terminal

- Control + Shift + w: Close window (e.g. for settings)
- Control + Shift + p: Command paletter

## References

- https://www.tutorialspoint.com/batch_script
- https://www.robvanderwoude.com/batchcommands.php
- http://www.trytoprogram.com/batch-file-commands/
- https://www.autohotkey.com/docs/AutoHotkey.htm
