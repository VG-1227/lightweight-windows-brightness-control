#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; ========= CONFIGURATION SECTION =========
; Default brightness levels (0-100)
dayBrightness := 80
eveningBrightness := 50
nightBrightness := 30

; Time thresholds (24-hour format)
morningStart := 7  ; 7:00 AM
eveningStart := 17 ; 5:00 PM
nightStart := 21   ; 9:00 PM

; Night light settings
nightLightIntensity := 65 ; 0-100 scale for registry

; ========= GLOBAL VARIABLES =========
currentBrightness := 0
isNightLightOn := false

; ========= INITIALIZE APPLICATION =========
InitializeApp()

; ========= HOTKEYS =========
; Ctrl+Alt+Up: Increase brightness
^!Up::
    IncreaseBrightness()
    ShowBrightnessOSD()
return

; Ctrl+Alt+Down: Decrease brightness
^!Down::
    DecreaseBrightness()
    ShowBrightnessOSD()
return

; Ctrl+Alt+N: Toggle night light
^!n::
    ToggleNightLight()
return

; Ctrl+Alt+A: Auto mode (set brightness and night light based on time)
^!a::
    AutoAdjustSettings()
    ShowNotification("Auto mode activated", "Brightness and night light adjusted for current time")
return

; Show settings menu
^!s::
    ShowSettingsMenu()
return

; ========= FUNCTIONS =========
InitializeApp() {
    ; Get current monitor brightness
    currentBrightness := GetCurrentBrightness()
    
    ; Check if night light is on
    isNightLightOn := IsNightLightEnabled()
    
    ; Auto-adjust on startup
    AutoAdjustSettings()
    
    ; Show startup notification
    ShowNotification("Brightness Control Started", "Press Ctrl+Alt+S for settings")
}

IncreaseBrightness() {
    global currentBrightness
    
    if (currentBrightness < 100) {
        currentBrightness += 5
        if (currentBrightness > 100)
            currentBrightness := 100
            
        SetBrightness(currentBrightness)
    }
}

DecreaseBrightness() {
    global currentBrightness
    
    if (currentBrightness > 0) {
        currentBrightness -= 5
        if (currentBrightness < 0)
            currentBrightness := 0
            
        SetBrightness(currentBrightness)
    }
}

GetCurrentBrightness() {
    ; Use PowerShell to get current brightness
    PowerShellCmd := "powershell.exe -Command ""(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightness).CurrentBrightness"""
    RunWait, %ComSpec% /c %PowerShellCmd% > "%A_Temp%\brightness.txt",, Hide
    FileRead, brightness, %A_Temp%\brightness.txt
    FileDelete, %A_Temp%\brightness.txt
    brightness := Trim(brightness)
    
    if brightness is not integer
        brightness := 50  ; Default if we can't get the value
        
    return brightness
}

SetBrightness(level) {
    ; Use PowerShell to set brightness
    PowerShellCmd := "powershell.exe -Command ""(Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1," . level . ")"""
    Run, %ComSpec% /c %PowerShellCmd%,, Hide
}

ToggleNightLight() {
    global isNightLightOn
    
    if (isNightLightOn) {
        DisableNightLight()
        isNightLightOn := false
        ShowNotification("Night Light", "Disabled")
    } else {
        EnableNightLight()
        isNightLightOn := true
        ShowNotification("Night Light", "Enabled")
    }
}

EnableNightLight() {
    global nightLightIntensity
    
    ; Set registry values to enable Night Light
    RegWrite, REG_DWORD, HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.bluelightreduction.bluelightreductionstate\windows.data.bluelightreduction.bluelightreductionstate, Data, 43
    
    ; Set night light intensity via registry (this is approximate)
    intensity := 100 - nightLightIntensity  ; Registry uses inverse scale
    RegWrite, REG_DWORD, HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.bluelightreduction.settings\windows.data.bluelightreduction.settings, Data, %intensity%
}

DisableNightLight() {
    ; Set registry values to disable Night Light
    RegWrite, REG_DWORD, HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.bluelightreduction.bluelightreductionstate\windows.data.bluelightreduction.bluelightreductionstate, Data, 21
}

IsNightLightEnabled() {
    ; Check registry to see if night light is on
    RegRead, value, HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\default$windows.data.bluelightreduction.bluelightreductionstate\windows.data.bluelightreduction.bluelightreductionstate, Data
    return (value = 43)
}

AutoAdjustSettings() {
    global dayBrightness, eveningBrightness, nightBrightness
    global morningStart, eveningStart, nightStart
    global nightLightIntensity
    
    ; Get current hour
    FormatTime, currentHour, , H
    currentHour := Floor(currentHour)
    
    ; Adjust brightness and night light based on time
    if (currentHour >= morningStart && currentHour < eveningStart) {
        ; Day time
        SetBrightness(dayBrightness)
        currentBrightness := dayBrightness
        DisableNightLight()
        isNightLightOn := false
    } else if (currentHour >= eveningStart && currentHour < nightStart) {
        ; Evening time
        SetBrightness(eveningBrightness)
        currentBrightness := eveningBrightness
        EnableNightLight()
        isNightLightOn := true
        ; Set moderate intensity
        nightLightIntensity := 40
    } else {
        ; Night time
        SetBrightness(nightBrightness)
        currentBrightness := nightBrightness
        EnableNightLight()
        isNightLightOn := true
        ; Set higher intensity
        nightLightIntensity := 65
    }
}

ShowBrightnessOSD() {
    ; Display brightness level
    Progress, b w200 h30 cw000000 ct00FF00 zn0, Brightness: %currentBrightness%`%
    SetTimer, RemoveOSD, -1000
}

RemoveOSD:
    Progress, Off
return

ShowNotification(title, message) {
    TrayTip, %title%, %message%, 10, 17
}

ShowSettingsMenu() {
    global dayBrightness, eveningBrightness, nightBrightness
    global morningStart, eveningStart, nightStart
    global nightLightIntensity
    
    ; Create simple GUI for settings
    Gui, Settings:New, , Brightness Control Settings
    Gui, Settings:Add, Text, , Day Brightness (7AM-5PM):
    Gui, Settings:Add, Slider, vDayBrightness Range0-100, %dayBrightness%
    
    Gui, Settings:Add, Text, , Evening Brightness (5PM-9PM):
    Gui, Settings:Add, Slider, vEveningBrightness Range0-100, %eveningBrightness%
    
    Gui, Settings:Add, Text, , Night Brightness (9PM-7AM):
    Gui, Settings:Add, Slider, vNightBrightness Range0-100, %nightBrightness%
    
    Gui, Settings:Add, Text, , Night Light Intensity:
    Gui, Settings:Add, Slider, vNightLightIntensity Range0-100, %nightLightIntensity%
    
    Gui, Settings:Add, Button, gSaveSettings, Save Settings
    Gui, Settings:Add, Button, gCancelSettings, Cancel
    
    Gui, Settings:Show
}

SaveSettings:
    Gui, Settings:Submit
    ; Update global variables
    dayBrightness := DayBrightness
    eveningBrightness := EveningBrightness
    nightBrightness := NightBrightness
    nightLightIntensity := NightLightIntensity
    
    ShowNotification("Settings Saved", "New brightness and night light settings applied")
    AutoAdjustSettings()
return

CancelSettings:
    Gui, Settings:Destroy
return

Settings:GuiClose:
    Gui, Settings:Destroy
return
