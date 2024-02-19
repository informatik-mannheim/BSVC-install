;--------------------------------
; Includes 

  !include "MUI2.nsh"
  !include "logiclib.nsh"
;--------------------------------
; Custom defines
  !define NAME "BSVC"
  !define APPFILE "bsvc.exe"
  !define VERSION "2.1.0"
  !define SLUG "${NAME} v${VERSION}"
;--------------------------------
; General - Here we configure the general

  Name "${NAME}"
  OutFile "${NAME} Setup.exe"
  InstallDir "$PROGRAMFILES\${NAME}"
  InstallDirRegKey HKCU "Software\${NAME}" ""
  RequestExecutionLevel admin
;--------------------------------
; Pages
  
  ; Installer pages
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "license.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  ; Uninstaller pages
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
  ; Set UI language
  !insertmacro MUI_LANGUAGE "English"
;--------------------------------
; Section - Move BSVC to InstallDir, add Registry Key, and add $INSTDIR to PATH Variable.

  Section "-hidden app"
    SectionIn RO
    SetOutPath "$INSTDIR"
    File /r "app\*.*" 
    WriteRegStr HKLM "Software\${NAME}" "" $INSTDIR
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    EnVar::SetHKLM
    EnVar::AddValue "PATH" $INSTDIR
  SectionEnd
;--------------------------------
; Section - Replace Install Dir in bsvc.tk File

  Section "-hidden TK"
    SectionIn RO
    SetOutPath "$INSTDIR\bsvc-bin\bin"
    File "redist\change-install-dir\change-install-dir.ps1"
    ExecWait "powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File .\change-install-dir.ps1"
  SectionEnd

;--------------------------------
; Section - Use Freewrap to wrap the bsvc.tk into an executable

  Section "-hidden Freewrap"
    SectionIn RO
    SetOutPath "$INSTDIR\"
    File "redist\freewrap\freewrap.exe"
    ExecWait ".\freewrap.exe bsvc-bin\bin\UI\bsvc.tk"
  SectionEnd
;--------------------------------
; Section - Create Desktop Shortcut

  Section "Desktop Shortcut" DeskShort
    CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${APPFILE}"
  SectionEnd

;--------------------------------
; Section - Create Startmenu Entry 

  Section "Startmenu Shortcut" StartShort 
    createDirectory "$SMPROGRAMS\${NAME}"
	  createShortCut "$SMPROGRAMS\${NAME}\${APPFILE}.lnk" "$INSTDIR\${APPFILE}"  
  SectionEnd

;--------------------------------
; Descriptions

  ;Language strings
  LangString DESC_DeskShort ${LANG_ENGLISH} "Create Shortcut on Dekstop."
  ;Language strings
  LangString DESC_StartShort ${LANG_ENGLISH} "Create Startmenu Entry."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${DeskShort} $(DESC_DeskShort)
    !insertmacro MUI_DESCRIPTION_TEXT ${StartShort} $(DESC_StartShort)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
;--------------------------------
; Remove empty parent directories

  Function un.RMDirUP
    !define RMDirUP '!insertmacro RMDirUPCall'

    !macro RMDirUPCall _PATH
          push '${_PATH}'
          Call un.RMDirUP
    !macroend

    ; $0 - current folder
    ClearErrors

    Exch $0
    ;DetailPrint "ASDF - $0\.."
    RMDir "$0\.."

    IfErrors Skip
    ${RMDirUP} "$0\.."
    Skip:

    Pop $0

  FunctionEnd
;--------------------------------
; Section - Uninstaller

Section "Uninstall"

  ;Delete INSTDIR Entry from PATH 
  EnVar::SetHKLM
  EnVar::DeleteValue "PATH" $INSTDIR

  ;Delete Shortcut
  Delete "$DESKTOP\${NAME}.lnk"

  ;Delete Startmenu 
  Delete "$SMPROGRAMS\${NAME}\${APPFILE}.lnk"

  ;Delete Startmenu Folder 
  RMDir "$SMPROGRAMS\${NAME}"

  ;Delete Uninstall
  Delete "$INSTDIR\Uninstall.exe"

  ;Delete Folder
  RMDir /r "$INSTDIR"
  ${RMDirUP} "$INSTDIR"
  
  ;Delete Registry Key
  DeleteRegKey /ifempty HKCU "Software\${NAME}"

SectionEnd