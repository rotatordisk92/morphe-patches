@echo off
rem ============================================================
rem  4-sign.bat — Sign patched base APK and all splits
rem ============================================================
rem
rem  USAGE: 4-sign.bat
rem
rem  INPUT:  work\base-patched.apk       (from 3-patch.bat)
rem          work\extracted\split_*.apk  (original splits from XAPK)
rem  OUTPUT: work\signed\base.apk
rem          work\signed\split_*.apk     (one per split)
rem
rem  WHY SIGN SPLITS TOO: Android requires every APK in a split
rem  install to share the same signing certificate. The original
rem  splits are signed by iFunny's cert; we must re-sign them
rem  with our cert before install-multiple will accept them.
rem
rem  NOTE: apksigner verifies alignment before signing. Since
rem  morphe-cli already aligned base-patched.apk, this is safe.
rem  Splits are small config APKs and do not need re-alignment.
rem ============================================================

call "%~dp0CONFIG.bat"
setlocal EnableDelayedExpansion

set SIGNED=%WORK%\signed

if not exist "%WORK%\base-patched.apk" (
    echo ERROR: work\base-patched.apk not found. Run 3-patch.bat first.
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

if exist "%SIGNED%" rmdir /s /q "%SIGNED%"
mkdir "%SIGNED%"

rem --- Sign patched base ---
echo Signing base APK...
call "%APKSIGNER%" sign ^
  --ks "%KEYSTORE%" --ks-pass pass:%KS_PASS% ^
  --ks-key-alias %KS_ALIAS% --key-pass pass:%KS_PASS% ^
  --out "%SIGNED%\base.apk" ^
  "%WORK%\base-patched.apk"
if errorlevel 1 ( echo ERROR: Failed to sign base APK. & exit /b 1 )

rem --- Sign all splits ---
for %%F in ("%WORK%\extracted\split_*.apk") do (
    echo Signing %%~nxF...
    copy /y "%%F" "%SIGNED%\%%~nxF" >nul
    call "%APKSIGNER%" sign ^
      --ks "%KEYSTORE%" --ks-pass pass:%KS_PASS% ^
      --ks-key-alias %KS_ALIAS% --key-pass pass:%KS_PASS% ^
      "%SIGNED%\%%~nxF"
    if errorlevel 1 ( echo ERROR: Failed to sign %%~nxF. & exit /b 1 )
)

echo.
echo Signed APKs in %SIGNED%:
dir "%SIGNED%\*.apk" /b
echo.
echo To test on device:  run 5-install-split.bat
echo To build final APK: run 6-merge.bat
