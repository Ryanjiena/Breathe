@ECHO OFF&PUSHD %~DP0 &TITLE 重装小狼毫输入法(By fxliang)

>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\GetAdmin.vbs"
    "%TEMP%\GetAdmin.vbs"
    DEL /f /q "%TEMP%\GetAdmin.vbs" 2>NUL
    Exit /b
)

:reinstall
set DataFolder=%cd%\data
ECHO ----------------------------------------------------------------------
ECHO "uninstall"
ECHO 同步数据...
REM "%cd%\WeaselDeployer.exe" /sync
ECHO 退出WeaselServer.exe
"%cd%\WeaselServer.exe" /quit
"%cd%\WeaselSetup.exe" /u

ECHO 删除注册表项
REG DELETE HKCU\Software\Rime /f
REG DELETE HKLM\Software\Microsoft\Windows\CurrentVersion\Run\ /v WeaselServer /f

ECHO 清除数据目录的临时内容
REM DEL /Q "%DataFolder%\installation.yaml"
REM DEL /Q "%DataFolder%\user.yaml"
REM RD /S /Q "%DataFolder%\build"

ECHO ----------------------------------------------------------------------
ECHO "install"
REM -----------------------------------------------
ECHO ----------------------------------------------------------------------
REM 注册表操作
ECHO 注册表操作
ECHO ----------------------------------------------------------------------
REM -----------------------------------------------
REM 设置用户目录
ECHO 设置用户目录
REG ADD HKCU\Software\Rime\Weasel /v RimeUserDir /d "%DataFolder%"

REM 不弹出确认窗口
ECHO 不弹出确认窗口
REG ADD HKCU\Software\Rime\Weasel /v Hant /t REG_DWORD /d 0
REM 不检查软件更新
ECHO 不检查软件更新
REG ADD HKCU\Software\Rime\Weasel\Updates /v CheckForUpdates /d 0

REM -----------------------------------------------
REM 安装小狼毫输入法
ECHO 安装小狼毫输入法中...
"%cd%\WeaselSetup.exe" /i
ECHO 部署小狼毫输入法中...
"%cd%\WeaselDeployer.exe" /install

REM -----------------------------------------------
ECHO ----------------------------------------------------------------------
REM 开机自动启动服务
ECHO 开机自动启动服务
REG ADD HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v WeaselServer /d "%~dp0WeaselServer.exe" /f

REM 打开输入法
REM ECHO 打开输入法
REM start "" "%cd%\WeaselServer.exe"

ECHO.&ECHO 完成 &TIMEOUT /t 2 >NUL&EXIT
