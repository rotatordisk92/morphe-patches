@echo off
rem ============================================================
rem  5-install-split.bat — Install splits onto a connected device
rem ============================================================
rem
rem  USAGE: 5-install-split.bat
rem
rem  INPUT:  work\signed\base.apk + all work\signed\split_*.apk
rem  EFFECT: Installs iFunny on the connected ADB device
rem
rem  REQUIRES: ADB device connected (enable USB debugging on phone)
rem            Verify with:  adb devices
rem
rem  NOTE: You must uninstall the Play Store version of iFunny first
rem        if this is your first time — Android rejects signature
rem        changes on top of existing installs.
rem        Uninstall:  adb uninstall mobi.ifunny
rem
rem  This step is for development testing only.
rem  For a single shareable APK, skip to 6-merge.bat instead.
rem ============================================================

call "%~dp0CONFIG.bat"
setlocal EnableDelayedExpansion

set SIGNED=%WORK%\signed

if not exist "%SIGNED%\base.apk" (
    echo ERROR: Signed APKs not found. Run 4-sign.bat first.
    exit /b 1
)

adb get-state >nul 2>&1
if errorlevel 1 (
    echo ERROR: No ADB device detected. Connect your phone and enable USB debugging.
    exit /b 1
)

rem Build the install-multiple argument list
set ARGS="%SIGNED%\base.apk"
for %%F in ("%SIGNED%\split_*.apk") do set ARGS=!ARGS! "%%F"

echo Installing...
adb install-multiple %ARGS%

if errorlevel 1 (
    echo.
    echo FAILED. If you see INSTALL_FAILED_UPDATE_INCOMPATIBLE, uninstall first:
    echo   adb uninstall mobi.ifunny
    echo Then run this script again.
    exit /b 1
)

echo.
echo Installed. Launch iFunny on your device.
