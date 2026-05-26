@echo off
rem ============================================================
rem  CONFIG.bat — Edit this file once before running any script
rem ============================================================
rem
rem  USAGE: This file is called by the numbered scripts automatically.
rem         Do not run it directly.
rem
rem  HOW TO SET UP:
rem    1. Download morphe-cli-*.jar from:
rem       https://github.com/MorpheApp/morphe-cli/releases
rem    2. Build patches bundle (gradlew :patches:build) or download
rem       patches-*.mpp from the release page.
rem    3. Download APKEditor-*.jar from:
rem       https://github.com/REAndroid/APKEditor/releases
rem    4. Fill in the paths below.
rem ============================================================

rem --- Tool paths (required) ---
set MORPHE_CLI=C:\path\to\morphe-cli-1.8.1-all.jar
set PATCHES_MPP=C:\path\to\patches-1.29.0.mpp
set APKEDITOR=C:\path\to\APKEditor.jar

rem --- Keystore (created by 2-create-keystore.bat) ---
set KEYSTORE=%~dp0morphe.p12
set KS_PASS=morphe123
set KS_ALIAS=morphe

rem --- Android SDK (auto-detected from ANDROID_HOME if set) ---
if not defined ANDROID_HOME set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk

rem --- Auto-detect latest build-tools (do not edit) ---
set APKSIGNER=
for /f %%D in ('dir /b /o-n "%ANDROID_HOME%\build-tools" 2^>nul') do (
    if not defined APKSIGNER set APKSIGNER=%ANDROID_HOME%\build-tools\%%D\apksigner.bat
)

rem --- Working directory for all intermediate files ---
set WORK=%~dp0work
