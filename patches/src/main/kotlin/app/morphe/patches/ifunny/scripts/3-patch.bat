@echo off
rem ============================================================
rem  3-patch.bat — Patch base.apk with morphe-cli
rem ============================================================
rem
rem  USAGE: 3-patch.bat
rem
rem  INPUT:  work\extracted\base.apk  (from 1-extract-xapk.bat)
rem  OUTPUT: work\base-patched.apk    (unsigned, already aligned)
rem
rem  Applies three patches:
rem    - Hide ads        (AdsDisableManagerImpl)
rem    - Unlock premium  (User.isUserPremium)
rem    - Save videos     (SaveContentCriterion)
rem
rem  --unsigned: morphe-cli signing is incompatible with JDK 9+
rem              keystores. Sign separately in 4-sign.bat instead.
rem  --force:    bypasses version check. Remove if your APK version
rem              exactly matches the one declared in Constants.kt.
rem  morphe-cli automatically zipaligns the output before saving.
rem ============================================================

call "%~dp0CONFIG.bat"
setlocal

set INPUT=%WORK%\extracted\base.apk
set OUTPUT=%WORK%\base-patched.apk

if not exist "%INPUT%" (
    echo ERROR: %INPUT% not found. Run 1-extract-xapk.bat first.
    exit /b 1
)
if not exist "%MORPHE_CLI%" (
    echo ERROR: morphe-cli JAR not found: %MORPHE_CLI%
    echo Edit MORPHE_CLI in CONFIG.bat.
    exit /b 1
)
if not exist "%PATCHES_MPP%" (
    echo ERROR: Patches bundle not found: %PATCHES_MPP%
    echo Edit PATCHES_MPP in CONFIG.bat.
    exit /b 1
)

echo Patching %INPUT%...
java -jar "%MORPHE_CLI%" patch ^
  -p "%PATCHES_MPP%" ^
  --exclusive --force --unsigned ^
  -e "Hide ads" ^
  -e "Unlock premium" ^
  -e "Save videos" ^
  -o "%OUTPUT%" ^
  "%INPUT%"

if errorlevel 1 (
    echo ERROR: Patching failed. Check output above.
    exit /b 1
)

echo.
echo Output: %OUTPUT%
echo Proceed to 4-sign.bat.
