#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CapsLock::Send {ctrl down}c{ctrl up}

; Also download: https://github.com/pmb6tz/windows-desktop-switcher

;Switch desktop modification (disable mayus lock)
; Globals
CapsLock::		; CapsLock
+CapsLock::	; Shift+CapsLock
!CapsLock::	; Alt+CapsLock
^CapsLock::		; Ctrl+CapsLock
#CapsLock::		; Win+CapsLock
^!CapsLock::	; Ctrl+Alt+CapsLock
^!#CapsLock::	; Ctrl+Alt+Win+CapsLock
return			; Do nothing, return
