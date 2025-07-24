-- Qt Assistant Plugin - 系统适配模块
-- System compatibility module

local M = {}

-- 系统信息缓存
local system_info = nil

-- 检测操作系统类型
function M.detect_os()
    if system_info then
        return system_info
    end
    
    local os_name = vim.loop.os_uname().sysname:lower()
    
    if os_name:match("windows") or vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        system_info = {
            type = "windows",
            name = "Windows",
            is_windows = true,
            is_macos = false,
            is_linux = false,
            is_unix = false,
            path_separator = "\\",
            path_delimiter = ";",
            executable_ext = ".exe",
            script_ext = ".bat"
        }
    elseif os_name:match("darwin") or os_name:match("macos") then
        system_info = {
            type = "macos", 
            name = "macOS",
            is_windows = false,
            is_macos = true,
            is_linux = false,
            is_unix = true,
            path_separator = "/",
            path_delimiter = ":",
            executable_ext = "",
            script_ext = ".sh"
        }
    else
        -- 默认为Linux/Unix
        system_info = {
            type = "linux",
            name = "Linux",
            is_windows = false,
            is_macos = false,
            is_linux = true,
            is_unix = true,
            path_separator = "/",
            path_delimiter = ":",
            executable_ext = "",
            script_ext = ".sh"
        }
    end
    
    return system_info
end

-- 规范化路径分隔符
function M.normalize_path(path)
    if not path then return nil end
    
    local sys = M.detect_os()
    if sys.is_windows then
        return path:gsub("/", "\\")
    else
        return path:gsub("\\", "/")
    end
end

-- 连接路径
function M.join_path(...)
    local parts = {...}
    local sys = M.detect_os()
    local separator = sys.path_separator
    
    -- 过滤空值
    local valid_parts = {}
    for _, part in ipairs(parts) do
        if part and part ~= "" then
            table.insert(valid_parts, tostring(part))
        end
    end
    
    if #valid_parts == 0 then
        return ""
    end
    
    local path = table.concat(valid_parts, separator)
    return M.normalize_path(path)
end

-- 获取可执行文件名（添加适当的扩展名）
function M.get_executable_name(name)
    local sys = M.detect_os()
    return name .. sys.executable_ext
end

-- 获取脚本文件名（添加适当的扩展名）
function M.get_script_name(name)
    local sys = M.detect_os()
    return name .. sys.script_ext
end

-- 检查文件是否可执行
function M.is_executable(file_path)
    if not file_path then return false end
    
    local sys = M.detect_os()
    
    if sys.is_windows then
        -- Windows: 检查文件是否存在且有正确的扩展名
        local stat = vim.loop.fs_stat(file_path)
        if not stat or stat.type ~= "file" then
            return false
        end
        
        local ext = file_path:match("%.([^%.]+)$")
        if ext then
            ext = ext:lower()
            return ext == "exe" or ext == "bat" or ext == "cmd" or ext == "com"
        end
        return false
    else
        -- Unix/Linux/macOS: 检查执行权限
        local stat = vim.loop.fs_stat(file_path)
        if not stat or stat.type ~= "file" then
            return false
        end
        
        -- 检查owner execute bit
        return (stat.mode % 512) >= 256
    end
end

-- 设置文件为可执行
function M.make_executable(file_path)
    if not file_path then return false end
    
    local sys = M.detect_os()
    
    if sys.is_windows then
        -- Windows: 文件权限由扩展名决定，无需额外操作
        return true
    else
        -- Unix/Linux/macOS: 使用chmod设置执行权限
        local result = os.execute("chmod +x " .. vim.fn.shellescape(file_path))
        return result == 0
    end
end

-- 查找可执行文件路径
function M.find_executable(exe_name)
    local sys = M.detect_os()
    local exe_with_ext = M.get_executable_name(exe_name)
    
    -- 首先检查是否为绝对路径
    if M.is_executable(exe_name) then
        return exe_name
    end
    
    if M.is_executable(exe_with_ext) then
        return exe_with_ext
    end
    
    -- 在PATH中搜索
    local path_env = os.getenv("PATH") or ""
    local paths = vim.split(path_env, sys.path_delimiter)
    
    for _, path in ipairs(paths) do
        if path and path ~= "" then
            local full_path = M.join_path(path, exe_with_ext)
            if M.is_executable(full_path) then
                return full_path
            end
            
            -- 也尝试不带扩展名的版本
            local full_path_no_ext = M.join_path(path, exe_name)
            if M.is_executable(full_path_no_ext) then
                return full_path_no_ext
            end
        end
    end
    
    return nil
end

-- 获取Qt工具的默认路径
function M.get_qt_tool_paths()
    local sys = M.detect_os()
    local paths = {}
    
    if sys.is_windows then
        paths = {
            -- Qt官方安装路径
            "C:\\Qt\\Tools\\QtCreator\\bin",
            "C:\\Qt\\6.5.0\\msvc2019_64\\bin",
            "C:\\Qt\\6.4.0\\msvc2019_64\\bin", 
            "C:\\Qt\\5.15.2\\msvc2019_64\\bin",
            -- 可能的用户安装路径
            os.getenv("USERPROFILE") .. "\\Qt\\Tools\\QtCreator\\bin",
            -- vcpkg路径
            "C:\\vcpkg\\installed\\x64-windows\\tools\\qt5",
            -- Chocolatey路径
            "C:\\ProgramData\\chocolatey\\lib\\qt-creator\\tools",
        }
    elseif sys.is_macos then
        paths = {
            -- Qt官方安装路径
            "/Applications/Qt Creator.app/Contents/MacOS",
            "/Applications/Qt Creator.app/Contents/bin",
            "/Users/" .. os.getenv("USER") .. "/Qt/Tools/QtCreator/bin",
            "/Users/" .. os.getenv("USER") .. "/Qt/6.5.0/macos/bin",
            -- Homebrew路径
            "/usr/local/bin",
            "/opt/homebrew/bin",
            "/usr/local/opt/qt/bin",
            "/opt/homebrew/opt/qt@6/bin",
            "/opt/homebrew/opt/qt@5/bin",
            -- MacPorts路径
            "/opt/local/bin",
        }
    else -- Linux
        paths = {
            -- 系统包管理器路径
            "/usr/bin",
            "/usr/local/bin",
            -- Qt官方安装路径
            "/opt/Qt/Tools/QtCreator/bin",
            "/opt/Qt/6.5.0/gcc_64/bin",
            "/opt/Qt/5.15.2/gcc_64/bin",
            -- 用户安装路径
            os.getenv("HOME") .. "/Qt/Tools/QtCreator/bin",
            os.getenv("HOME") .. "/Qt/6.5.0/gcc_64/bin",
            -- Snap路径
            "/snap/bin",
            -- Flatpak路径
            "/var/lib/flatpak/exports/bin",
            os.getenv("HOME") .. "/.local/share/flatpak/exports/bin",
        }
    end
    
    return paths
end

-- 智能查找Qt工具
function M.find_qt_tool(tool_name)
    -- 首先在PATH中查找
    local found_path = M.find_executable(tool_name)
    if found_path then
        return found_path
    end
    
    -- 在Qt默认路径中查找
    local qt_paths = M.get_qt_tool_paths()
    for _, path in ipairs(qt_paths) do
        local tool_path = M.join_path(path, M.get_executable_name(tool_name))
        if M.is_executable(tool_path) then
            return tool_path
        end
        
        -- 也尝试不带扩展名的版本
        local tool_path_no_ext = M.join_path(path, tool_name)
        if M.is_executable(tool_path_no_ext) then
            return tool_path_no_ext
        end
    end
    
    return nil
end

-- 获取Shell命令
function M.get_shell_command()
    local sys = M.detect_os()
    
    if sys.is_windows then
        return "cmd.exe"
    else  
        return os.getenv("SHELL") or "/bin/bash"
    end
end

-- 获取Shell执行参数
function M.get_shell_args(command)
    local sys = M.detect_os()
    
    if sys.is_windows then
        return {"/c", command}
    else
        return {"-c", command}
    end
end

-- 构建系统命令适配
function M.adapt_build_command(cmd_table)
    local sys = M.detect_os()
    local adapted_cmd = {}
    
    for i, arg in ipairs(cmd_table) do
        if i == 1 then
            -- 第一个参数是命令，需要查找可执行文件
            local exe_path = M.find_executable(arg)
            table.insert(adapted_cmd, exe_path or arg)
        else
            -- 其他参数保持不变，但路径需要规范化
            if arg:match("[/\\]") then
                table.insert(adapted_cmd, M.normalize_path(arg))
            else
                table.insert(adapted_cmd, arg)
            end
        end
    end
    
    return adapted_cmd
end

-- 获取临时目录
function M.get_temp_dir()
    local sys = M.detect_os()
    
    if sys.is_windows then
        return os.getenv("TEMP") or os.getenv("TMP") or "C:\\Windows\\Temp"
    else
        return os.getenv("TMPDIR") or "/tmp"
    end
end

-- 获取用户主目录
function M.get_home_dir()
    local sys = M.detect_os()
    
    if sys.is_windows then
        return os.getenv("USERPROFILE") or "C:\\Users\\Default"
    else
        return os.getenv("HOME") or "/tmp"
    end
end

-- 获取应用数据目录
function M.get_app_data_dir()
    local sys = M.detect_os()
    
    if sys.is_windows then
        return os.getenv("APPDATA") or (M.get_home_dir() .. "\\AppData\\Roaming")
    elseif sys.is_macos then
        return M.get_home_dir() .. "/Library/Application Support"
    else
        return os.getenv("XDG_DATA_HOME") or (M.get_home_dir() .. "/.local/share")
    end
end

-- 获取配置目录
function M.get_config_dir()
    local sys = M.detect_os()
    
    if sys.is_windows then
        return os.getenv("APPDATA") or (M.get_home_dir() .. "\\AppData\\Roaming")
    elseif sys.is_macos then
        return M.get_home_dir() .. "/Library/Preferences"
    else
        return os.getenv("XDG_CONFIG_HOME") or (M.get_home_dir() .. "/.config")
    end
end

-- 环境变量处理
function M.expand_env_vars(path)
    if not path then return nil end
    
    local sys = M.detect_os()
    
    if sys.is_windows then
        -- Windows环境变量格式: %VAR%
        return path:gsub("%%([^%%]+)%%", function(var)
            return os.getenv(var) or ("%" .. var .. "%")
        end)
    else
        -- Unix环境变量格式: $VAR 或 ${VAR}
        path = path:gsub("%$%{([^}]+)%}", function(var)
            return os.getenv(var) or ("${" .. var .. "}")
        end)
        path = path:gsub("%$([%w_]+)", function(var)
            return os.getenv(var) or ("$" .. var)
        end)
        return path
    end
end

-- 获取系统信息摘要
function M.get_system_info()
    local sys = M.detect_os()
    local uname = vim.loop.os_uname()
    
    return {
        os = sys.name,
        type = sys.type,
        arch = uname.machine,
        version = uname.release,
        hostname = uname.nodename,
        neovim_version = vim.version(),
        path_separator = sys.path_separator,
        executable_ext = sys.executable_ext,
        script_ext = sys.script_ext
    }
end

-- 显示系统信息
function M.show_system_info()
    local info = M.get_system_info()
    local qt_tools = {
        designer = M.find_qt_tool("designer"),
        qtcreator = M.find_qt_tool("qtcreator"),
        qmake = M.find_qt_tool("qmake"),
        cmake = M.find_executable("cmake")
    }
    
    local info_lines = {}
    table.insert(info_lines, "=== System Information ===")
    table.insert(info_lines, "")
    table.insert(info_lines, "Operating System: " .. info.os)
    table.insert(info_lines, "Architecture: " .. info.arch)
    table.insert(info_lines, "Version: " .. info.version) 
    table.insert(info_lines, "Hostname: " .. info.hostname)
    table.insert(info_lines, "Neovim Version: " .. tostring(info.neovim_version))
    table.insert(info_lines, "")
    table.insert(info_lines, "Path Separator: " .. info.path_separator)
    table.insert(info_lines, "Executable Extension: " .. (info.executable_ext ~= "" and info.executable_ext or "(none)"))
    table.insert(info_lines, "Script Extension: " .. info.script_ext)
    table.insert(info_lines, "")
    table.insert(info_lines, "Qt Tools:")
    for tool, path in pairs(qt_tools) do
        local status = path and "FOUND" or "NOT FOUND"
        local display_path = path or "N/A"
        table.insert(info_lines, string.format("  %s: %s", tool, status))
        if path then
            table.insert(info_lines, string.format("    Path: %s", display_path))
        end
    end
    table.insert(info_lines, "")
    table.insert(info_lines, "Press 'q' or <Esc> to close")
    
    -- 显示信息窗口
    local ui = require('qt-assistant.ui')
    if ui and ui.show_info_window then
        ui.show_info_window(info_lines)
    else
        -- 备用显示方法
        for _, line in ipairs(info_lines) do
            print(line)
        end
    end
end

return M