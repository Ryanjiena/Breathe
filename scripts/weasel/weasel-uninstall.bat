@ECHO OFF&PUSHD %~DP0 &TITLE 卸载小狼毫输入法(By fxliang)

>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\GetAdmin.vbs"
    "%TEMP%\GetAdmin.vbs"
    DEL /f /q "%TEMP%\GetAdmin.vbs" 2>NUL
    Exit /b
)

:uninstall
set DataFolder=%cd%\data
ECHO ----------------------------------------------------------------------
ECHO "uninstall"
ECHO 同步数据...
REM "%cd%\WeaselDeployer.exe" /sync
ECHO 退出WeaselServer.exe
"%cd%\WeaselServer.exe" /quit
"%cd%\WeaselSetup.exe" /u
REM regsvr32 /s /u weasel.dll
If Exist "%WinDir%\SysWOW64" REM regsvr32 /s /u weaselx64.dll


ECHO 删除注册表项
REG DELETE HKCU\Software\Rime /f
REG DELETE HKLM\Software\Microsoft\Windows\CurrentVersion\Run\ /v WeaselServer /f

ECHO 清除数据目录的临时内容
REM DEL /Q "%DataFolder%\installation.yaml"
REM DEL /Q "%DataFolder%\user.yaml"
REM RD /S /Q "%DataFolder%\build"

ECHO.&ECHO 完成 &TIMEOUT /t 2 >NUL&EXIT
