# Windows Brightness Control
A simple yet powerful AutoHotkey-based utility for controlling screen brightness and Windows Night Light settings with automatic time-based adjustments.
Features

Keyboard brightness control - Easily adjust screen brightness with hotkeys
Night Light management - Toggle Windows Night Light mode on/off and adjust intensity
Time-based automatic adjustments - Different brightness levels and Night Light settings based on time of day
Customizable settings - Adjust all parameters through a simple settings menu
Visual feedback - On-screen display shows brightness level when adjusting

Requirements

Windows 10 or 11
AutoHotkey v1.1 or later installed

Installation

Clone this repository or download the zip file
Make sure AutoHotkey is installed on your system
Double-click the BrightnessControl.ahk file to run it
For automatic startup, create a shortcut to the script in your startup folder (shell:startup)

Usage
Hotkeys
HotkeyFunctionCtrl+Alt+UpIncrease brightness by 5%Ctrl+Alt+DownDecrease brightness by 5%Ctrl+Alt+NToggle night light on/offCtrl+Alt+AAuto mode (adjust based on time of day)Ctrl+Alt+SOpen settings menu
Automatic Mode
The script automatically adjusts settings based on the time of day:

Day (7AM-5PM): High brightness (80%), Night Light off
Evening (5PM-9PM): Medium brightness (50%), moderate Night Light
Night (9PM-7AM): Low brightness (30%), stronger Night Light

You can customize these settings through the settings menu (Ctrl+Alt+S).
How It Works
This utility uses:

PowerShell commands via AutoHotkey to control monitor brightness
Windows Registry modifications to control the Night Light feature
AutoHotkey's GUI capabilities for the settings interface

Customization
To modify default settings, open the script in a text editor and adjust the variables in the CONFIGURATION SECTION at the top:
autohotkey; Default brightness levels (0-100)
dayBrightness := 80
eveningBrightness := 50
nightBrightness := 30

; Time thresholds (24-hour format)
morningStart := 7  ; 7:00 AM
eveningStart := 17 ; 5:00 PM
nightStart := 21   ; 9:00 PM

; Night light settings
nightLightIntensity := 65 ; 0-100 scale for registry
Troubleshooting

Brightness control doesn't work: Some monitors or laptop displays may not support WMI brightness control. Try running as Administrator.
Night Light issues: The Night Light feature manipulates Windows registry values and may not work on all Windows versions. Try toggling Night Light manually in Windows settings first.
Script errors: Make sure you're using the correct version of AutoHotkey (v1.1+).

License
This project is licensed under the MIT License - see the LICENSE file for details.
Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

Acknowledgments

AutoHotkey for making Windows automation possible
Windows PowerShell for providing brightness control capabilities
