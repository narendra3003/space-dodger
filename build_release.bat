@echo off
REM 🚀 Space Dodger - Build and Release Script (Windows)
REM This script automates the process of building and preparing APK releases

setlocal enabledelayedexpansion

echo 🚀 Space Dodger - Build and Release Script
echo ==========================================

REM Check if Flutter is installed
echo [INFO] Checking Flutter installation...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

for /f "tokens=*" %%i in ('flutter --version') do (
    set "flutter_version=%%i"
    goto :found_flutter
)
:found_flutter
echo [SUCCESS] Flutter found: !flutter_version!

REM Setup project
echo [INFO] Setting up project...

echo [INFO] Cleaning project...
flutter clean

echo [INFO] Getting dependencies...
flutter pub get

echo [SUCCESS] Project setup complete

REM Generate app icons
echo [INFO] Generating app icons...
flutter pub run flutter_launcher_icons:main
if errorlevel 1 (
    echo [ERROR] Failed to generate app icons
    exit /b 1
)
echo [SUCCESS] App icons generated successfully

REM Run tests (unless skipped)
if "%3"=="true" (
    echo [WARNING] Skipping tests
) else (
    echo [INFO] Running tests...
    flutter test
    if errorlevel 1 (
        echo [ERROR] Tests failed
        exit /b 1
    )
    echo [SUCCESS] All tests passed
)

REM Analyze code
echo [INFO] Analyzing code...
flutter analyze
if errorlevel 1 (
    echo [WARNING] Code analysis found issues
) else (
    echo [SUCCESS] Code analysis passed
)

REM Build APK
set "version=%1"
if "%version%"=="" set "version=1.0.0"
set "build_type=%2"
if "%build_type%"=="" set "build_type=release"

echo [INFO] Building %build_type% APK for version %version%...

REM Create releases directory if it doesn't exist
if not exist "releases" mkdir releases

REM Build APK
if "%build_type%"=="release" (
    flutter build apk --release
    copy "build\app\outputs\flutter-apk\app-release.apk" "releases\SpaceDodge-v%version%.apk"
    echo [SUCCESS] Release APK built: releases\SpaceDodge-v%version%.apk
    
    REM Build App Bundle
    echo [INFO] Building App Bundle for version %version%...
    flutter build appbundle --release
    copy "build\app\outputs\bundle\release\app-release.aab" "releases\SpaceDodge-v%version%.aab"
    echo [SUCCESS] App Bundle built: releases\SpaceDodge-v%version%.aab
) else (
    flutter build apk --debug
    copy "build\app\outputs\flutter-apk\app-debug.apk" "releases\SpaceDodge-v%version%-debug.apk"
    echo [SUCCESS] Debug APK built: releases\SpaceDodge-v%version%-debug.apk
)

REM Get file sizes
if "%build_type%"=="release" (
    for %%A in ("releases\SpaceDodge-v%version%.apk") do echo [INFO] APK size: %%~zA bytes
    for %%A in ("releases\SpaceDodge-v%version%.aab") do echo [INFO] AAB size: %%~zA bytes
) else (
    for %%A in ("releases\SpaceDodge-v%version%-debug.apk") do echo [INFO] Debug APK size: %%~zA bytes
)

echo.
echo [SUCCESS] Build process completed successfully!
echo.
echo [INFO] Generated files:
dir releases
echo.
echo [INFO] Next steps:
echo 1. Test the APK on a device
echo 2. Update RELEASE.md with any changes
echo 3. Create a GitHub release with the APK
echo 4. Upload to Google Play Console (if using App Bundle)

pause 