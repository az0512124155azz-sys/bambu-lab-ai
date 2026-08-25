; Bambu Lab AI Monitor - NSIS Installer
; To build: makensis BambuMonitor.nsi
; Output: BambuMonitor-1.0-installer.exe

!include "MUI2.nsh"
!include "x64.nsh"

; Basic settings
Name "Bambu Lab AI Monitor v1.0"
OutFile "BambuMonitor-1.0-installer.exe"
InstallDir "$PROGRAMFILES\BambuLabAI"
InstallDirRegKey HKCU "Software\BambuLabAI" "InstallDir"

; Require admin rights
RequestExecutionLevel admin

; UI
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

; Installer sections
Section "Install"
    SetOutPath "$INSTDIR"
    
    ; Copy files
    File /r "backend\*.*"
    File "*.bat"
    File "*.md"
    
    ; Create config from example
    ${If} ${FileExists} "$INSTDIR\config.example.yaml"
        ${IfNot} ${FileExists} "$INSTDIR\config.yaml"
            CopyFiles "$INSTDIR\config.example.yaml" "$INSTDIR\config.yaml"
        ${EndIf}
    ${EndIf}
    
    ; Store installation folder
    WriteRegStr HKCU "Software\BambuLabAI" "InstallDir" "$INSTDIR"
    
    ; Create Start Menu shortcuts
    CreateDirectory "$SMPROGRAMS\Bambu Lab AI"
    CreateShortcut "$SMPROGRAMS\Bambu Lab AI\Configure Monitor.lnk" "$INSTDIR\install_windows.bat"
    CreateShortcut "$SMPROGRAMS\Bambu Lab AI\Start Monitor.lnk" "$INSTDIR\run_windows.bat"
    CreateShortcut "$SMPROGRAMS\Bambu Lab AI\Uninstall.lnk" "$INSTDIR\uninstall.exe"
    
    ; Create Desktop shortcut
    CreateShortcut "$DESKTOP\Bambu Lab Monitor.lnk" "$INSTDIR\run_windows.bat"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    ; Add to Programs and Features
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuLabAI" "DisplayName" "Bambu Lab AI Monitor"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuLabAI" "UninstallString" "$INSTDIR\uninstall.exe"
SectionEnd

; Uninstaller
Section "Uninstall"
    ; Remove shortcuts
    RMDir /r "$SMPROGRAMS\Bambu Lab AI"
    Delete "$DESKTOP\Bambu Lab Monitor.lnk"
    
    ; Remove files (keep config.yaml for user)
    RMDir /r "$INSTDIR\venv"
    Delete "$INSTDIR\*.bat"
    Delete "$INSTDIR\*.py"
    Delete "$INSTDIR\*.txt"
    
    ; Remove registry
    DeleteRegKey HKCU "Software\BambuLabAI"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuLabAI"
    
    RMDir "$INSTDIR"
SectionEnd
