-- Qt Assistant Plugin - 构建管理模块
-- Build management module

local M = {}
local file_manager = require('qt-assistant.file_manager')
local project_manager = require('qt-assistant.project_manager')

-- 获取插件配置
local function get_config()
    return require('qt-assistant').config
end

-- 构建系统配置
local build_systems = {
    cmake = {
        name = "CMake",
        detect_files = {"CMakeLists.txt"},
        configure_cmd = function(build_dir, build_type)
            return {"cmake", "..", "-DCMAKE_BUILD_TYPE=" .. build_type}
        end,
        build_cmd = function(build_dir, parallel_jobs)
            if parallel_jobs and parallel_jobs > 1 then
                return {"cmake", "--build", ".", "--parallel", tostring(parallel_jobs)}
            else
                return {"cmake", "--build", "."}
            end
        end,
        clean_cmd = function(build_dir)
            return {"cmake", "--build", ".", "--target", "clean"}
        end
    },
    qmake = {
        name = "qmake",
        detect_files = {"*.pro"},
        configure_cmd = function(build_dir, build_type)
            local config = build_type == "Debug" and "debug" or "release"
            return {"qmake", "..", "CONFIG+=" .. config}
        end,
        build_cmd = function(build_dir, parallel_jobs)
            if parallel_jobs and parallel_jobs > 1 then
                return {"make", "-j" .. tostring(parallel_jobs)}
            else
                return {"make"}
            end
        end,
        clean_cmd = function(build_dir)
            return {"make", "clean"}
        end
    },
    meson = {
        name = "Meson",
        detect_files = {"meson.build"},
        configure_cmd = function(build_dir, build_type)
            return {"meson", "setup", ".", "..", "--buildtype=" .. build_type:lower()}
        end,
        build_cmd = function(build_dir, parallel_jobs)
            return {"meson", "compile"}
        end,
        clean_cmd = function(build_dir)
            return {"meson", "compile", "--clean"}
        end
    }
}

-- 检测项目构建系统
function M.detect_build_system(project_path)
    project_path = project_path or get_config().project_root
    
    for system_name, system_config in pairs(build_systems) do
        for _, detect_file in ipairs(system_config.detect_files) do
            if detect_file:match("%*") then
                -- 通配符匹配
                local pattern = detect_file:gsub("%*", ".*")
                local handle = vim.loop.fs_scandir(project_path)
                if handle then
                    while true do
                        local name, type = vim.loop.fs_scandir_next(handle)
                        if not name then break end
                        
                        if name:match(pattern) then
                            return system_name, system_config
                        end
                    end
                end
            else
                -- 精确匹配
                if file_manager.file_exists(project_path .. "/" .. detect_file) then
                    return system_name, system_config
                end
            end
        end
    end
    
    return nil, nil
end

-- 构建项目
function M.build_project(build_type)
    local config = get_config()
    local project_root = config.project_root
    
    -- 检测构建系统
    local system_name, system_config = M.detect_build_system(project_root)
    if not system_config then
        vim.notify("No supported build system detected", vim.log.levels.ERROR)
        return false
    end
    
    -- 设置构建类型
    build_type = build_type or config.qt_project.build_type
    local build_dir = project_root .. "/" .. config.qt_project.build_dir
    
    vim.notify(string.format("Building project using %s (%s)...", system_config.name, build_type), vim.log.levels.INFO)
    
    -- 创建构建目录
    local success, error_msg = file_manager.ensure_directory_exists(build_dir)
    if not success then
        vim.notify("Failed to create build directory: " .. error_msg, vim.log.levels.ERROR)
        return false
    end
    
    -- 执行构建过程
    return M.execute_build_process(system_config, build_dir, build_type)
end

-- 执行构建过程
function M.execute_build_process(system_config, build_dir, build_type)
    local config = get_config()
    local system = require('qt-assistant.system')
    
    -- 进入构建目录
    local old_cwd = vim.fn.getcwd()
    vim.cmd("cd " .. vim.fn.fnameescape(build_dir))
    
    local build_success = true
    
    -- 配置阶段
    local configure_cmd = system_config.configure_cmd(build_dir, build_type)
    local adapted_configure_cmd = system.adapt_build_command(configure_cmd)
    vim.notify("Configuring project...", vim.log.levels.INFO)
    
    local configure_success = M.run_build_command(adapted_configure_cmd, "Configure")
    if not configure_success then
        build_success = false
    else
        -- 构建阶段
        local parallel_jobs = config.qt_project.parallel_build and config.qt_project.build_jobs or 1
        local build_cmd = system_config.build_cmd(build_dir, parallel_jobs)
        local adapted_build_cmd = system.adapt_build_command(build_cmd)
        
        vim.notify("Building project...", vim.log.levels.INFO)
        local build_cmd_success = M.run_build_command(adapted_build_cmd, "Build")
        if not build_cmd_success then
            build_success = false
        end
    end
    
    -- 恢复工作目录
    vim.cmd("cd " .. vim.fn.fnameescape(old_cwd))
    
    if build_success then
        vim.notify("Build completed successfully!", vim.log.levels.INFO)
    else
        vim.notify("Build failed!", vim.log.levels.ERROR)
    end
    
    return build_success
end

-- 运行构建命令
function M.run_build_command(cmd, stage_name)
    local output_lines = {}
    local error_lines = {}
    
    local success = false
    local job_id = vim.fn.jobstart(cmd, {
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(output_lines, line)
                        print("[" .. stage_name .. "] " .. line)
                    end
                end
            end
        end,
        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(error_lines, line)
                        vim.notify("[" .. stage_name .. " ERROR] " .. line, vim.log.levels.ERROR)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            success = (exit_code == 0)
        end
    })
    
    if job_id <= 0 then
        vim.notify("Failed to start " .. stage_name:lower() .. " command", vim.log.levels.ERROR)
        return false
    end
    
    -- 等待命令完成
    vim.fn.jobwait({job_id})
    
    -- 保存构建日志
    if #output_lines > 0 or #error_lines > 0 then
        M.save_build_log(stage_name, output_lines, error_lines)
    end
    
    return success
end

-- 运行项目
function M.run_project()
    local config = get_config()
    local build_dir = config.project_root .. "/" .. config.qt_project.build_dir
    
    -- 查找可执行文件
    local executable = M.find_executable(build_dir)
    if not executable then
        vim.notify("No executable found. Please build the project first.", vim.log.levels.ERROR)
        return false
    end
    
    vim.notify("Running: " .. executable, vim.log.levels.INFO)
    
    -- 在终端中运行
    vim.cmd("split")
    vim.cmd("terminal cd " .. vim.fn.shellescape(build_dir) .. " && " .. vim.fn.shellescape(executable))
    
    return true
end

-- 查找可执行文件
function M.find_executable(build_dir)
    if not file_manager.file_exists(build_dir) then
        return nil
    end
    
    local system = require('qt-assistant.system')
    local sys = system.detect_os()
    
    -- 扫描函数
    local function scan_directory(dir)
        local handle = vim.loop.fs_scandir(dir)
        if not handle then
            return {}
        end
        
        local executables = {}
        
        while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then break end
            
            if type == "file" then
                local file_path = system.join_path(dir, name)
                
                if sys.is_windows then
                    -- Windows: 检查.exe文件
                    if name:match("%.exe$") then
                        table.insert(executables, file_path)
                    end
                else
                    -- Unix/Linux/macOS: 检查可执行权限
                    if system.is_executable(file_path) and not name:match("%.") then
                        table.insert(executables, file_path)
                    end
                end
            end
        end
        
        return executables
    end
    
    -- 首先在构建目录根目录查找
    local executables = scan_directory(build_dir)
    
    -- 如果没找到，在常见的子目录中查找
    if #executables == 0 then
        local subdirs = {"Release", "Debug", "bin"}
        for _, subdir in ipairs(subdirs) do
            local subdir_path = system.join_path(build_dir, subdir)
            if file_manager.file_exists(subdir_path) then
                local sub_executables = scan_directory(subdir_path)
                for _, exe in ipairs(sub_executables) do
                    table.insert(executables, exe)
                end
            end
        end
    end
    
    -- 返回第一个找到的可执行文件
    if #executables > 0 then
        return executables[1]
    end
    
    return nil
end

-- 清理项目
function M.clean_project()
    local config = get_config()
    local project_root = config.project_root
    local build_dir = project_root .. "/" .. config.qt_project.build_dir
    
    -- 检测构建系统
    local system_name, system_config = M.detect_build_system(project_root)
    
    if system_config and file_manager.file_exists(build_dir) then
        -- 使用构建系统的清理命令
        local old_cwd = vim.fn.getcwd() 
        vim.cmd("cd " .. vim.fn.fnameescape(build_dir))
        
        local clean_cmd = system_config.clean_cmd(build_dir)
        vim.notify("Cleaning project...", vim.log.levels.INFO)
        
        local success = M.run_build_command(clean_cmd, "Clean")
        
        vim.cmd("cd " .. vim.fn.fnameescape(old_cwd))
        
        if success then
            vim.notify("Project cleaned successfully!", vim.log.levels.INFO)
        else
            vim.notify("Clean failed, removing build directory...", vim.log.levels.WARN)
            M.remove_build_directory()
        end
    else
        -- 直接删除构建目录
        M.remove_build_directory()
    end
    
    return true
end

-- 删除构建目录
function M.remove_build_directory()
    local config = get_config()
    local system = require('qt-assistant.system')
    local sys = system.detect_os()
    local build_dir = system.join_path(config.project_root, config.qt_project.build_dir)
    
    if file_manager.file_exists(build_dir) then
        vim.notify("Removing build directory: " .. build_dir, vim.log.levels.INFO)
        
        -- 使用系统命令删除目录
        local rm_cmd
        if sys.is_windows then
            rm_cmd = {"cmd", "/c", "rmdir", "/s", "/q", build_dir}
        else
            rm_cmd = {"rm", "-rf", build_dir}
        end
        
        local job_id = vim.fn.jobstart(rm_cmd, {
            on_exit = function(_, exit_code)
                if exit_code == 0 then
                    vim.notify("Build directory removed successfully!", vim.log.levels.INFO)
                else
                    vim.notify("Failed to remove build directory", vim.log.levels.ERROR)
                end
            end
        })
        
        if job_id <= 0 then
            vim.notify("Failed to start remove command", vim.log.levels.ERROR)
        end
    else
        vim.notify("Build directory does not exist", vim.log.levels.INFO)
    end
end

-- 保存构建日志
function M.save_build_log(stage_name, output_lines, error_lines)
    local config = get_config()
    if not config.debug.enabled then
        return
    end
    
    local log_file = config.debug.log_file
    local log_dir = vim.fn.fnamemodify(log_file, ":h")
    
    -- 确保日志目录存在
    file_manager.ensure_directory_exists(log_dir)
    
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local log_content = string.format("\n=== %s - %s ===\n", stage_name, timestamp)
    
    if #output_lines > 0 then
        log_content = log_content .. "STDOUT:\n" .. table.concat(output_lines, "\n") .. "\n"
    end
    
    if #error_lines > 0 then
        log_content = log_content .. "STDERR:\n" .. table.concat(error_lines, "\n") .. "\n"
    end
    
    -- 追加到日志文件
    local file = io.open(log_file, "a")
    if file then
        file:write(log_content)
        file:close()
    end
end

-- 获取构建状态
function M.get_build_status()
    local config = get_config()
    local project_root = config.project_root
    local build_dir = project_root .. "/" .. config.qt_project.build_dir
    
    local status = {
        build_system = nil,
        build_dir_exists = file_manager.file_exists(build_dir),
        executable_exists = false,
        last_build_time = nil
    }
    
    -- 检测构建系统
    local system_name, system_config = M.detect_build_system(project_root)
    if system_config then
        status.build_system = system_config.name
    end
    
    -- 检查可执行文件
    if status.build_dir_exists then
        local executable = M.find_executable(build_dir)
        status.executable_exists = executable ~= nil
        status.executable_path = executable
        
        -- 获取构建时间
        if executable then
            local stat = vim.loop.fs_stat(executable)
            if stat then
                status.last_build_time = stat.mtime.sec
            end
        end
    end
    
    return status
end

-- 显示构建状态
function M.show_build_status()
    local status = M.get_build_status()
    
    local status_lines = {}
    table.insert(status_lines, "=== Build Status ===")
    table.insert(status_lines, "")
    
    if status.build_system then
        table.insert(status_lines, "Build System: " .. status.build_system)
    else
        table.insert(status_lines, "Build System: Not detected")
    end
    
    table.insert(status_lines, "Build Directory: " .. (status.build_dir_exists and "EXISTS" or "NOT FOUND"))
    table.insert(status_lines, "Executable: " .. (status.executable_exists and "EXISTS" or "NOT FOUND"))
    
    if status.executable_path then
        table.insert(status_lines, "Executable Path: " .. file_manager.get_relative_path(status.executable_path))
    end
    
    if status.last_build_time then
        local build_time = os.date('%Y-%m-%d %H:%M:%S', status.last_build_time)
        table.insert(status_lines, "Last Build: " .. build_time)
    end
    
    table.insert(status_lines, "")
    table.insert(status_lines, "Available Actions:")
    table.insert(status_lines, "  b - Build project")
    table.insert(status_lines, "  r - Run project")
    table.insert(status_lines, "  c - Clean project")
    table.insert(status_lines, "  q - Close")
    
    -- 显示状态窗口
    M.show_status_window(status_lines, status)
end

-- 显示状态窗口
function M.show_status_window(lines, status)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    local width = 60
    local height = math.min(#lines + 2, 20)
    
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
    
    local function close_window()
        vim.api.nvim_win_close(win, true)
    end
    
    -- 设置键盘映射
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        callback = close_window,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
        callback = close_window,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'b', '', {
        callback = function()
            close_window()
            M.build_project()
        end,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'r', '', {
        callback = function()
            close_window()
            M.run_project()
        end,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'c', '', {
        callback = function()
            close_window()
            M.clean_project()
        end,
        noremap = true,
        silent = true
    })
end

return M