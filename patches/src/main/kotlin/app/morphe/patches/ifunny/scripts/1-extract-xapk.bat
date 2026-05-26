@echo off
rem ============================================================
rem  1-extract-xapk.bat — Extract base APK and splits from XAPK
rem ============================================================
rem
rem  USAGE:
rem    1-extract-xapk.bat path\to\ifunny.xapk
rem
rem  INPUT:  An XAPK file (rename .xapk to .zip to inspect manually)
rem  OUTPUT: work\extracted\  containing base.apk + all split_*.apk files
rem
rem  NOTE: An XAPK is just a ZIP. The base APK is the largest file inside
rem        (usually mobi.ifunny.apk). Splits are the smaller config APKs.
rem        This script renames the base to base.apk for consistency.
rem ============================================================

call "%~dp0CONFIG.bat"
setlocal EnableDelayedExpansion

if "%~1"=="" (
    echo USAGE: %~nx0 path\to\ifunny.xapk
    exit /b 1
)
if not exist "%~1" (
    echo ERROR: File not found: %~1
    exit /b 1
)

set XAPK=%~f1
set OUTDIR=%WORK%\extracted

echo Cleaning output dir...
if exist "%OUTDIR%" rmdir /s /q "%OUTDIR%"
mkdir "%OUTDIR%"

echo Extracting XAPK...
powershell -NoProfile -Command ^
  "Copy-Item '%XAPK%' '%WORK%\input.zip' -Force; ^
   Expand-Archive '%WORK%\input.zip' -DestinationPath '%OUTDIR%' -Force; ^
   Remove-Item '%WORK%\input.zip' -Force"

echo.
echo Locating base APK (largest .apk in archive)...
powershell -NoProfile -Command ^
  "$files = Get-ChildItem '%OUTDIR%\*.apk' | Sort-Object Length -Descending; ^
   $base = $files[0]; ^
   if ($base.Name -ne 'base.apk') { ^
     Rename-Item $base.FullName 'base.apk'; ^
     Write-Host ('Renamed ' + $base.Name + ' to base.apk') ^
   } else { Write-Host 'base.apk already correctly named' }"

echo.
echo Contents of %OUTDIR%:
dir "%OUTDIR%\*.apk" /b
echo.
echo Done. Proceed to 3-patch.bat (or 2-create-keystore.bat if first run).
