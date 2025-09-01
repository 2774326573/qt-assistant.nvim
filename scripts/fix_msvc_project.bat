@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Qt Project MSVC C++17 Fix Script
echo ========================================
echo.
echo This script fixes the MSVC C++17 compilation error by:
echo 1. Updating CMakeLists.txt with proper MSVC flags
echo 2. Regenerating build files with correct configuration
echo 3. Providing guidance for environment setup
echo.

set PROJECT_ROOT=%~dp0
set CMAKELISTS_FILE=%PROJECT_ROOT%CMakeLists.txt

:: Check if CMakeLists.txt exists
if not exist "%CMAKELISTS_FILE%" (
    echo [ERROR] CMakeLists.txt not found in current directory!
    echo Please run this script from your Qt project root directory.
    pause
    exit /b 1
)

echo [INFO] Found CMakeLists.txt: %CMAKELISTS_FILE%

:: Backup original CMakeLists.txt
set BACKUP_FILE=%CMAKELISTS_FILE%.backup
if not exist "%BACKUP_FILE%" (
    echo [INFO] Creating backup: %BACKUP_FILE%
    copy "%CMAKELISTS_FILE%" "%BACKUP_FILE%"
)

:: Create temporary updated CMakeLists.txt
set TEMP_FILE=%CMAKELISTS_FILE%.temp

echo [INFO] Updating CMakeLists.txt with MSVC C++17 fixes...

:: Process the CMakeLists.txt file
(
echo # Updated by Qt Assistant MSVC Fix Script
echo.
) > "%TEMP_FILE%"

:: Read and modify the original file
for /f "delims=" %%a in ('type "%CMAKELISTS_FILE%"') do (
    set "line=%%a"
    
    :: Skip if this line is our marker (avoid duplicates)
    echo !line! | findstr /c:"# MSVC specific settings for C++17 support" >nul
    if !errorlevel! equ 0 (
        echo [INFO] MSVC settings already present, skipping...
        goto :skip_msvc_block
    )
    
    :: Add MSVC settings after C++ standard setting
    echo !line! | findstr /c:"set(CMAKE_CXX_STANDARD_REQUIRED ON)" >nul
    if !errorlevel! equ 0 (
        echo !line!
        echo.
        echo # MSVC specific settings for C++17 support
        echo if^(MSVC^)
        echo     # Ensure we're using the correct C++ standard flags globally
        echo     set^(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++17 /Zc:__cplusplus /permissive-"^)
        echo endif^(^)
    ) else (
        echo !line!
    )
)

:skip_msvc_block

:: Replace original with updated file
move "%TEMP_FILE%" "%CMAKELISTS_FILE%"

echo [SUCCESS] CMakeLists.txt updated successfully!
echo.

:: Clean and regenerate build directory
echo [INFO] Cleaning build directory...
if exist build (
    rmdir /s /q build
    echo [INFO] Removed old build directory
)

echo [INFO] Creating new build directory...
mkdir build
cd build

echo [INFO] Regenerating project with Visual Studio 2022 generator...
cmake .. -G "Visual Studio 17 2022" -A x64
if %errorlevel% neq 0 (
    echo [WARNING] Visual Studio 2022 generator failed, trying default...
    cmake ..
    if %errorlevel% neq 0 (
        echo [ERROR] CMake configuration still failed!
        echo.
        echo Please check:
        echo 1. Visual Studio 2022 is installed
        echo 2. Qt is properly installed and in PATH
        echo 3. You're running from Developer Command Prompt
        pause
        exit /b 1
    )
)

echo.
echo [SUCCESS] Project regenerated successfully!
echo.
echo Next steps:
echo 1. Build project: cmake --build . --config Debug
echo 2. Or use: ..\build.bat Debug
echo.
echo If you still encounter errors:
echo 1. Verify Qt installation: qmake --version
echo 2. Check Visual Studio: where cl
echo 3. Ensure you're using Developer Command Prompt
echo.

pause