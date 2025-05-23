!include MUI2.nsh
!include "WordFunc.nsh"
!insertmacro VersionCompare

!define SOFTWARE_NAME "KinshipDiagram"
!define SOFTWARE_VERSION "0.16.3"
!define SOFTWARE_PUBLISHER "Easy Wang"
!define SOFTWARE_PATH "D:\RelativeSpectrumTemp\KinshipDiagramInstaller\packages\package1\data\"
!define SOFTWARE_EXE "KinshipDiagramApp.exe"
!define SOFTWARE_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SOFTWARE_NAME}"

; 64bit default key: HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Kinship Diagram
; 64bit default uninstall key: HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\KinshipDiagram


; 基本配置
Name "Kinship Diagram"
OutFile "KinshipDiagramInstaller.exe"
RequestExecutionLevel admin ; 需要管理员权限写注册表
InstallDir "$PROGRAMFILES64\${SOFTWARE_NAME}" ; 默认安装路径

; 图标配置
!define MUI_ICON "${SOFTWARE_PATH}\Logo.ico"
!define MUI_UNICON "${SOFTWARE_PATH}\Logo.ico"

; 页面配置
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\${SOFTWARE_EXE}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"

Var ExistingVersion
Var ExistingInstallDir

Function .onInit
    ; 检查注册表项
    ReadRegStr $ExistingInstallDir HKLM "SOFTWARE\${SOFTWARE_NAME}" "InstallDir"
    ReadRegStr $ExistingVersion HKLM "SOFTWARE\${SOFTWARE_NAME}" "Version"

    ${If} $ExistingVersion != ""
        ${VersionCompare} $ExistingVersion ${SOFTWARE_VERSION} $R0
        ; "0" =, "1" >, "2" <
        ${If} $R0 != "2"
            MessageBox MB_OK|MB_ICONEXCLAMATION "已安装相同或更高版本 ($ExistingVersion >= ${SOFTWARE_VERSION})，退出安装！"
            Quit
        ${EndIf}
    ${EndIf}
    
    ${If} $ExistingInstallDir != ""
        StrCpy $INSTDIR $ExistingInstallDir
    ${EndIf}
FunctionEnd

Section "主程序" SEC_MAIN
    ; 版本比较逻辑
    ; 全新安装
    SetOverwrite on
    SetOutPath $INSTDIR
    File /r "${SOFTWARE_PATH}\*.*"
    
    ; 写入注册表
    WriteRegStr HKLM "SOFTWARE\${SOFTWARE_NAME}" "InstallDir" "$INSTDIR"
    WriteRegStr HKLM "SOFTWARE\${SOFTWARE_NAME}" "Version" "${SOFTWARE_VERSION}"
    
    ; 创建卸载程序
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "${SOFTWARE_UNINST_KEY}" "DisplayIcon" "$INSTDIR\Logo.ico"
    WriteRegStr HKLM "${SOFTWARE_UNINST_KEY}" "DisplayName" "$(^Name)"
    WriteRegStr HKLM "${SOFTWARE_UNINST_KEY}" "DisplayVersion" "${SOFTWARE_VERSION}"
    WriteRegStr HKLM "${SOFTWARE_UNINST_KEY}" "Publisher" "${SOFTWARE_PUBLISHER}"
    WriteRegStr HKLM "${SOFTWARE_UNINST_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"

SectionEnd

Section "桌面快捷方式" SEC_DESKTOP
    CreateShortcut "$DESKTOP\$(^Name).lnk" "$INSTDIR\${SOFTWARE_EXE}" "" "$INSTDIR\Logo.ico"
SectionEnd

Section "开始菜单快捷方式" SEC_STARTMENU
    CreateDirectory "$SMPROGRAMS\$(^Name)"
    CreateShortcut "$SMPROGRAMS\$(^Name)\$(^Name).lnk" "$INSTDIR\${SOFTWARE_EXE}" "" "$INSTDIR\Logo.ico"
SectionEnd

; 卸载程序
Section "Uninstall"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir /r "$INSTDIR"
    
    DeleteRegKey HKLM "SOFTWARE\${SOFTWARE_NAME}"
    DeleteRegKey HKLM "${SOFTWARE_UNINST_KEY}"
    
    Delete "$DESKTOP\$(^Name).lnk"
    RMDir /r "$SMPROGRAMS\$(^Name)"
SectionEnd

Function .onSelChange
    ; 设置默认选中状态
    ${If} ${SectionIsSelected} ${SEC_DESKTOP}
    ${Else}
        !insertmacro SelectSection ${SEC_DESKTOP}
    ${EndIf}
    
    ${If} ${SectionIsSelected} ${SEC_STARTMENU}
    ${Else}
        !insertmacro SelectSection ${SEC_STARTMENU}
    ${EndIf}
FunctionEnd