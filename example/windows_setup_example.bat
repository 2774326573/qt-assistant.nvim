@echo off
echo =======================================
echo Qt Assistant Windows Setup Example
echo =======================================
echo.
echo This script demonstrates how to set up your environment
echo for Qt development on Windows with Neovim Qt Assistant.
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% == 0 (
    echo [INFO] Running with administrator privileges
) else (
    echo [WARNING] Consider running as administrator for system-wide installations
)
echo.

:: Set environment variables (customize these paths)
echo [INFO] Setting up environment variables...
set QT_DIR=C:\Qt\6.8.0\msvc2022_64
set CMAKE_PATH=C:\Program Files\CMake\bin
set VS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build

echo Qt Directory: %QT_DIR%
echo CMake Path: %CMAKE_PATH%
echo Visual Studio Path: %VS_PATH%
echo.

:: Add to PATH (session only - for permanent, use setx)
echo [INFO] Adding tools to PATH for this session...
set PATH=%QT_DIR%\bin;%CMAKE_PATH%;%PATH%

:: Verify installations
echo [INFO] Verifying tool installations...
echo.

:: Check Qt
qmake --version >nul 2>&1
if %errorlevel% == 0 (
    echo [✓] Qt is available
    qmake --version | findstr "Qt version"
) else (
    echo [✗] Qt/qmake not found
    echo Please install Qt from https://www.qt.io/download
)
echo.

:: Check CMake
cmake --version >nul 2>&1
if %errorlevel% == 0 (
    echo [✓] CMake is available
    cmake --version | findstr "cmake version"
) else (
    echo [✗] CMake not found
    echo Please install CMake from https://cmake.org/download/
)
echo.

:: Check Visual Studio
where cl >nul 2>&1
if %errorlevel% == 0 (
    echo [✓] Visual Studio compiler is available
) else (
    echo [✗] Visual Studio compiler not found
    echo Please install Visual Studio 2022 or Build Tools
    echo Or run from Visual Studio Developer Command Prompt
)
echo.

:: Create a sample project structure
echo [INFO] Creating sample project structure...
set SAMPLE_DIR=QtSampleProject
if not exist %SAMPLE_DIR% (
    mkdir %SAMPLE_DIR%
    mkdir %SAMPLE_DIR%\src
    mkdir %SAMPLE_DIR%\include
    mkdir %SAMPLE_DIR%\ui
    mkdir %SAMPLE_DIR%\resources
    
    echo Sample project structure created in %SAMPLE_DIR%
) else (
    echo Sample project directory already exists
)
echo.

:: Instructions
echo =======================================
echo Setup Instructions:
echo =======================================
echo.
echo 1. Make sure Qt, CMake, and Visual Studio are installed
echo 2. Add Qt's bin directory to your system PATH permanently:
echo    - %QT_DIR%\bin
echo.
echo 3. In Neovim, configure Qt Assistant in your init.lua:
echo    require('qt-assistant').setup({
echo        qt_tools = {
echo            designer_path = "designer",
echo            qmake_path = "qmake",
echo            cmake_path = "cmake"
echo        }
echo    })
echo.
echo 4. Create a new Qt project using:
echo    :QtNewProject MyProject widget_app
echo.
echo 5. Or add scripts to existing project:
echo    :QtCreateScripts MyProject
echo.
echo Available batch scripts after project creation:
echo - build.bat [Debug^|Release] : Build the project
echo - run.bat [Debug^|Release]   : Run the project
echo - clean.bat                  : Clean build directory
echo - dev.bat                   : Developer menu
echo - setup.bat                : Check development environment
echo.

pause