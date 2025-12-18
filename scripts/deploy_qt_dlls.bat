@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Qt DLL Deployment Tool
echo ========================================
echo.

:: Check if export directory path is provided
if "%~1"=="" (
    echo Usage: deploy_qt_dlls.bat ^<export_bin_directory^>
    echo Example: deploy_qt_dlls.bat "D:/Document/Qt/Test1/TestApp/export/TestApp/bin"
    echo.
    pause
    exit /b 1
)

set "BIN_DIR=%~1"

:: Check if directory exists
if not exist "%BIN_DIR%" (
    echo [ERROR] Directory not found: %BIN_DIR%
    echo.
    pause
    exit /b 1
)

echo [INFO] Target directory: %BIN_DIR%
echo.

:: Find windeployqt
where windeployqt >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] windeployqt not found in PATH
    echo.
    echo Please ensure Qt bin directory is in your PATH, for example:
    echo   C:\Qt\6.5.0\msvc2019_64\bin
    echo   C:\Qt\5.15.2\msvc2019_64\bin
    echo.
    echo Or add it temporarily:
    echo   set PATH=C:\Qt\YOUR_VERSION\YOUR_COMPILER\bin;%%PATH%%
    echo.
    pause
    exit /b 1
)

echo [OK] windeployqt found: 
where windeployqt
echo.

:: Find all executables in the directory
set EXE_COUNT=0
for %%F in ("%BIN_DIR%\*.exe") do (
    echo ----------------------------------------
    echo [INFO] Deploying Qt DLLs for: %%~nxF
    echo ----------------------------------------
    
    :: Run windeployqt for each executable
    windeployqt --no-translations --compiler-runtime "%%F"
    
    if !errorlevel! equ 0 (
        echo [SUCCESS] Deployment completed for %%~nxF
        set /a EXE_COUNT+=1
    ) else (
        echo [WARNING] Deployment failed for %%~nxF
    )
    echo.
)

echo ========================================
echo Deployment Summary
echo ========================================
echo Total executables processed: %EXE_COUNT%
echo Target directory: %BIN_DIR%
echo.

:: List DLLs in the directory after deployment
echo DLL files in target directory:
dir /b "%BIN_DIR%\*.dll" 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] No DLL files found after deployment
) else (
    echo.
    echo [INFO] Qt plugins directory:
    if exist "%BIN_DIR%\platforms" (
        echo   [OK] platforms\ exists
    )
    if exist "%BIN_DIR%\styles" (
        echo   [OK] styles\ exists
    )
    if exist "%BIN_DIR%\imageformats" (
        echo   [OK] imageformats\ exists
    )
)

echo.
echo ========================================
echo Deployment complete!
echo ========================================
pause
