@echo off
rem ============================================================
rem  7-sign-merged.bat — Sign the merged APK for distribution
rem ============================================================
rem
rem  USAGE: 7-sign-merged.bat
rem
rem  INPUT:  work\merged.apk       (from 6-merge.bat)
rem  OUTPUT: work\ifunny-patched.apk  (final, signed, ready to share)
rem
rem  This is the file to distribute. Recipients must uninstall their
rem  Play Store version of iFunny before installing this APK.
rem ============================================================

call "%~dp0CONFIG.bat"

set INPUT=%WORK%\merged.apk
set OUTPUT=%WORK%\ifunny-patched.apk

if not exist "%INPUT%" (
    echo ERROR: work\merged.apk not found. Run 6-merge.bat first.
    exit /b 1
)
if not exist "%KEYSTORE%" (
    echo ERROR: Keystore not found. Run 2-create-keystore.bat first.
    exit /b 1
)
if not defined APKSIGNER (
    echo ERROR: apksigner not found. Check ANDROID_HOME in CONFIG.bat.
    exit /b 1
)

echo Signing merged APK...
call "%APKSIGNER%" sign ^
  --ks "%KEYSTORE%" --ks-pass pass:%KS_PASS% ^
  --ks-key-alias %KS_ALIAS% --key-pass pass:%KS_PASS% ^
  --out "%OUTPUT%" ^
  "%INPUT%"

if errorlevel 1 (
    echo ERROR: Signing failed.
    exit /b 1
)

echo.
echo ============================================================
echo  DONE: %OUTPUT%
echo ============================================================
echo.
echo SHA256:
powershell -NoProfile -Command "(Get-FileHash '%OUTPUT%' -Algorithm SHA256).Hash"
echo.
echo Share this file. Remind recipients to uninstall iFunny first.
echo Install on connected device:  adb install -r "%OUTPUT%"
