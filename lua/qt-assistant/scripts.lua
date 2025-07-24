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
make -j$(nproc)

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
REM Qt项目构建脚本

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~dp0.."
set "BUILD_DIR=%PROJECT_DIR%\build"

echo === Building Qt Project ===
echo Project directory: %PROJECT_DIR%
echo Build directory: %BUILD_DIR%

REM 创建构建目录
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

REM 运行CMake配置
echo Running CMake configuration...
cmake .. -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

REM 编译项目
echo Building project...
cmake --build . --config Release
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

REM 检查构建目录是否存在
if not exist "%BUILD_DIR%" (
    echo Build directory does not exist. Please build the project first.
    echo Run: build.bat
    pause
    exit /b 1
)

cd /d "%BUILD_DIR%"

REM 查找可执行文件
for %%f in (*.exe) do (
    set "EXECUTABLE=%%f"
    goto :found
)

REM 在Release目录中查找
if exist "Release" (
    cd Release
    for %%f in (*.exe) do (
        set "EXECUTABLE=%%f"
        goto :found
    )
)

REM 在Debug目录中查找
if exist "..\Debug" (
    cd ..\Debug
    for %%f in (*.exe) do (
        set "EXECUTABLE=%%f"
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

REM 检查构建目录是否存在
if not exist "%BUILD_DIR%" (
    echo Build directory does not exist. Please build the project first.
    echo Run: build.bat
    pause
    exit /b 1
)

cd /d "%BUILD_DIR%"

REM 查找可执行文件
for %%f in (*.exe) do (
    set "EXECUTABLE=%%f"
    goto :found
)

REM 在Debug目录中查找
if exist "Debug" (
    cd Debug
    for %%f in (*.exe) do (
        set "EXECUTABLE=%%f"
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

REM 检查构建目录是否存在
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

    -- 写入Windows脚本文件
    local scripts = {
        ["build.bat"] = build_script,
        ["clean.bat"] = clean_script,
        ["run.bat"] = run_script,
        ["debug.bat"] = debug_script,
        ["test.bat"] = test_script
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

return M