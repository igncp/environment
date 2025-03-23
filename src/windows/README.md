# Windows Provision

## 初始設定

1. 安裝: Terminal, Git shell (新增個人資料 to Terminal, 不要使用內建的 ssh 伺服器)
2. 複製此 environment git 儲存庫
3. 運行這個 shell 命令: `bash src/windows.sh`
4. 安裝 Rust: https://www.rust-lang.org/tools/install
5. 設定 ssh 剪貼簿命令
6. 編輯檔案.ssh/config
7: 使用此腳本配置中文 IME: [./installation.sh](./installation.sh)

## Sleep shortcut file

Create a shortcut with the following content:

`rundll32.exe powrprof.dll,SetSuspendState 0,1,0`

In order to go to sleep, and not hibernate, hibernation must be disabled. In a
terminal, with admin privileges, run: `powercfg -hibernate off`

## Windows Terminal

- To change the cursor's color, can change the settings.json file for the used theme (e.g. Campbell): `"cursorColor": "#C20064",`
    - Can also change it directly in the UI by clicking the theme, which opens a window listing the colors
- To be able to run Sublime Text, add it to the `Path` environment variable:
    - Search in settings for "Environment Variables"
    - Update the user's one with the path (e.g. `C:\Program Files\Sublime Text`)
    - Close the whole Windows Terminal program and open again
    - To confirm, run: `echo $Env:Path`
- Edit the `hosts` file: Run alias `HostsEdit`
- Change the Word Delimeter option characters ` ()[]{}"'` (it includes an space at the beginning)
    - This is under "Interactions" in settings
- 若要停用鈴聲：
    - 前往設定、個人資料、進階並更改鈴聲行為

## 有用的鍵盤快捷鍵

- https://support.microsoft.com/en-us/windows/keyboard-shortcuts-in-windows-dcc61a57-8ff0-cffe-9796-cb9706c75eec

- Alt + space: Open the window menu (useful for maximized terminal)
- LWin + Shift + s: Take screenshot with the snipping tool
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

- 截圖: Snipping tool (LWin + Shift + S)
- Clipboard setup:
    - Create a shortcut file, and in the shortcut file properties
        - In the target add: `"C:\Program Files\Git\bin\sh.exe" --login -c "/c/Users/Ignacio/development/environment/project/clipboard_ssh host"`
        - Update the icon (can find many in `shell32.dll`)
        - Change to be opened minimized
    - 按 Windows 鍵 + R 並輸入“shell:startup”
        - 將快捷方式檔案複製到該目錄下
    - 將快捷方式檔案也複製到工作列

## References

- https://www.tutorialspoint.com/batch_script
- https://www.robvanderwoude.com/batchcommands.php
- http://www.trytoprogram.com/batch-file-commands/
- https://www.autohotkey.com/docs/AutoHotkey.htm

## 有用的連結

- PowerToys: https://learn.microsoft.com/en-us/windows/powertoys/#current-powertoy-utilities
- Git: https://git-scm.com/downloads
- VS Code Insiders: https://code.visualstudio.com/insiders/
- VS Code: https://code.visualstudio.com/download
