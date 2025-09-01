@echo off
setlocal enabledelayedexpansion

echo =======================================
echo Qt Development with Visual Studio 2017
echo =======================================
echo.

:: Check for VS2017 installation
set VS2017_FOUND=0
set VS2017_PATH=

:: Check common VS2017 installation paths
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" (
    set VS2017_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat
    set VS2017_EDITION=Community
    set VS2017_FOUND=1
)

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    set VS2017_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars64.bat
    set VS2017_EDITION=Professional
    set VS2017_FOUND=1
)

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
    set VS2017_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars64.bat
    set VS2017_EDITION=Enterprise
    set VS2017_FOUND=1
)

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
    set VS2017_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars64.bat
    set VS2017_EDITION=BuildTools
    set VS2017_FOUND=1
)

if %VS2017_FOUND% equ 1 (
    echo [OK] Visual Studio 2017 %VS2017_EDITION% found
    echo Path: %VS2017_PATH%
    echo.
    
    echo [INFO] Setting up Visual Studio 2017 environment...
    call "%VS2017_PATH%"
    
    if %errorlevel% equ 0 (
        echo [SUCCESS] VS2017 environment loaded successfully!
        echo.
        
        :: Verify compiler
        cl 2>nul
        if %errorlevel% neq 0 (
            echo [WARNING] cl.exe not found in PATH after VS setup
        ) else (
            echo [OK] MSVC compiler ready
            cl 2>&1 | findstr "Microsoft"
        )
        
        echo.
        echo VS2017 C++17 Support:
        echo - /std:c++17 flag available
        echo - /Zc:__cplusplus flag available  
        echo - /permissive- available from VS2017 15.7+
        echo.
        
        echo You can now:
        echo 1. Create Qt projects with C++17 support
        echo 2. Build using: cmake --build . --config Debug
        echo 3. Use Qt tools: qmake, designer, etc.
        echo.
        
    ) else (
        echo [ERROR] Failed to setup VS2017 environment
        exit /b 1
    )
    
) else (
    echo [ERROR] Visual Studio 2017 not found!
    echo.
    echo Please install Visual Studio 2017 with C++ support:
    echo 1. Download from: https://visualstudio.microsoft.com/vs/older-downloads/
    echo 2. Select "Desktop development with C++" workload
    echo 3. Ensure MSVC v141 compiler toolset is installed
    echo.
    echo Or install Visual Studio 2019/2022 for better C++17 support.
    echo.
    pause
    exit /b 1
)

:: Keep environment active for this session
echo Environment will remain active for this command prompt session.
echo To make permanent, add VS tools to your system PATH.
echo.

cmd /k "echo VS2017 environment ready. Type 'exit' to close."