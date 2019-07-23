; With `Windows + Z` open two instances of Notepad, one minimized and one maximized
#z::
Run, Notepad, , max
Run, Notepad, , min
return

; With `Windows + Z` open a specific program (Sublime Text in this case), wait two seconds before
#z::
sleep, 2000
Run, "C:\Program Files\Sublime Text 3\sublime_text.exe", , max
return

; Close Chrome process (check in `tasklist`)
Process, Close, chrome.exe

; Launch a AHK on startup
; https://stackoverflow.com/a/41730695/3244654
