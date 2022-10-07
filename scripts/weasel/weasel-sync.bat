@ECHO OFF&PUSHD %~DP0 &TITLE 同步小狼毫输入法(By fxliang)

>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\GetAdmin.vbs"
    "%TEMP%\GetAdmin.vbs"
    DEL /f /q "%TEMP%\GetAdmin.vbs" 2>NUL
    Exit /b
)

:sync
set DataFolder=%cd%\data
ECHO ----------------------------------------------------------------------
ECHO "uninstall"
ECHO 同步数据...
"%cd%\sed.exe" -i "s/installation_id.*/installation_id: \"Win\"/g"  data\installation.yaml
REM "%cd%\WeaselDeployer.exe" /deploy
"%cd%\WeaselDeployer.exe" /sync

ECHO.&ECHO 完成 &TIMEOUT /t 2 >NUL&EXIT
