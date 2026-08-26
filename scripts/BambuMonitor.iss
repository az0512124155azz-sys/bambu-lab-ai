; Bambu AI Monitor - Inno Setup script
; Produces a proper Windows installer: Setup.exe with a wizard,
; Start Menu entry, optional desktop shortcut, and an uninstaller
; listed in "Add or Remove Programs".
;
; To build: install Inno Setup (free) from https://jrsoftware.org/isdl.php
; then open this file in it and click Compile (or run scripts\build_installer.bat).

#define MyAppName "Bambu AI Monitor"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Magic 3D"
#define MyAppExeName "BambuMonitor.exe"

[Setup]
AppId={{B4E1A1E4-6B1D-4C9A-9B7E-BAMBUMONITOR1}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=..\dist_installer
OutputBaseFilename=BambuMonitorSetup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"
Name: "startupicon"; Description: "Start automatically when Windows starts"; GroupDescription: "Startup:"; Flags: unchecked

[Files]
Source: "..\dist\BambuMonitor.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\config.example.yaml"; DestDir: "{app}"; DestName: "config.yaml"; Flags: onlyifdoesntexist

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Edit configuration"; Filename: "{app}\config.yaml"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: startupicon

[Run]
Filename: "{app}\config.yaml"; Description: "Edit your printer and API settings now"; Flags: postinstall shellexec skipifsilent
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: postinstall nowait skipifsilent unchecked
