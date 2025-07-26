-- Qt Assistant Plugin - Qt版本检测模块
-- Qt version detection module

local M = {}
local file_manager = require('qt-assistant.file_manager')

-- Qt版本信息
local qt_versions = {
    qt5 = {
        name = "Qt5",
        cmake_minimum = "3.5",
        cxx_standard = "14",
        find_package = "Qt5",
        components = {"Core", "Widgets", "Gui"},
        standard_setup = false,
        executable_function = "qt5_add_executable",
        wrap_ui_function = "qt5_wrap_ui",
        add_resources_function = "qt5_add_resources",
        link_prefix = "Qt5::",
    },
    qt6 = {
        name = "Qt6", 
        cmake_minimum = "3.16",
        cxx_standard = "17",
        find_package = "Qt6",
        components = {"Core", "Widgets", "Gui"},
        standard_setup = true,
        executable_function = "qt6_add_executable",
        wrap_ui_function = "qt6_wrap_ui", 
        add_resources_function = "qt6_add_resources",
        link_prefix = "Qt6::",
    }
}

-- 获取系统信息
local function get_system_info()
    local system = require('qt-assistant.system')
    return system.detect_os()
end

-- Windows下查找Qt安装路径
local function find_qt_on_windows()
    local qt_paths = {}
    
    -- 常见的Qt安装路径
    local common_paths = {
        "C:\\Qt",
        "C:\\Program Files\\Qt",
        "C:\\Program Files (x86)\\Qt",
        "D:\\Qt",
        "E:\\Qt",
    }
    
    -- 从环境变量中获取
    local qt_dir = os.getenv("QTDIR")
    if qt_dir then
        table.insert(common_paths, 1, qt_dir)
    end
    
    local qt_root = os.getenv("QT_ROOT")
    if qt_root then
        table.insert(common_paths, 1, qt_root)
    end
    
    for _, base_path in ipairs(common_paths) do
        if file_manager.file_exists(base_path) then
            -- 扫描Qt版本目录
            local handle = vim.loop.fs_scandir(base_path)
            if handle then
                while true do
                    local name, type = vim.loop.fs_scandir_next(handle)
                    if not name then break end
                    
                    if type == "directory" then
                        -- 检查是否是Qt版本目录 (如: 5.15.2, 6.2.0)
                        if name:match("^%d+%.%d+") then
                            local version_path = base_path .. "\\" .. name
                            local version_info = M.detect_qt_version_from_path(version_path)
                            if version_info then
                                qt_paths[version_info.major_version] = {
                                    path = version_path,
                                    version = version_info.version,
                                    major = version_info.major_version
                                }
                            end
                        end
                    end
                end
            end
        end
    end
    
    return qt_paths
end

-- 从路径检测Qt版本
function M.detect_qt_version_from_path(qt_path)
    if not qt_path or not file_manager.file_exists(qt_path) then
        return nil
    end
    
    -- 查找qmake可执行文件
    local sys = get_system_info()
    local qmake_name = sys.is_windows and "qmake.exe" or "qmake"
    
    -- 常见的qmake路径
    local qmake_paths = {
        qt_path .. (sys.is_windows and "\\bin\\" or "/bin/") .. qmake_name,
        qt_path .. (sys.is_windows and "\\msvc2019_64\\bin\\" or "/gcc_64/bin/") .. qmake_name,
        qt_path .. (sys.is_windows and "\\msvc2017_64\\bin\\" or "/clang_64/bin/") .. qmake_name,
        qt_path .. (sys.is_windows and "\\mingw81_64\\bin\\" or "/mingw73_64/bin/") .. qmake_name,
    }
    
    for _, qmake_path in ipairs(qmake_paths) do
        if file_manager.file_exists(qmake_path) then
            -- 执行qmake -v获取版本信息
            local handle = io.popen('"' .. qmake_path .. '" -v 2>&1')
            if handle then
                local output = handle:read("*a")
                handle:close()
                
                -- 解析版本信息
                local version = output:match("Qt version (%d+%.%d+%.%d+)")
                if version then
                    local major = version:match("^(%d+)")
                    return {
                        version = version,
                        major_version = tonumber(major),
                        qmake_path = qmake_path,
                        qt_path = qt_path
                    }
                end
            end
        end
    end
    
    return nil
end

-- 从CMakeLists.txt检测Qt版本
function M.detect_qt_version_from_cmake(project_path)
    local cmake_file = project_path .. "/CMakeLists.txt"
    if not file_manager.file_exists(cmake_file) then
        return nil
    end
    
    local file = io.open(cmake_file, "r")
    if not file then
        return nil
    end
    
    local content = file:read("*a")
    file:close()
    
    -- 查找find_package(Qt5)或find_package(Qt6)
    local qt5_found = content:match("find_package%s*%(%s*Qt5")
    local qt6_found = content:match("find_package%s*%(%s*Qt6")
    
    if qt6_found then
        return 6
    elseif qt5_found then
        return 5
    end
    
    return nil
end

-- 自动检测系统中的Qt版本
function M.auto_detect_qt_version(project_path)
    local detected_versions = {}
    
    -- 1. 首先从项目CMakeLists.txt检测
    if project_path then
        local cmake_version = M.detect_qt_version_from_cmake(project_path)
        if cmake_version then
            detected_versions.cmake_preferred = cmake_version
        end
    end
    
    -- 2. 检测系统中安装的Qt版本
    local sys = get_system_info()
    
    if sys.is_windows then
        -- Windows: 扫描常见安装路径
        local qt_paths = find_qt_on_windows()
        detected_versions.system_qt = qt_paths
    else
        -- Linux/macOS: 使用which命令查找
        local qmake_paths = {"qmake", "qmake-qt5", "qmake-qt6"}
        
        for _, qmake_cmd in ipairs(qmake_paths) do
            local handle = io.popen("which " .. qmake_cmd .. " 2>/dev/null")
            if handle then
                local qmake_path = handle:read("*a"):gsub("%s+", "")
                handle:close()
                
                if qmake_path ~= "" then
                    local version_info = M.detect_qt_version_from_path(qmake_path:gsub("/bin/.*", ""))
                    if version_info then
                        detected_versions.system_qt = detected_versions.system_qt or {}
                        detected_versions.system_qt[version_info.major_version] = {
                            path = version_info.qt_path,
                            version = version_info.version,
                            major = version_info.major_version,
                            qmake_path = version_info.qmake_path
                        }
                    end
                end
            end
        end
    end
    
    return detected_versions
end

-- 获取Qt版本配置
function M.get_qt_config(version)
    local version_key = "qt" .. tostring(version)
    return qt_versions[version_key]
end

-- 获取推荐的Qt版本
function M.get_recommended_qt_version(project_path)
    local detected = M.auto_detect_qt_version(project_path)
    
    -- 优先使用CMakeLists.txt中指定的版本
    if detected.cmake_preferred then
        return detected.cmake_preferred
    end
    
    -- 如果系统中有Qt版本，优先选择Qt6，然后Qt5
    if detected.system_qt then
        if detected.system_qt[6] then
            return 6
        elseif detected.system_qt[5] then
            return 5
        end
    end
    
    -- 默认返回Qt6
    return 6
end

-- 设置Qt环境变量（Windows）
function M.setup_qt_environment(qt_version, qt_path)
    local sys = get_system_info()
    
    if not sys.is_windows or not qt_path then
        return true
    end
    
    -- 查找合适的编译器工具链目录
    local toolchain_dirs = {
        "msvc2019_64",
        "msvc2017_64", 
        "msvc2015_64",
        "mingw81_64",
        "mingw73_64"
    }
    
    local selected_toolchain = nil
    for _, toolchain in ipairs(toolchain_dirs) do
        local toolchain_path = qt_path .. "\\" .. toolchain
        if file_manager.file_exists(toolchain_path) then
            selected_toolchain = toolchain_path
            break
        end
    end
    
    if not selected_toolchain then
        vim.notify("No suitable Qt toolchain found in " .. qt_path, vim.log.levels.WARN)
        return false
    end
    
    -- 设置环境变量
    local qt_bin_path = selected_toolchain .. "\\bin"
    local qt_lib_path = selected_toolchain .. "\\lib"
    
    -- 添加到PATH
    local current_path = os.getenv("PATH") or ""
    if not current_path:find(qt_bin_path, 1, true) then
        vim.fn.setenv("PATH", qt_bin_path .. ";" .. current_path)
    end
    
    -- 设置Qt相关环境变量
    vim.fn.setenv("QTDIR", selected_toolchain)
    vim.fn.setenv("Qt" .. qt_version .. "_DIR", selected_toolchain)
    
    vim.notify("Qt" .. qt_version .. " environment configured: " .. selected_toolchain, vim.log.levels.INFO)
    return true
end

-- 显示Qt版本信息
function M.show_qt_version_info(project_path)
    local detected = M.auto_detect_qt_version(project_path)
    local recommended = M.get_recommended_qt_version(project_path)
    
    local info_lines = {}
    table.insert(info_lines, "=== Qt Version Information ===")
    table.insert(info_lines, "")
    
    if detected.cmake_preferred then
        table.insert(info_lines, "Project CMake Qt Version: Qt" .. detected.cmake_preferred)
    else
        table.insert(info_lines, "Project CMake Qt Version: Not specified")
    end
    
    table.insert(info_lines, "Recommended Qt Version: Qt" .. recommended)
    table.insert(info_lines, "")
    
    if detected.system_qt then
        table.insert(info_lines, "System Qt Installations:")
        for version, info in pairs(detected.system_qt) do
            table.insert(info_lines, string.format("  Qt%d: %s (%s)", version, info.version, info.path))
        end
    else
        table.insert(info_lines, "System Qt Installations: None found")
    end
    
    -- 显示信息窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, info_lines)
    
    local width = 60
    local height = math.min(#info_lines + 4, 20)
    
    local win_config = {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded'
    }
    
    local win = vim.api.nvim_open_win(buf, true, win_config)
    
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    -- 按q关闭
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>close<cr>', {
        noremap = true,
        silent = true
    })
end

return M