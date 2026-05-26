@echo off
rem ============================================================
rem  6-merge.bat — Merge signed splits into a single universal APK
rem ============================================================
rem
rem  USAGE: 6-merge.bat
rem
rem  INPUT:  work\signed\  (all signed APKs from 4-sign.bat)
rem  OUTPUT: work\merged.apk  (unsigned — signature invalidated by merge)
rem
rem  WHY MERGE: A single APK is easier to share. Recipients do not
rem  need to deal with adb install-multiple; they just sideload one file.
rem
rem  WHY RE-SIGN AFTER: APKEditor rewrites the ZIP structure when merging,
rem  which invalidates any existing signature. The output is unsigned.
rem  Run 7-sign-merged.bat immediately after this step.
rem ============================================================

call "%~dp0CONFIG.bat"

set SIGNED=%WORK%\signed
set OUTPUT=%WORK%\merged.apk

if not exist "%SIGNED%\base.apk" (
    echo ERROR: Signed APKs not found. Run 4-sign.bat first.
    exit /b 1
)
if not exist "%APKEDITOR%" (
    echo ERROR: APKEditor JAR not found: %APKEDITOR%
    echo Edit APKEDITOR in CONFIG.bat.
    echo Download from: https://github.com/REAndroid/APKEditor/releases
    exit /b 1
)

if exist "%OUTPUT%" del /f /q "%OUTPUT%"

echo Merging splits into single APK...
java -jar "%APKEDITOR%" m -i "%SIGNED%" -o "%OUTPUT%" -f

if errorlevel 1 (
    echo ERROR: APKEditor merge failed.
    exit /b 1
)

echo.
echo Output: %OUTPUT%  (unsigned — must re-sign before installing)
echo Proceed to 7-sign-merged.bat.
