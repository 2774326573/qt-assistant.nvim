-- Qt Assistant Plugin - 脚本管理模块
-- Script management module

local M = {}

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
end

-- 脚本配置
local script_configs = {
    build = {
        name = "Build Project",
        description = "构建Qt项目",
        command = "build.sh",
        working_dir = "scripts"
    },
    clean = {
        name = "Clean Project", 
        description = "清理构建文件",
        command = "clean.sh",
        working_dir = "scripts"
    },
    run = {
        name = "Run Application",
        description = "运行应用程序",
        command = "run.sh", 
        working_dir = "scripts"
    },
    debug = {
        name = "Debug Application",
        description = "调试应用程序",
        command = "debug.sh",
        working_dir = "scripts"
    },
    test = {
        name = "Run Tests",
        description = "运行测试",
        command = "test.sh",
        working_dir = "scripts"
    }
}

-- 初始化脚本目录
function M.init_scripts_directory()
    local config = get_config()
    local scripts_dir = config.project_root .. "/" .. config.directories.scripts
    
    -- 创建脚本目录
    local file_manager = require('qt-assistant.file_manager')
    local success, error_msg = file_manager.ensure_directory_exists(scripts_dir)
    
    if not success then
        vim.notify("Failed to create scripts directory: " .. error_msg, vim.log.levels.ERROR)
        return false
    end
    
    -- 创建默认脚本文件
    M.create_default_scripts(scripts_dir)
    
    return true
end

-- 创建默认脚本文件
function M.create_default_scripts(scripts_dir)
    local file_manager = require('qt-assistant.file_manager')
    local system = require('qt-assistant.system')
    local sys = system.detect_os()
    
    -- 根据系统创建不同的脚本
    if sys.is_windows then
        M.create_windows_scripts(scripts_dir, file_manager)
    else
        M.create_unix_scripts(scripts_dir, file_manager)
    end
end

-- 创建Unix/Linux/macOS脚本
function M.create_unix_scripts(scripts_dir, file_manager)
    -- 构建脚本
    local build_script = [[#!/bin/bash
# Qt项目构建脚本

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

echo "=== Building Qt Project ==="
echo "Project directory: $PROJECT_DIR"
echo "Build directory: $BUILD_DIR"

# 创建构建目录
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 运行CMake配置
echo "Running CMake configuration..."
cmake .. -DCMAKE_BUILD_TYPE=Release

# 编译项目
echo "Building project..."
if command -v nproc >/dev/null 2>&1; then
    # Linux
    make -j$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
    # macOS
    make -j$(sysctl -n hw.ncpu)
else
    # 默认4个并行任务
    make -j4
fi

echo "Build completed successfully!"
]]

    -- 清理脚本
    local clean_script = [[#!/bin/bash
# Qt项目清理脚本

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

echo "=== Cleaning Qt Project ==="
echo "Project directory: $PROJECT_DIR"

# 清理构建目录
if [ -d "$BUILD_DIR" ]; then
    echo "Removing build directory: $BUILD_DIR"
    rm -rf "$BUILD_DIR"
    echo "Build directory removed."
else
    echo "Build directory does not exist."
fi

# 清理临时文件
echo "Cleaning temporary files..."
find "$PROJECT_DIR" -name "*.o" -delete
find "$PROJECT_DIR" -name "*.so" -delete
find "$PROJECT_DIR" -name "*.a" -delete
find "$PROJECT_DIR" -name "moc_*.cpp" -delete
find "$PROJECT_DIR" -name "ui_*.h" -delete
find "$PROJECT_DIR" -name "qrc_*.cpp" -delete

echo "Clean completed successfully!"
]]

    -- 运行脚本
    local run_script = [[#!/bin/bash
# Qt项目运行脚本

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

echo "=== Running Qt Application ==="

# 检查构建目录是否存在
if [ ! -d "$BUILD_DIR" ]; then
    echo "Build directory does not exist. Please build the project first."
    echo "Run: ./build.sh"
    exit 1
fi

cd "$BUILD_DIR"

# 查找可执行文件
EXECUTABLE=$(find . -maxdepth 1 -type f -executable | head -n 1)

if [ -z "$EXECUTABLE" ]; then
    echo "No executable found in build directory."
    echo "Please make sure the project is built successfully."
    exit 1
fi

echo "Running: $EXECUTABLE"
$EXECUTABLE
]]

    -- 调试脚本
    local debug_script = [[#!/bin/bash
# Qt项目调试脚本

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

echo "=== Debugging Qt Application ==="

# 检查构建目录是否存在
if [ ! -d "$BUILD_DIR" ]; then
    echo "Build directory does not exist. Please build the project first."
    echo "Run: ./build.sh"
    exit 1
fi

cd "$BUILD_DIR"

# 查找可执行文件
EXECUTABLE=$(find . -maxdepth 1 -type f -executable | head -n 1)

if [ -z "$EXECUTABLE" ]; then
    echo "No executable found in build directory."
    echo "Please make sure the project is built successfully."
    exit 1
fi

# 检查是否安装了调试器
if command -v gdb >/dev/null 2>&1; then
    echo "Starting GDB debugger..."
    gdb "$EXECUTABLE"
elif command -v lldb >/dev/null 2>&1; then
    echo "Starting LLDB debugger..."  
    lldb "$EXECUTABLE"
else
    echo "No debugger found. Please install gdb or lldb."
    echo "Ubuntu/Debian: sudo apt install gdb"
    echo "CentOS/RHEL: sudo yum install gdb"
    exit 1
fi
]]

    -- 测试脚本
    local test_script = [[#!/bin/bash
# Qt项目测试脚本

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/build"

echo "=== Running Qt Project Tests ==="

# 检查构建目录是否存在
if [ ! -d "$BUILD_DIR" ]; then
    echo "Build directory does not exist. Please build the project first."
    echo "Run: ./build.sh"
    exit 1
fi

cd "$BUILD_DIR"

# 运行CTest（如果存在）
if [ -f "CTestTestfile.cmake" ]; then
    echo "Running CTest..."
    ctest --output-on-failure
else
    echo "No CTest configuration found."
    
    # 查找测试可执行文件
    TEST_EXECUTABLES=$(find . -name "*test*" -type f -executable)
    
    if [ -n "$TEST_EXECUTABLES" ]; then
        echo "Found test executables:"
        echo "$TEST_EXECUTABLES"
        echo "Running tests..."
        
        for test_exe in $TEST_EXECUTABLES; do
            echo "Running: $test_exe"
            $test_exe
        done
    else
        echo "No test executables found."
    fi
fi

echo "Tests completed!"
]]

    -- 写入Unix/Linux/macOS脚本文件
    local scripts = {
        ["build.sh"] = build_script,
        ["clean.sh"] = clean_script,
        ["run.sh"] = run_script,
        ["debug.sh"] = debug_script,
        ["test.sh"] = test_script
    }
    
    for filename, content in pairs(scripts) do
        local script_path = scripts_dir .. "/" .. filename
        
        if not file_manager.file_exists(script_path) then
            local success = file_manager.write_file(script_path, content)
            if success then
                -- 设置执行权限
                local system = require('qt-assistant.system')
                system.make_executable(script_path)
                vim.notify("Created script: " .. filename, vim.log.levels.INFO)
            else
                vim.notify("Failed to create script: " .. filename, vim.log.levels.ERROR)
            end
        end
    end
end

-- 创建Windows脚本
function M.create_windows_scripts(scripts_dir, file_manager)
    -- Windows构建脚本
    local build_script = [[@echo off
chcp 65001 >nul
REM Qt Project Build Script

setlocal enabledelayedexpansion

cd /d "%~dp0.."
set "PROJECT_DIR=%~dp0.."
set "BUILD_DIR=%PROJECT_DIR%\build"

echo === Building Qt Project ===
echo Project directory: %PROJECT_DIR%
echo Build directory: %BUILD_DIR%

REM Ask for build type
echo.
echo Select build configuration:
echo 1. Debug
echo 2. Release (default)
echo.
set /p choice="Enter your choice (1-2, default 2): "

if "%choice%"=="" set choice=2
if "%choice%"=="1" (
    set BUILD_CONFIG=Debug
) else (
    set BUILD_CONFIG=Release
)

echo Building in %BUILD_CONFIG% mode...

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

REM 检测编译器并设置生成器
echo Detecting compiler...
set "CMAKE_GENERATOR="

REM 检查Visual Studio
where cl >nul 2>&1
if not errorlevel 1 (
    echo MSVC compiler detected.
    REM 检测Visual Studio版本
    where devenv >nul 2>&1
    if not errorlevel 1 (
        for /f "tokens=*" %%i in ('dir "%ProgramFiles%\Microsoft Visual Studio" /b /ad 2^>nul ^| findstr "2022"') do set CMAKE_GENERATOR=Visual Studio 17 2022
        if "!CMAKE_GENERATOR!"=="" (
            for /f "tokens=*" %%i in ('dir "%ProgramFiles(x86)%\Microsoft Visual Studio" /b /ad 2^>nul ^| findstr "2019"') do set CMAKE_GENERATOR=Visual Studio 16 2019
        )
        if "!CMAKE_GENERATOR!"=="" (
            for /f "tokens=*" %%i in ('dir "%ProgramFiles(x86)%\Microsoft Visual Studio" /b /ad 2^>nul ^| findstr "2017"') do set CMAKE_GENERATOR=Visual Studio 15 2017
        )
    )
    if "!CMAKE_GENERATOR!"=="" set CMAKE_GENERATOR=NMake Makefiles
) else (
    REM 检查MinGW
    where gcc >nul 2>&1
    if not errorlevel 1 (
        echo MinGW compiler detected.
        set CMAKE_GENERATOR=MinGW Makefiles
    ) else (
        echo No supported compiler found!
        pause
        exit /b 1
    )
)

echo Using generator: !CMAKE_GENERATOR!

REM Run CMake configuration
echo Running CMake configuration...
if "!CMAKE_GENERATOR!"=="NMake Makefiles" (
    cmake .. -G "!CMAKE_GENERATOR!" -DCMAKE_BUILD_TYPE=%BUILD_CONFIG%
) else (
    cmake .. -G "!CMAKE_GENERATOR!" -A x64
)

if errorlevel 1 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

REM Build project
echo Building project...
cmake --build . --config %BUILD_CONFIG%
if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed successfully!
pause
]]

    -- Windows清理脚本
    local clean_script = [[@echo off
REM Qt项目清理脚本

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0.."
set "BUILD_DIR=%PROJECT_DIR%\build"

echo === Cleaning Qt Project ===
echo Project directory: %PROJECT_DIR%

REM 清理构建目录
if exist "%BUILD_DIR%" (
    echo Removing build directory: %BUILD_DIR%
    rmdir /s /q "%BUILD_DIR%"
    echo Build directory removed.
) else (
    echo Build directory does not exist.
)

REM 清理临时文件
echo Cleaning temporary files...
cd /d "%PROJECT_DIR%"
for /r %%i in (*.obj *.exe *.dll *.lib *.pdb *.ilk *.exp) do (
    if exist "%%i" del /q "%%i"
)

echo Clean completed successfully!
pause
]]

    -- Windows运行脚本
    local run_script = [[@echo off
REM Qt项目运行脚本

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0.."
set "BUILD_DIR=%PROJECT_DIR%\build"

echo === Running Qt Application ===

REM Check if build directory exists
if not exist "%BUILD_DIR%" (
    echo Build directory does not exist. Please build the project first.
    echo Run: build.bat
    pause
    exit /b 1
)

cd /d "%BUILD_DIR%"

REM Find executable file
REM 首先在根目录查找
for %%f in (*.exe) do (
    set "EXECUTABLE=%%f"
    goto :found
)

REM 在Release目录中查找
if exist "Release" (
    for %%f in (Release\*.exe) do (
        set "EXECUTABLE=Release\%%~nxf"
        goto :found
    )
)

REM 在Debug目录中查找
if exist "Debug" (
    for %%f in (Debug\*.exe) do (
        set "EXECUTABLE=Debug\%%~nxf"
        goto :found
    )
)

REM 在bin目录中查找
if exist "bin" (
    for %%f in (bin\*.exe) do (
        set "EXECUTABLE=bin\%%~nxf"
        goto :found
    )
)

echo No executable found in build directory.
echo Please make sure the project is built successfully.
pause
exit /b 1

:found
echo Running: %EXECUTABLE%
"%EXECUTABLE%"
pause
]]

    -- Windows调试脚本
    local debug_script = [[@echo off
REM Qt项目调试脚本

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0.."
set "BUILD_DIR=%PROJECT_DIR%\build"

echo === Debugging Qt Application ===

REM Check if build directory exists
if not exist "%BUILD_DIR%" (
    echo Build directory does not exist. Please build the project first.
    echo Run: build.bat
    pause
    exit /b 1
)

cd /d "%BUILD_DIR%"

REM Find executable file（优先Debug版本）
REM 在Debug目录中查找
if exist "Debug" (
    for %%f in (Debug\*.exe) do (
        set "EXECUTABLE=Debug\%%~nxf"
        goto :found
    )
)

REM 在根目录查找
for %%f in (*.exe) do (
    set "EXECUTABLE=%%f"
    goto :found
)

REM 在Release目录中查找
if exist "Release" (
    for %%f in (Release\*.exe) do (
        set "EXECUTABLE=Release\%%~nxf"
        goto :found
    )
)

REM 在bin目录中查找
if exist "bin" (
    for %%f in (bin\*.exe) do (
        set "EXECUTABLE=bin\%%~nxf"
        goto :found
    )
)

echo No executable found in build directory.
pause
exit /b 1

:found
REM 检查是否安装了调试器
where devenv >nul 2>&1
if not errorlevel 1 (
    echo Starting Visual Studio debugger...
    devenv "%EXECUTABLE%"
    goto :end
)

where gdb >nul 2>&1
if not errorlevel 1 (
    echo Starting GDB debugger...
    gdb "%EXECUTABLE%"
    goto :end
)

echo No debugger found. Please install Visual Studio or GDB.
pause
exit /b 1

:end
]]

    -- Windows测试脚本
    local test_script = [[@echo off
REM Qt项目测试脚本

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0.."
set "BUILD_DIR=%PROJECT_DIR%\build"

echo === Running Qt Project Tests ===

REM Check if build directory exists
if not exist "%BUILD_DIR%" (
    echo Build directory does not exist. Please build the project first.
    echo Run: build.bat
    pause
    exit /b 1
)

cd /d "%BUILD_DIR%"

REM 运行CTest（如果存在）
if exist "CTestTestfile.cmake" (
    echo Running CTest...
    ctest --output-on-failure
) else (
    echo No CTest configuration found.
    
    REM 查找测试可执行文件
    for %%f in (*test*.exe) do (
        echo Running: %%f
        "%%f"
    )
)

echo Tests completed!
pause
]]

    -- 修复.pro文件Windows路径脚本
    local fix_pro_script = [[@echo off
REM Fix .pro file for Windows MSVC compilation

setlocal enabledelayedexpansion

cd /d "%~dp0.."

echo === Fixing .pro file for Windows MSVC ===

REM Find .pro files
for %%f in (*.pro) do (
    set "PRO_FILE=%%f"
    echo Found .pro file: !PRO_FILE!
    
    REM Check if already has VC_IncludePath
    findstr /i "VC_IncludePath" "!PRO_FILE!" >nul
    if errorlevel 1 (
        echo Adding MSVC include paths to !PRO_FILE!...
        echo. >> "!PRO_FILE!"
        echo # Windows MSVC paths - added by qt-assistant >> "!PRO_FILE!"
        echo win32:INCLUDEPATH += $$(VC_IncludePath^) >> "!PRO_FILE!"
        echo win32:INCLUDEPATH += $$(WindowsSdkDir^)Include\$$(WindowsSDKVersion^)\ucrt >> "!PRO_FILE!"
        echo win32:INCLUDEPATH += $$(WindowsSdkDir^)Include\$$(WindowsSDKVersion^)\shared >> "!PRO_FILE!"
        echo win32:INCLUDEPATH += $$(WindowsSdkDir^)Include\$$(WindowsSDKVersion^)\um >> "!PRO_FILE!"
        echo win32:INCLUDEPATH += $$(WindowsSdkDir^)Include\$$(WindowsSDKVersion^)\winrt >> "!PRO_FILE!"
        echo. >> "!PRO_FILE!"
        echo MSVC include paths added to !PRO_FILE!
    ) else (
        echo !PRO_FILE! already contains MSVC paths.
    )
)

echo .pro file fix completed!
echo.
echo Next steps:
echo 1. Clean and rebuild your project
echo 2. Run: qmake and then nmake
echo.
pause
]]

    -- 生成clangd兼容的compile_commands.json脚本
    local generate_clangd_script = [[@echo off
REM Generate clangd-compatible compile_commands.json

setlocal enabledelayedexpansion

cd /d "%~dp0.."
set "PROJECT_DIR=%~dp0.."

echo === Generating clangd-compatible compile_commands.json ===

REM 检查是否存在Qt Creator生成的compile_commands.json
if exist "compile_commands.json" (
    echo Backing up existing compile_commands.json...
    copy "compile_commands.json" "compile_commands.json.qtcreator.bak" >nul
)

REM 检查bear工具是否可用
where bear >nul 2>&1
if not errorlevel 1 (
    echo Using bear to generate compile_commands.json...
    
    REM 清理之前的构建
    if exist "build" rmdir /s /q build
    
    REM 生成Makefile
    qmake CONFIG+=debug
    if errorlevel 1 (
        echo qmake failed!
        pause
        exit /b 1
    )
    
    REM 使用bear生成compile_commands.json
    bear -- nmake
    
    echo compile_commands.json generated successfully!
) else (
    echo Bear tool not found. Creating simplified .clangd config instead...
    
    REM 创建.clangd配置文件
    echo CompileFlags: > .clangd
    echo   Add: >> .clangd
    echo     - -std=c++14 >> .clangd
    echo     - -DQT_WIDGETS_LIB >> .clangd
    echo     - -DQT_GUI_LIB >> .clangd
    echo     - -DQT_CORE_LIB >> .clangd
    echo     - -DQT_SQL_LIB >> .clangd
    echo     - -DQT_XML_LIB >> .clangd
    echo     - -DUNICODE >> .clangd
    echo     - -D_UNICODE >> .clangd
    echo     - -DWIN32 >> .clangd
    echo     - -DWIN64 >> .clangd
    echo   Remove: >> .clangd
    echo     - --driver-mode=* >> .clangd
    echo     - /Zs >> .clangd
    echo     - /TP >> .clangd
    echo     - -nostdinc >> .clangd
    echo     - -nostdinc++ >> .clangd
    echo     - /clang:* >> .clangd
    echo     - -fms-compatibility-version=* >> .clangd
    
    echo .clangd config file created successfully!
    echo Install bear tool for better compile_commands.json generation:
    echo   pip install bear
)

echo.
echo === Instructions for Neovim ===
echo 1. Make sure Neovim is started from this project directory
echo 2. Run :LspRestart in Neovim to reload clangd
echo 3. Check :LspInfo to verify clangd is working
echo.
pause
]]

    -- MSVC环境设置脚本
    local setup_msvc_script = [[@echo off
REM Setup MSVC Environment

REM Check if already setup
if defined VCINSTALLDIR (
    echo MSVC environment already configured.
    goto :end
)

setlocal enabledelayedexpansion

echo === Setting up MSVC Environment ===

REM 查找vcvarsall.bat
set "VCVARSALL="

REM Visual Studio 2022
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"
)

REM Visual Studio 2019
if "!VCVARSALL!"=="" (
    if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
    ) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat"
    ) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"
    )
)

REM Visual Studio 2017
if "!VCVARSALL!"=="" (
    if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
    ) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"
    ) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat"
    )
)

if "!VCVARSALL!"=="" (
    echo Visual Studio not found! Please install Visual Studio 2017, 2019, or 2022.
    pause
    exit /b 1
)

echo Found Visual Studio at: !VCVARSALL!
echo Setting up x64 environment...
call "!VCVARSALL!" x64

if errorlevel 1 (
    echo Failed to setup MSVC environment!
    pause
    exit /b 1
)

echo MSVC environment setup completed!
echo.
echo Available tools:
echo - cl.exe (C++ compiler)
echo - nmake.exe (build tool)
echo - devenv.exe (Visual Studio IDE)
echo.

:end
REM Don't pause when called from other scripts
if "%1"=="nopause" goto :eof
pause
]]

    -- 快速Debug构建脚本
    local build_debug_script = [[@echo off
REM Qt项目Debug构建脚本

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0.."
set "BUILD_DIR=%PROJECT_DIR%\build"

echo === Building Qt Project (Debug) ===
echo Project directory: %PROJECT_DIR%
echo Build directory: %BUILD_DIR%

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

REM Run CMake configuration
echo Running CMake configuration...
cmake .. -DCMAKE_BUILD_TYPE=Debug
if errorlevel 1 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

REM Build project
echo Building project...
cmake --build . --config Debug
if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo Debug build completed successfully!
pause
]]

    -- MSVC状态检查脚本
    local check_msvc_script = [[@echo off
REM Check MSVC Status

echo === MSVC Environment Status ===
echo.

REM 检查编译器
echo [1] Checking C++ Compiler (cl.exe)...
where cl >nul 2>&1
if not errorlevel 1 (
    echo     ✓ cl.exe found
    cl 2>nul | findstr /i "Microsoft" | head -n 1
) else (
    echo     ✗ cl.exe not found
)
echo.

REM 检查nmake
echo [2] Checking Build Tool (nmake.exe)...
where nmake >nul 2>&1
if not errorlevel 1 (
    echo     ✓ nmake.exe found
    nmake /? 2>nul | findstr /i "Microsoft" | head -n 1
) else (
    echo     ✗ nmake.exe not found
)
echo.

REM 检查devenv
echo [3] Checking Visual Studio IDE (devenv.exe)...
where devenv >nul 2>&1
if not errorlevel 1 (
    echo     ✓ devenv.exe found
) else (
    echo     ✗ devenv.exe not found
)
echo.

REM 检查Qt
echo [4] Checking Qt installation...
where qmake >nul 2>&1
if not errorlevel 1 (
    echo     ✓ qmake.exe found
    qmake -v 2>nul | findstr /i "Qt version"
) else (
    echo     ✗ qmake.exe not found
)
echo.

REM 检查CMake
echo [5] Checking CMake...
where cmake >nul 2>&1
if not errorlevel 1 (
    echo     ✓ cmake.exe found
    cmake --version 2>nul | head -n 1
) else (
    echo     ✗ cmake.exe not found
)
echo.

echo === Environment Variables ===
echo VCINSTALLDIR=%VCINSTALLDIR%
echo INCLUDE=%INCLUDE%
echo LIB=%LIB%
echo PATH (Qt paths):
echo %PATH% | findstr /i qt
echo.

echo To setup MSVC environment, run: setup_msvc.bat
pause
]]

    -- 写入Windows脚本文件
    local scripts = {
        ["build.bat"] = build_script,
        ["build-debug.bat"] = build_debug_script,
        ["clean.bat"] = clean_script,
        ["run.bat"] = run_script,
        ["debug.bat"] = debug_script,
        ["test.bat"] = test_script,
        ["setup_msvc.bat"] = setup_msvc_script,
        ["check_msvc.bat"] = check_msvc_script,
        ["setup_clangd.bat"] = generate_clangd_script,
        ["fix_pro.bat"] = fix_pro_script
    }
    
    for filename, content in pairs(scripts) do
        local script_path = scripts_dir .. "\\" .. filename
        
        if not file_manager.file_exists(script_path) then
            local success = file_manager.write_file(script_path, content)
            if success then
                vim.notify("Created script: " .. filename, vim.log.levels.INFO)
            else
                vim.notify("Failed to create script: " .. filename, vim.log.levels.ERROR)
            end
        end
    end
end

-- 运行脚本
function M.run_script(script_name, options)
    options = options or {}
    
    local config = get_config()
    local system = require('qt-assistant.system')
    local sys = system.detect_os()
    local scripts_dir = system.join_path(config.project_root, config.directories.scripts)
    
    local script_config = script_configs[script_name]
    if not script_config then
        vim.notify("Unknown script: " .. script_name, vim.log.levels.ERROR)
        return false
    end
    
    -- 根据系统选择正确的脚本文件
    local script_extension = sys.is_windows and ".bat" or ".sh"
    local script_filename = script_name .. script_extension
    local script_path = system.join_path(scripts_dir, script_filename)
    
    local file_manager = require('qt-assistant.file_manager')
    
    if not file_manager.file_exists(script_path) then
        vim.notify("Script not found: " .. script_path, vim.log.levels.ERROR)
        vim.notify("Run :QtInitScripts to create default scripts", vim.log.levels.INFO)
        return false
    end
    
    -- 在终端中运行脚本
    if options.in_terminal then
        M.run_script_in_terminal(script_path, script_config)
    else
        M.run_script_async(script_path, script_config)
    end
    
    return true
end

-- 在终端中运行脚本
function M.run_script_in_terminal(script_path, script_config)
    local system = require('qt-assistant.system')
    local sys = system.detect_os()
    
    local cmd
    if sys.is_windows then
        cmd = "cd /d " .. vim.fn.shellescape(vim.fn.fnamemodify(script_path, ":h")) ..
              " && " .. vim.fn.shellescape(script_path)
    else
        cmd = "cd " .. vim.fn.shellescape(vim.fn.fnamemodify(script_path, ":h")) ..
              " && " .. vim.fn.shellescape(script_path)
    end
    
    -- 打开终端并运行命令
    vim.cmd("split")
    vim.cmd("terminal " .. cmd)
    
    vim.notify("Running " .. script_config.name .. " in terminal", vim.log.levels.INFO)
end

-- 异步运行脚本
function M.run_script_async(script_path, script_config)
    local cmd = {script_path}
    local cwd = vim.fn.fnamemodify(script_path, ":h")
    
    vim.notify("Starting " .. script_config.name .. "...", vim.log.levels.INFO)
    
    local job_id = vim.fn.jobstart(cmd, {
        cwd = cwd,
        on_stdout = function(_, data)
            if data and #data > 0 then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        print("[" .. script_config.name .. "] " .. line)
                    end
                end
            end
        end,
        on_stderr = function(_, data)
            if data and #data > 0 then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        vim.notify("[" .. script_config.name .. " ERROR] " .. line, vim.log.levels.ERROR)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                vim.notify(script_config.name .. " completed successfully!", vim.log.levels.INFO)
            else
                vim.notify(script_config.name .. " failed with exit code: " .. exit_code, vim.log.levels.ERROR)
            end
        end
    })
    
    if job_id <= 0 then
        vim.notify("Failed to start " .. script_config.name, vim.log.levels.ERROR)
    end
end

-- 获取可用脚本列表
function M.get_available_scripts()
    local scripts = {}
    for name, config in pairs(script_configs) do
        table.insert(scripts, {
            name = name,
            display_name = config.name,
            description = config.description
        })
    end
    return scripts
end

-- 编辑脚本
function M.edit_script(script_name)
    local config = get_config()
    local scripts_dir = config.project_root .. "/" .. config.directories.scripts
    
    local script_config = script_configs[script_name]
    if not script_config then
        vim.notify("Unknown script: " .. script_name, vim.log.levels.ERROR)
        return false
    end
    
    local script_path = scripts_dir .. "/" .. script_config.command
    local file_manager = require('qt-assistant.file_manager')
    
    if not file_manager.file_exists(script_path) then
        vim.notify("Script not found: " .. script_path, vim.log.levels.ERROR)
        return false
    end
    
    -- 在新缓冲区中打开脚本文件
    vim.cmd("edit " .. vim.fn.fnameescape(script_path))
    
    return true
end

-- 检查脚本状态
function M.check_script_status()
    local config = get_config()
    local scripts_dir = config.project_root .. "/" .. config.directories.scripts
    local file_manager = require('qt-assistant.file_manager')
    
    local status = {
        scripts_dir_exists = file_manager.file_exists(scripts_dir),
        scripts = {}
    }
    
    for name, script_config in pairs(script_configs) do
        local script_path = scripts_dir .. "/" .. script_config.command
        status.scripts[name] = {
            exists = file_manager.file_exists(script_path),
            path = script_path,
            executable = false
        }
        
        if status.scripts[name].exists then
            -- 检查是否可执行
            local stat = vim.loop.fs_stat(script_path)
            if stat and stat.mode then
                -- 简单检查执行权限（owner execute bit）
                status.scripts[name].executable = (stat.mode % 512) >= 256
            end
        end
    end
    
    return status
end

-- 显示脚本状态
function M.show_script_status()
    local status = M.check_script_status()
    
    print("=== Qt Assistant Scripts Status ===")
    print("Scripts directory: " .. (status.scripts_dir_exists and "EXISTS" or "MISSING"))
    print("")
    
    for name, script_status in pairs(status.scripts) do
        local script_config = script_configs[name]
        local status_text = script_status.exists and 
                           (script_status.executable and "READY" or "NOT EXECUTABLE") or "MISSING"
        
        print(string.format("%-10s [%-13s] %s", name, status_text, script_config.description))
    end
    
    if not status.scripts_dir_exists then
        print("\nRun :QtInitScripts to create scripts directory and default scripts.")
    end
end

-- ==================== 新增功能：独立脚本生成 ====================

-- 脚本类型配置（统一版本）
local script_types = {
    build = {
        name = "构建脚本",
        description = "编译项目的脚本",
        executable = true
    },
    run = {
        name = "运行脚本", 
        description = "运行项目的脚本",
        executable = true
    },
    debug = {
        name = "调试脚本",
        description = "调试项目的脚本", 
        executable = true
    },
    clean = {
        name = "清理脚本",
        description = "清理编译文件的脚本",
        executable = true
    },
    test = {
        name = "测试脚本",
        description = "运行测试的脚本",
        executable = true
    },
    deploy = {
        name = "部署脚本",
        description = "部署项目的脚本",
        executable = true
    },
    setup_clangd = {
        name = "Clangd设置脚本",
        description = "为Neovim配置clangd语言服务器",
        executable = true
    },
    setup_msvc = {
        name = "MSVC环境设置脚本",
        description = "设置MSVC编译环境",
        executable = true
    },
    check_msvc = {
        name = "MSVC状态检查脚本",
        description = "检查MSVC编译环境状态",
        executable = true
    },
    fix_pro = {
        name = ".pro文件修复脚本",
        description = "修复Windows下.pro文件的MSVC路径问题",
        executable = true
    },
    fix_compile = {
        name = "编译环境修复脚本",
        description = "修复编译环境和标准库路径问题",
        executable = true
    }
}

-- 快速生成脚本（可以覆盖现有脚本）
function M.quick_generate_scripts()
    local success, scripts_dir = M.ensure_scripts_directory()
    if not success then
        vim.notify("Error: " .. scripts_dir, vim.log.levels.ERROR)
        return false
    end
    
    -- 清理旧的文件名冲突
    M.cleanup_old_script_files(scripts_dir)
    
    -- 检测构建系统
    local build_system = M.detect_build_system()
    vim.notify("Generating scripts for " .. build_system .. " build system...", vim.log.levels.INFO)
    
    -- 强制生成所有脚本
    M.force_generate_scripts(scripts_dir, build_system)
    
    vim.notify("All scripts generated successfully in: " .. scripts_dir, vim.log.levels.INFO)
    return true
end

-- 清理旧的脚本文件（连字符命名的文件）
function M.cleanup_old_script_files(scripts_dir)
    local old_files = {
        "setup-msvc.bat",
        "check-msvc.bat", 
        "setup-clangd.bat",
        "fix-pro.bat"
    }
    
    for _, filename in ipairs(old_files) do
        local system = require('qt-assistant.system')
        local old_path = system.join_path(scripts_dir, filename)
        if vim.fn.filereadable(old_path) == 1 then
            vim.fn.delete(old_path)
            vim.notify("Removed old script: " .. filename, vim.log.levels.INFO)
        end
    end
end

-- 强制生成脚本（覆盖现有）
function M.force_generate_scripts(scripts_dir, build_system)
    local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
    local script_ext = is_windows and ".bat" or ".sh"
    
    local generated_count = 0
    
    -- 为每种脚本类型生成文件
    for script_type, config in pairs(script_types) do
        local script_content = M.generate_script_content(script_type, build_system, is_windows)
        local system = require('qt-assistant.system')
        local script_path = system.join_path(scripts_dir, script_type .. script_ext)
        
        if M.write_script_file(script_path, script_content, is_windows) then
            vim.notify("Generated: " .. script_type .. script_ext, vim.log.levels.INFO)
            generated_count = generated_count + 1
        end
    end
    
    vim.notify(string.format("Generated %d scripts", generated_count), vim.log.levels.INFO)
end

-- 生成单个脚本
function M.generate_single_script(script_type)
    local success, scripts_dir = M.ensure_scripts_directory()
    if not success then
        vim.notify("Error: " .. scripts_dir, vim.log.levels.ERROR)
        return false
    end
    
    if not script_types[script_type] then
        vim.notify("Unknown script type: " .. script_type, vim.log.levels.ERROR)
        return false
    end
    
    -- 检测构建系统
    local build_system = M.detect_build_system()
    local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
    local script_ext = is_windows and ".bat" or ".sh"
    
    local script_content = M.generate_script_content(script_type, build_system, is_windows)
    local system = require('qt-assistant.system')
    local script_path = system.join_path(scripts_dir, script_type .. script_ext)
    
    if M.write_script_file(script_path, script_content, is_windows) then
        vim.notify("Generated " .. script_type .. " script: " .. script_path, vim.log.levels.INFO)
        return true
    else
        vim.notify("Failed to generate " .. script_type .. " script", vim.log.levels.ERROR)
        return false
    end
end

-- 交互式脚本生成器
function M.interactive_script_generator()
    local script_list = {}
    for script_type, config in pairs(script_types) do
        table.insert(script_list, {type = script_type, name = config.name})
    end
    
    -- 创建选择菜单
    local choices = {"=== Script Generator ===", ""}
    table.insert(choices, "0. Generate All Scripts")
    table.insert(choices, "")
    
    for i, script in ipairs(script_list) do
        table.insert(choices, string.format("%d. Generate %s", i, script.name))
    end
    
    local choice = vim.fn.inputlist(choices)
    
    if choice == 0 then
        M.quick_generate_scripts()
    elseif choice >= 1 and choice <= #script_list then
        local selected_script = script_list[choice]
        M.generate_single_script(selected_script.type)
    else
        vim.notify("Script generation cancelled", vim.log.levels.WARN)
    end
end

-- 构建系统检测
function M.detect_build_system()
    local cwd = vim.fn.getcwd()
    
    -- 检查CMakeLists.txt
    if vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
        return "cmake"
    end
    
    -- 检查.pro文件
    local pro_files = vim.fn.glob(cwd .. "/*.pro", false, true)
    if #pro_files > 0 then
        return "qmake"
    end
    
    -- 检查Makefile
    if vim.fn.filereadable(cwd .. "/Makefile") == 1 then
        return "make"
    end
    
    return "unknown"
end

-- 创建脚本目录
function M.ensure_scripts_directory()
    local scripts_dir = M.get_scripts_directory()
    local stat = vim.loop.fs_stat(scripts_dir)
    
    if not stat then
        local success = vim.fn.mkdir(scripts_dir, "p")
        if success == 0 then
            return false, "Failed to create scripts directory: " .. scripts_dir
        end
        vim.notify("Created scripts directory: " .. scripts_dir, vim.log.levels.INFO)
    elseif stat.type ~= "directory" then
        return false, "Scripts path exists but is not a directory: " .. scripts_dir
    end
    
    return true, scripts_dir
end

-- 生成脚本内容
function M.generate_script_content(script_type, build_system, is_windows)
    -- 检测Qt版本
    local qt_version = M.detect_qt_version()
    local templates = M.get_script_templates(build_system, is_windows, qt_version)
    local content = templates[script_type] or templates.default
    
    -- 获取用户配置
    local config = require('qt-assistant.config').get()
    local build_env = config.build_environment or {}
    
    -- 替换项目名称变量
    local project_name = M.get_project_name()
    content = content:gsub("{{PROJECT_NAME}}", project_name)
    
    -- 替换Qt版本相关变量
    content = content:gsub("{{QT_VERSION}}", tostring(qt_version))
    
    -- 替换Visual Studio路径变量
    content = content:gsub("{{CUSTOM_VS2017_PATH}}", build_env.vs2017_path or "")
    content = content:gsub("{{CUSTOM_VS2019_PATH}}", build_env.vs2019_path or "")
    content = content:gsub("{{CUSTOM_VS2022_PATH}}", build_env.vs2022_path or "")
    content = content:gsub("{{PREFER_VS_VERSION}}", build_env.prefer_vs_version or "2017")
    
    return content
end

-- 检测Qt版本
function M.detect_qt_version()
    -- 尝试使用Qt版本检测模块
    local ok, qt_version_module = pcall(require, "qt-assistant.qt_version")
    if ok then
        local detected_version = qt_version_module.get_recommended_qt_version(vim.fn.getcwd())
        if detected_version then
            return detected_version
        end
    end
    
    -- 从CMakeLists.txt检测Qt版本
    local cmake_file = vim.fn.getcwd() .. "/CMakeLists.txt"
    if vim.fn.filereadable(cmake_file) == 1 then
        local content = vim.fn.readfile(cmake_file)
        for _, line in ipairs(content) do
            if line:match("find_package%s*%(%s*Qt6") then
                return 6
            elseif line:match("find_package%s*%(%s*Qt5") then
                return 5
            end
        end
    end
    
    -- 默认返回Qt6
    return 6
end

-- 获取项目名称
function M.get_project_name()
    -- 尝试从CMakeLists.txt获取项目名称
    local cmake_file = vim.fn.getcwd() .. "/CMakeLists.txt"
    if vim.fn.filereadable(cmake_file) == 1 then
        local content = vim.fn.readfile(cmake_file)
        for _, line in ipairs(content) do
            local project_match = line:match("project%s*%(%s*([%w_%-]+)")
            if project_match then
                return project_match
            end
        end
    end
    
    -- 尝试从.pro文件获取项目名称
    local pro_files = vim.fn.glob(vim.fn.getcwd() .. "/*.pro", false, true)
    if #pro_files > 0 then
        local pro_name = vim.fn.fnamemodify(pro_files[1], ":t:r")
        return pro_name
    end
    
    -- 默认使用当前目录名称
    return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

-- 获取脚本模板
function M.get_script_templates(build_system, is_windows, qt_version)
    qt_version = qt_version or 6
    if is_windows then
        return M.get_windows_templates(build_system, qt_version)
    else
        return M.get_unix_templates(build_system, qt_version)
    end
end

-- Unix/Linux脚本模板（简化版）
function M.get_unix_templates(build_system, qt_version)
    local templates = {}
    
    if build_system == "cmake" then
        templates.build = [[#!/bin/bash
echo "Building Qt project with CMake..."
cd "$(dirname "$0")/.." || exit 1
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Debug .. || exit 1
cmake --build . --config Debug -j $(nproc) || exit 1
echo "Build completed successfully!"]]

        templates.run = [[#!/bin/bash
echo "Running Qt project..."
cd "$(dirname "$0")/.." || exit 1
if [ ! -d "build" ]; then
  echo "Build directory not found! Please build first."
  exit 1
fi
cd build
if [ -x "./bin/{{PROJECT_NAME}}" ]; then
  echo "Running ./bin/{{PROJECT_NAME}}..."
  ./bin/{{PROJECT_NAME}}
elif [ -x "./{{PROJECT_NAME}}" ]; then
  echo "Running ./{{PROJECT_NAME}}..."
  ./{{PROJECT_NAME}}
else
  echo "Executable {{PROJECT_NAME}} not found!"
  exit 1
fi]]

        templates.clean = [[#!/bin/bash
echo "Cleaning Qt project..."
cd "$(dirname "$0")/.." || exit 1
if [ -d "build" ]; then
  rm -rf build
  echo "Build directory removed."
fi
rm -f *.tmp *.log
echo "Clean completed!"]]

    elseif build_system == "qmake" then
        templates.build = [[#!/bin/bash
echo "Building Qt project with qmake..."
mkdir -p build && cd build
qmake ..
if command -v nproc >/dev/null 2>&1; then
    # Linux
    make -j $(nproc)
elif command -v sysctl >/dev/null 2>&1; then
    # macOS
    make -j $(sysctl -n hw.ncpu)
else
    # 默认4个并行任务
    make -j 4
fi
echo "Build completed successfully!"]]

        templates.run = [[#!/bin/bash
echo "Running Qt project..."
if [ ! -d "build" ]; then
    echo "Build directory not found! Please build first."
    exit 1
fi
cd build
for exe in $(find . -maxdepth 1 -type f -executable -not -name "*.so*"); do
    if [ -f "$exe" ]; then
        echo "Running $exe..."
        "$exe"
        exit 0
    fi
done
echo "No executable found!"]]

        templates.clean = [[#!/bin/bash
echo "Cleaning Qt project..."
if [ -d "build" ]; then
    rm -rf build
fi
rm -f Makefile* *.pro.user* *.tmp
echo "Clean completed!"]]
    end

    templates.debug = [[#!/bin/bash
echo "Debugging Qt project..."
cd "$(dirname "$0")/.." || exit 1
if [ ! -d "build" ]; then
  echo "Build directory not found! Please build first."
  exit 1
fi
cd build
for exe in $(find . -maxdepth 1 -type f -executable -not -name "*.so*"); do
  if [ -f "$exe" ]; then
    echo "Debugging $exe with gdb..."
    gdb "$exe"
    exit 0
  fi
done
echo "No executable found!"]]

    templates.test = [[#!/bin/bash
echo "Running tests..."
cd "$(dirname "$0")/.." || exit 1
if [ ! -d "build" ]; then
  echo "Build directory not found! Please build first."
  exit 1
fi
cd build
ctest --output-on-failure || exit 1
echo "Tests completed!"]]

    templates.deploy = [[#!/bin/bash
echo "Deploying Qt project..."
cd "$(dirname "$0")/.." || exit 1
if [ ! -d "build" ]; then
  echo "Build directory not found! Please build first."
  exit 1
fi
cd build
mkdir -p deploy
for exe in $(find . -maxdepth 1 -type f -executable -not -name "*.so*"); do
  if [ -f "$exe" ]; then
    cp "$exe" deploy/
  fi
done
echo "Deployment completed!"]]

    templates.setup_msvc = [[#!/bin/bash
echo "MSVC setup is only needed on Windows."
echo "On Unix/Linux/macOS, use gcc/clang compiler instead."
echo "For Qt development, install Qt development packages:"
echo "  Ubuntu/Debian: sudo apt install qtbase5-dev qttools5-dev"
echo "  CentOS/RHEL: sudo yum install qt5-qtbase-devel qt5-qttools-devel"
echo "  macOS: brew install qt"]]

    templates.check_msvc = [[#!/bin/bash
echo "=== Development Environment Status ==="
echo

echo "[1] Checking C++ Compiler..."
if command -v g++ >/dev/null 2>&1; then
    echo "    ✓ g++ found"
    g++ --version | head -n 1
elif command -v clang++ >/dev/null 2>&1; then
    echo "    ✓ clang++ found"
    clang++ --version | head -n 1
else
    echo "    ✗ No C++ compiler found"
fi
echo

echo "[2] Checking Build Tool..."
if command -v make >/dev/null 2>&1; then
    echo "    ✓ make found"
else
    echo "    ✗ make not found"
fi
echo

echo "[3] Checking Qt installation..."
if command -v qmake >/dev/null 2>&1; then
    echo "    ✓ qmake found"
    qmake -v
else
    echo "    ✗ qmake not found"
fi
echo

echo "[4] Checking CMake..."
if command -v cmake >/dev/null 2>&1; then
    echo "    ✓ cmake found"
    cmake --version | head -n 1
else
    echo "    ✗ cmake not found"
fi]]

    templates.setup_clangd = [[#!/bin/bash
echo "Setting up clangd for Neovim..."
cd "$(dirname "$0")/.." || exit 1

# Backup existing compile_commands.json if it exists
if [ -f "compile_commands.json" ]; then
    echo "Backing up existing compile_commands.json..."
    cp "compile_commands.json" "compile_commands.json.backup"
fi

# Create .clangd config file
echo "Creating .clangd configuration..."
cat > .clangd << 'EOF'
CompileFlags:
  Add:
    - -std=c++14
    - -DQT_WIDGETS_LIB
    - -DQT_GUI_LIB
    - -DQT_CORE_LIB
    - -DQT_SQL_LIB
    - -DQT_XML_LIB
  Remove:
    - -nostdinc
    - -nostdinc++
EOF

echo ".clangd configuration created!"
echo
echo "Next steps:"
echo "1. Start Neovim from this directory"
echo "2. Run :LspRestart to reload clangd"
echo "3. Check :LspInfo to verify clangd is working"]]

    templates.fix_pro = [[#!/bin/bash
echo "Fixing .pro file for Unix/Linux/macOS..."
cd "$(dirname "$0")/.." || exit 1

for pro_file in *.pro; do
    if [ -f "$pro_file" ]; then
        if ! grep -q "unix:" "$pro_file"; then
            echo "Adding Unix-specific configurations to $pro_file..."
            echo "" >> "$pro_file"
            echo "# Unix/Linux/macOS configurations" >> "$pro_file"
            echo "unix:LIBS += -lpthread" >> "$pro_file"
            echo "unix:CONFIG += link_pkgconfig" >> "$pro_file"
            echo "$pro_file updated."
        else
            echo "$pro_file already has Unix configurations."
        fi
    fi
done
echo ".pro file fix completed!"]]

    templates.default = [[#!/bin/bash
echo "Custom script template"
echo "Modify this script for your specific needs"]]

    return templates
end

-- Windows脚本模板（简化版）
function M.get_windows_templates(build_system, qt_version)
    local templates = {}
    
    if build_system == "cmake" then
        templates.build = [[@echo off
echo Building Qt project with CMake...
if not exist "build" mkdir build
cd build
cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Debug ..
cmake --build . --config Debug -j 4
echo Build completed successfully!
pause]]

        templates.run = [[@echo off
echo Running Qt project...
cd /d "%~dp0.."
if not exist "build" (
    echo Build directory not found! Please build first.
    pause
    exit /b 1
)
cd build
for %%f in (*.exe) do (
    echo Running %%f...
    %%f
    goto :found
)
echo No executable found!
pause
:found
pause]]

        templates.clean = [[@echo off
echo Cleaning Qt project...
cd /d "%~dp0.."
if exist "build" (
    rmdir /s /q build
    echo Build directory removed.
)
if exist "*.tmp" del /q *.tmp
echo Clean completed!
pause]]

    elseif build_system == "qmake" then
        templates.build = [[@echo off
chcp 65001 >nul
echo Building Qt project with qmake...
cd /d "%~dp0.."

REM Setup MSVC environment first
call "%~dp0setup_msvc.bat" nopause
if errorlevel 1 (
    echo Failed to setup MSVC environment!
    pause
    exit /b 1
)

if not exist "build" mkdir build
cd build

REM Detect compiler and use appropriate make tool
qmake .. -spec win32-msvc
if errorlevel 1 (
    echo qmake configuration failed!
    pause
    exit /b 1
)

REM Try different make tools
where nmake >nul 2>&1
if not errorlevel 1 (
    echo Using nmake...
    nmake
) else (
    where mingw32-make >nul 2>&1
    if not errorlevel 1 (
        echo Using mingw32-make...
        mingw32-make -j 4
    ) else (
        where make >nul 2>&1
        if not errorlevel 1 (
            echo Using make...
            make -j 4
        ) else (
            echo No make tool found! Please install nmake or mingw32-make.
            pause
            exit /b 1
        )
    )
)

echo Build completed successfully!
pause]]
    end

    templates.debug = [[@echo off
echo Debugging Qt project...
cd /d "%~dp0.."
if not exist "build" (
    echo Build directory not found! Please build first.
    pause
    exit /b 1
)
cd build
for %%f in (*.exe) do (
    echo Debugging %%f with gdb...
    gdb %%f
    goto :found
)
:found
pause]]

    templates.test = [[@echo off
echo Running tests...
cd /d "%~dp0.."
if not exist "build" (
    echo Build directory not found! Please build first.
    pause
    exit /b 1
)
cd build
ctest --output-on-failure
echo Tests completed!
pause]]

    templates.deploy = [[@echo off
echo Deploying Qt{{QT_VERSION}} project...
cd /d "%~dp0.."
if not exist "build" (
    echo Build directory not found! Please build first.
    pause
    exit /b 1
)
cd build
if not exist "deploy" mkdir deploy
for %%f in (*.exe) do (
    copy "%%f" deploy\
)
REM Use appropriate deployment tool based on Qt version
echo Using Qt{{QT_VERSION}} deployment tool...
windeployqt deploy\
echo Deployment completed!
pause]]

    templates.setup_clangd = [[@echo off
echo Setting up clangd for Neovim...
cd /d "%~dp0.."

REM Backup existing compile_commands.json if it exists
if exist "compile_commands.json" (
    echo Backing up Qt Creator compile_commands.json...
    copy "compile_commands.json" "compile_commands.json.qtcreator.bak" >nul
)

REM Create .clangd config file
echo Creating .clangd configuration...
(
echo CompileFlags:
echo   Add:
echo     - -std=c++14
echo     - -DQT_WIDGETS_LIB
echo     - -DQT_GUI_LIB
echo     - -DQT_CORE_LIB
echo     - -DQT_SQL_LIB
echo     - -DQT_XML_LIB
echo     - -DUNICODE
echo     - -D_UNICODE
echo     - -DWIN32
echo     - -DWIN64
echo   Remove:
echo     - --driver-mode=*
echo     - /Zs
echo     - /TP
echo     - -nostdinc
echo     - -nostdinc++
echo     - /clang:*
echo     - -fms-compatibility-version=*
) > .clangd

echo .clangd configuration created!
echo.
echo Next steps:
echo 1. Start Neovim from this directory
echo 2. Run :LspRestart to reload clangd
echo 3. Check :LspInfo to verify clangd is working
echo.
pause]]

    templates.fix_pro = [[@echo off
echo Fixing .pro file for Windows MSVC...
cd /d "%~dp0.."

for %%f in (*.pro) do (
    findstr /i "VC_IncludePath" "%%f" >nul
    if errorlevel 1 (
        echo Adding MSVC paths to %%f...
        echo. >> "%%f"
        echo # Windows MSVC paths >> "%%f"
        echo win32:INCLUDEPATH += $$(VC_IncludePath^) >> "%%f"
        echo win32:INCLUDEPATH += $$(WindowsSdkDir^)Include\$$(WindowsSDKVersion^)\ucrt >> "%%f"
    ) else (
        echo %%f already has MSVC paths
    )
)
echo .pro file fix completed!
pause]]

    templates.fix_compile = [[@echo off
echo === Qt Compilation Environment Fix Tool ===
echo.

setlocal enabledelayedexpansion

cd /d "%~dp0.."

echo [1] Setting up MSVC environment...
call "%~dp0setup_msvc.bat" nopause

if errorlevel 1 (
    echo Failed to setup MSVC environment!
    goto :error
)

echo.
echo [2] Cleaning previous build...
if exist "build" (
    echo Removing build directory...
    rmdir /s /q "build"
)

echo.
echo [3] Checking standard library paths...
echo Current INCLUDE paths:
echo !INCLUDE!
echo.

REM 验证type_traits头文件
set "TYPE_TRAITS_FOUND="
for %%I in (!INCLUDE:;= !) do (
    if exist "%%I\type_traits" (
        set "TYPE_TRAITS_FOUND=%%I"
        echo ✓ type_traits found in: %%I
        goto :found_traits
    )
)

echo ✗ type_traits not found in current INCLUDE paths
echo.
echo [4] Manually adding standard library paths...

REM 手动添加标准库路径
if defined VCINSTALLDIR (
    for /d %%D in ("!VCINSTALLDIR!Tools\MSVC\*") do (
        set "MSVC_VER=%%~nxD"
        set "STD_PATH=!VCINSTALLDIR!Tools\MSVC\!MSVC_VER!\include"
        if exist "!STD_PATH!\type_traits" (
            echo Adding MSVC standard library: !STD_PATH!
            set "INCLUDE=!STD_PATH!;!INCLUDE!"
            set "TYPE_TRAITS_FOUND=!STD_PATH!"
            goto :found_traits
        )
    )
)

:found_traits
if not defined TYPE_TRAITS_FOUND (
    echo ERROR: Cannot find type_traits header file!
    echo Please ensure Visual Studio 2017 is properly installed.
    goto :error
)

echo.
echo [5] Creating build directory and configuring...
mkdir build
cd build

echo.
echo [6] Running qmake with fixed environment...
qmake .. -spec win32-msvc

if errorlevel 1 (
    echo qmake failed!
    goto :error
)

echo.
echo [7] Building project with nmake...
nmake

if errorlevel 1 (
    echo nmake failed!
    goto :error
)

echo.
echo === Build completed successfully! ===
echo.
echo Executable should be in:
for %%f in (*.exe) do (
    echo   ✓ %%f
)

if exist "release" (
    for %%f in (release\*.exe) do (
        echo   ✓ release\%%f
    )
)

if exist "debug" (
    for %%f in (debug\*.exe) do (
        echo   ✓ debug\%%f
    )
)

echo.
goto :end

:error
echo.
echo === Build failed! ===
echo.
echo Troubleshooting steps:
echo 1. Run: check_msvc.bat to verify environment
echo 2. Check VS2017 installation: {{CUSTOM_VS2017_PATH}}
echo 3. Verify Qt installation paths
echo 4. Try running setup_msvc.bat manually
echo.

:end
pause]]

    -- 添加缺失的脚本类型模板
    templates.setup_msvc = [[@echo off
REM Setup MSVC Environment - Compatible with Qt version

REM Check if already setup
if defined VCINSTALLDIR (
    echo MSVC environment already configured.
    goto :end
)

setlocal enabledelayedexpansion

echo === Setting up MSVC Environment for Qt ===

REM Detect Qt version from current directory
set "QT_VERSION="
if exist "*.pro" (
    for /f "tokens=*" %%i in ('findstr /i "QT" *.pro 2^>nul') do (
        echo Qt project detected: %%i
    )
)

REM 查找Visual Studio安装路径 (支持用户自定义路径)
set "VCVARSALL="
set "VS_VERSION="

REM 检查用户自定义的VS2017路径 (从配置文件注入)
set "CUSTOM_VS2017={{CUSTOM_VS2017_PATH}}"
if not "!CUSTOM_VS2017!"=="" (
    if exist "!CUSTOM_VS2017!\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=!CUSTOM_VS2017!\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2017"
        echo Using custom VS2017 path: !CUSTOM_VS2017!
        goto :vs_found
    ) else (
        echo Warning: Custom VS2017 path not valid: !CUSTOM_VS2017!
    )
)

REM 检查用户自定义的VS2019路径
set "CUSTOM_VS2019={{CUSTOM_VS2019_PATH}}"
if not "!CUSTOM_VS2019!"=="" (
    if exist "!CUSTOM_VS2019!\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=!CUSTOM_VS2019!\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2019"
        echo Using custom VS2019 path: !CUSTOM_VS2019!
        goto :vs_found
    )
)

REM 检查用户自定义的VS2022路径
set "CUSTOM_VS2022={{CUSTOM_VS2022_PATH}}"
if not "!CUSTOM_VS2022!"=="" (
    if exist "!CUSTOM_VS2022!\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VCVARSALL=!CUSTOM_VS2022!\VC\Auxiliary\Build\vcvarsall.bat"
        set "VS_VERSION=2022"
        echo Using custom VS2022 path: !CUSTOM_VS2022!
        goto :vs_found
    )
)

REM 自动检测Visual Studio (优先使用{{PREFER_VS_VERSION}})
set "PREFER_VERSION={{PREFER_VS_VERSION}}"

REM 根据首选版本顺序查找
if "!PREFER_VERSION!"=="2017" (
    call :find_vs2017
    if not "!VCVARSALL!"=="" goto :vs_found
    call :find_vs2019  
    if not "!VCVARSALL!"=="" goto :vs_found
    call :find_vs2022
) else if "!PREFER_VERSION!"=="2019" (
    call :find_vs2019
    if not "!VCVARSALL!"=="" goto :vs_found
    call :find_vs2017
    if not "!VCVARSALL!"=="" goto :vs_found
    call :find_vs2022
) else (
    call :find_vs2022
    if not "!VCVARSALL!"=="" goto :vs_found
    call :find_vs2019
    if not "!VCVARSALL!"=="" goto :vs_found
    call :find_vs2017
)

goto :check_vs_found

:find_vs2017
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2017"
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2017"
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2017"
)
exit /b

:find_vs2019
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2019"
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2019"
) else if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2019"
)
exit /b

:find_vs2022
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2022"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2022"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"
    set "VS_VERSION=2022"
)
exit /b

:check_vs_found

:vs_found

if "!VCVARSALL!"=="" (
    echo Visual Studio not found! Please install Visual Studio 2017, 2019, or 2022.
    echo For Qt 5.12, Visual Studio 2017 is recommended.
    pause
    exit /b 1
)

echo Found Visual Studio !VS_VERSION! at: !VCVARSALL!

echo Setting up x64 environment...
call "!VCVARSALL!" x64

if errorlevel 1 (
    echo Failed to setup MSVC environment!
    pause
    exit /b 1
)

REM 修复标准库路径问题
if "!VS_VERSION!"=="2017" (
    echo Fixing VS2017 standard library paths...
    
    REM 获取MSVC工具集版本
    for /d %%D in ("!VCINSTALLDIR!Tools\MSVC\*") do set "MSVC_VER=%%~nxD"
    
    REM 设置标准库路径
    set "STD_INCLUDE=!VCINSTALLDIR!Tools\MSVC\!MSVC_VER!\include"
    set "UCRT_INCLUDE=!UniversalCRTSdkDir!Include\!UCRTVersion!\ucrt"
    set "SDK_INCLUDE=!WindowsSdkDir!Include\!WindowsSDKVersion!\um"
    set "SDK_SHARED_INCLUDE=!WindowsSdkDir!Include\!WindowsSDKVersion!\shared"
    
    REM 添加到INCLUDE环境变量前面
    set "INCLUDE=!STD_INCLUDE!;!UCRT_INCLUDE!;!SDK_INCLUDE!;!SDK_SHARED_INCLUDE!;!INCLUDE!"
    
    echo Standard library paths configured:
    echo   MSVC: !STD_INCLUDE!
    echo   UCRT: !UCRT_INCLUDE!
    echo   SDK:  !SDK_INCLUDE!
    echo.
) else if "!VS_VERSION!"=="2022" (
    echo WARNING: Using Visual Studio 2022 with Qt 5.12 may cause compatibility issues.
    echo Setting up compatibility environment...
    set "_CL_=/std:c++14"
)

echo MSVC environment setup completed for Visual Studio !VS_VERSION!!

:end
if "%1"=="nopause" goto :eof
pause]]

    templates.check_msvc = [[@echo off
REM Check MSVC Status

echo === MSVC Environment Status ===
echo.

REM 检查编译器
echo [1] Checking C++ Compiler (cl.exe)...
where cl >nul 2>&1
if not errorlevel 1 (
    echo     ✓ cl.exe found
    cl 2>&1 | findstr "Microsoft" | head -n 1
) else (
    echo     ✗ cl.exe not found
)
echo.

REM 检查nmake
echo [2] Checking Build Tool (nmake.exe)...
where nmake >nul 2>&1
if not errorlevel 1 (
    echo     ✓ nmake.exe found
) else (
    echo     ✗ nmake.exe not found
)
echo.

REM 检查Qt
echo [3] Checking Qt installation...
where qmake >nul 2>&1
if not errorlevel 1 (
    echo     ✓ qmake.exe found
    qmake -v 2>&1 | findstr "Qt version"
) else (
    echo     ✗ qmake.exe not found
)
echo.

REM 检查关键环境变量
echo [4] Checking Environment Variables...
if defined VCINSTALLDIR (
    echo     ✓ VCINSTALLDIR = %VCINSTALLDIR%
) else (
    echo     ✗ VCINSTALLDIR not set
)

if defined INCLUDE (
    echo     ✓ INCLUDE paths configured
    echo       Key paths:
    echo %INCLUDE% | findstr /i "type_traits" >nul 2>&1
    for /f "tokens=1* delims=;" %%a in ("%INCLUDE%") do (
        if exist "%%a\type_traits" (
            echo         ✓ type_traits found in: %%a
        )
    )
) else (
    echo     ✗ INCLUDE not set
)
echo.

REM 检查关键头文件
echo [5] Checking Standard Library Headers...
for /f "tokens=1* delims=;" %%a in ("%INCLUDE%") do (
    if exist "%%a\type_traits" (
        echo     ✓ type_traits found: %%a\type_traits
        goto :found_headers
    )
)
echo     ✗ type_traits not found in INCLUDE paths
:found_headers

echo.
echo To setup MSVC environment, run: setup_msvc.bat
pause]]

    templates.default = [[@echo off
echo Custom script template
pause]]

    return templates
end

-- 写入脚本文件
function M.write_script_file(script_path, content, is_windows)
    local file = io.open(script_path, "w")
    if not file then
        vim.notify("Error: Cannot create script file: " .. script_path, vim.log.levels.ERROR)
        return false
    end
    
    file:write(content)
    file:close()
    
    -- 在Unix系统上设置执行权限
    if not is_windows then
        os.execute("chmod +x '" .. script_path .. "'")
    end
    
    return true
end

-- 列出可用脚本
function M.list_scripts()
    local scripts_dir = M.get_scripts_directory()
    
    if vim.fn.isdirectory(scripts_dir) == 0 then
        return {}
    end
    
    local scripts = {}
    local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
    local script_ext = is_windows and ".bat" or ".sh"
    
    local files = vim.fn.glob(scripts_dir .. "/*" .. script_ext, false, true)
    for _, file in ipairs(files) do
        local name = vim.fn.fnamemodify(file, ":t:r")
        table.insert(scripts, name)
    end
    
    return scripts
end

-- 获取脚本类型信息
function M.get_script_types()
    return script_types
end

-- 获取脚本目录
function M.get_scripts_directory()
    local config = get_config()
    local current_dir = vim.fn.getcwd()  -- 使用当前工作目录而不是配置中的project_root
    local scripts_dir
    
    if config and config.directories and config.directories.scripts then
        scripts_dir = current_dir .. "/" .. config.directories.scripts
    else
        scripts_dir = current_dir .. "/scripts"
    end
    
    return scripts_dir
end

return M