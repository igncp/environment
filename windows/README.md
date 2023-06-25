# Windows Provision

- PowerToys: https://learn.microsoft.com/en-us/windows/powertoys/#current-powertoy-utilities
- Git: https://git-scm.com/downloads
- VS Code Insiders: https://code.visualstudio.com/insiders/
- VS Code: https://code.visualstudio.com/download

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
- Edit the `hosts` file: Run alias `HostsEdit`

## Useful keyboard shortcuts

- https://support.microsoft.com/en-us/windows/keyboard-shortcuts-in-windows-dcc61a57-8ff0-cffe-9796-cb9706c75eec

- Alt + space: Open the window menu (useful for maximized terminal)
- Control + Shift + s: Take screenshot with the snipping tool
- LWin + d: Display desktop
- LWin + Ctrl + n: (n is the position of the app in the bottom bar) switch windows of the same application
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
- Powershell History: subl.exe ~\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine

### VNC

- When logging into a Mac: AltL = Cmd
- To move to host (by minifying): F8 + n

## Misc

- Take a screenshot: Snipping tool
- Open the explorer inside the current location: `explorer.exe .`

### VNC

- When logging into a Mac: AltL = Cmd
- To move to host (by minifying): F8 + n

### VS Code

Shortcuts:

- Alt + Shift + r (with the tree bar opened): Open file in explorer
- Control + .: Show code action
- Control + /: Toggle comment
- Control + 1: When in the terminal, focus first tab
- Control + Alt + l: Open GitHub Copilot chat
- Control + b: Toggle sidebar
- Control + Shift + e: Open tree bar
- Control + Shift + x: Open the extensions tab
- F12: Go to definition
- F8: Go to the next error
- gh: Show hover

## Misc

- Take a screenshot: Snipping tool

### VNC

- When logging into a Mac: AltL = Cmd
- To move to host (by minifying): F8 + n

### VS Code

- Control + .: Show code action
- Control + /: Toggle comment
- Control + b: Toggle sidebar
- F12: Go to definition
- F8: Go to the next error

## Misc

- Take a screenshot: Snipping tool
- Clipboard setup:
    - Create a shortcut file, and in the shortcut file properties
        - Add: `"C:\Program Files\Git\bin\sh.exe" --login -c "/c/Users/Ignacio/development/environment/project/target/release/clipboard_ssh host"`
        - Update the icon (can find many in `shell32.dll`)
        - Change to be opened minimized
    - Move it to the taskbar

## References

- https://www.tutorialspoint.com/batch_script
- https://www.robvanderwoude.com/batchcommands.php
- http://www.trytoprogram.com/batch-file-commands/
- https://www.autohotkey.com/docs/AutoHotkey.htm
