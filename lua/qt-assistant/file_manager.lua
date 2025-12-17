-- Qt Assistant Plugin - 文件管理模块
-- File management module

local M = {}

-- Get the project root directory
function M.get_project_root()
    local system = require('qt-assistant.system')
    local current_dir = system.normalize_path(vim.fn.getcwd())
    while current_dir ~= "" do
        local git_dir = system.join_path(current_dir, ".git")
        local cmake_file = system.join_path(current_dir, "CMakeLists.txt")
        if vim.fn.isdirectory(git_dir) == 1 or vim.fn.filereadable(cmake_file) == 1 then
            return current_dir
        end
        local parent = vim.fn.fnamemodify(current_dir, ":h")
        if parent == current_dir then
            break
        end
        current_dir = parent
    end
    return nil -- Project root not found
end

-- 获取插件配置
local function get_config()
    -- 安全地获取配置，避免循环依赖
    local ok, config_module = pcall(require, 'qt-assistant.config')
    if ok then
        return config_module.get()
    else
        -- 返回默认配置
        return {
            project_root = vim.fn.getcwd(),
            directories = {
                source = "src",
                include = "include", 
                ui = "ui",
                resource = "resource",
                scripts = "scripts"
            },
            naming_convention = "snake_case"
        }
    end
end

-- 类名转换为文件名
function M.class_name_to_filename(class_name)
    local config = get_config()
    
    if config.naming_convention == "snake_case" then
        -- 将驼峰命名转换为下划线命名
        return class_name:gsub("(%u)", function(c)
            return "_" .. c:lower()
        end):gsub("^_", ""):lower()
    else
        -- 保持驼峰命名，首字母小写
        return class_name:sub(1,1):lower() .. class_name:sub(2)
    end
end

-- 确定目标目录
function M.determine_target_directories(class_type, opts)
    local config = get_config()
    local system = require('qt-assistant.system')
    local project_root = config.project_root
    local dirs = config.directories
    local subdir = opts and opts.target_subdir
    local custom_dir = opts and opts.custom_dir

    -- If user specified a custom directory, place all generated files there
    if custom_dir and custom_dir ~= '' then
        return {
            header = custom_dir,
            source = custom_dir,
            ui = custom_dir
        }
    end

    local function with_subdir(base)
        if subdir and subdir ~= '' then
            return system.join_path(base, subdir)
        end
        return base
    end
    
    local target_dirs = {}
    
    if class_type == "main_window" or class_type == "dialog" or class_type == "widget" then
        target_dirs.header = with_subdir(system.join_path(project_root, dirs.include, "ui"))
        target_dirs.source = with_subdir(system.join_path(project_root, dirs.source, "ui"))
        target_dirs.ui = with_subdir(system.join_path(project_root, dirs.ui))
    elseif class_type == "model" or class_type == "delegate" then
        target_dirs.header = with_subdir(system.join_path(project_root, dirs.include, "core"))
        target_dirs.source = with_subdir(system.join_path(project_root, dirs.source, "core"))
    elseif class_type == "thread" then
        target_dirs.header = with_subdir(system.join_path(project_root, dirs.include, "core"))
        target_dirs.source = with_subdir(system.join_path(project_root, dirs.source, "core"))
    elseif class_type == "utility" or class_type == "singleton" then
        target_dirs.header = with_subdir(system.join_path(project_root, dirs.include, "utils"))
        target_dirs.source = with_subdir(system.join_path(project_root, dirs.source, "utils"))
    else
        -- 默认目录
        target_dirs.header = with_subdir(system.join_path(project_root, dirs.include))
        target_dirs.source = with_subdir(system.join_path(project_root, dirs.source))
        target_dirs.ui = with_subdir(system.join_path(project_root, dirs.ui))
    end
    
    return target_dirs
end

-- 创建目录（如果不存在）
function M.ensure_directory_exists(dir_path)
    local stat = vim.loop.fs_stat(dir_path)
    if not stat then
        local success = vim.fn.mkdir(dir_path, "p")
        if success == 0 then
            return false, "Failed to create directory: " .. dir_path
        end
    elseif stat.type ~= "directory" then
        return false, "Path exists but is not a directory: " .. dir_path
    end
    
    return true
end

-- 检查文件是否存在
function M.file_exists(file_path)
    local stat = vim.loop.fs_stat(file_path)
    return stat and stat.type == "file"
end

-- 检查目录是否存在
function M.directory_exists(dir_path)
    local stat = vim.loop.fs_stat(dir_path)
    return stat and stat.type == "directory"
end

-- Copy a file (best-effort cross-platform)
function M.copy_file(src_path, dst_path)
    if not src_path or src_path == '' or not dst_path or dst_path == '' then
        return false, 'Invalid source/destination'
    end

    local dst_dir = vim.fn.fnamemodify(dst_path, ":h")
    local ok, err = M.ensure_directory_exists(dst_dir)
    if not ok then
        return false, err
    end

    local ok_copy, copy_err = pcall(function()
        vim.loop.fs_copyfile(src_path, dst_path)
    end)
    if not ok_copy then
        return false, copy_err
    end

    return true
end

-- 创建文件
function M.create_files(files, target_dirs)
    -- 确保目标目录存在
    for dir_type, dir_path in pairs(target_dirs) do
        local success, error_msg = M.ensure_directory_exists(dir_path)
        if not success then
            return false, error_msg
        end
    end
    
    -- 创建文件
    for file_type, file_info in pairs(files) do
        local target_dir = target_dirs[file_type]
        if target_dir then
            local system = require('qt-assistant.system')
            local file_path = system.join_path(target_dir, file_info.name)
            
            -- 检查文件是否已存在
            if M.file_exists(file_path) then
                local choice = vim.fn.confirm(
                    string.format("File '%s' already exists. Overwrite?", file_path),
                    "&Yes\n&No\n&Backup", 2)
                
                if choice == 2 then -- No
                    return false, "Operation cancelled by user"
                elseif choice == 3 then -- Backup
                    local backup_path = file_path .. ".backup." .. os.time()
                    vim.loop.fs_copyfile(file_path, backup_path)
                    vim.notify("Backup created: " .. backup_path, vim.log.levels.INFO)
                end
            end
            
            -- 写入文件
            local success, error_msg = M.write_file(file_path, file_info.content)
            if not success then
                return false, error_msg
            end
            
            vim.notify("Created: " .. file_path, vim.log.levels.INFO)
        end
    end
    
    return true
end

-- 写入文件
function M.write_file(file_path, content)
    local config = get_config()
    
    -- 如果启用了禁用写入确认，临时设置vim选项
    local old_confirm = nil
    if config.file_handling and config.file_handling.disable_write_confirm then
        old_confirm = vim.o.confirm
        vim.o.confirm = false
    end
    
    local success, error_msg = pcall(function()
        local file = io.open(file_path, "w")
        if not file then
            error("Failed to open file for writing: " .. file_path)
        end
        
        -- Normalize line endings to LF for cross-platform builds
        local normalized = content:gsub("\r\n", "\n")
        file:write(normalized)
        file:close()
    end)
    
    -- 恢复之前的confirm设置
    if old_confirm ~= nil then
        vim.o.confirm = old_confirm
    end
    
    if not success then
        return false, error_msg
    end
    
    return true
end

-- 读取文件
function M.read_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        return nil, "Failed to open file for reading: " .. file_path
    end
    
    local content = file:read("*a")
    file:close()
    
    return content
end

-- 获取项目中的源文件列表
function M.get_source_files()
    local config = get_config()
    local source_files = {}
    
    local function scan_directory(dir, extension)
        local files = {}
        local handle = vim.loop.fs_scandir(dir)
        if handle then
            while true do
                local name, type = vim.loop.fs_scandir_next(handle)
                if not name then break end
                
                if type == "file" and name:match("%." .. extension .. "$") then
                    table.insert(files, dir .. "/" .. name)
                elseif type == "directory" and name ~= "." and name ~= ".." then
                    local sub_files = scan_directory(dir .. "/" .. name, extension)
                    for _, file in ipairs(sub_files) do
                        table.insert(files, file)
                    end
                end
            end
        end
        return files
    end
    
    -- 扫描源文件
    local src_dir = config.project_root .. "/" .. config.directories.source
    source_files.cpp = scan_directory(src_dir, "cpp")
    
    -- 扫描头文件
    local include_dir = config.project_root .. "/" .. config.directories.include
    source_files.h = scan_directory(include_dir, "h")
    
    -- 扫描UI文件
    local ui_dir = config.project_root .. "/" .. config.directories.ui
    source_files.ui = scan_directory(ui_dir, "ui")
    
    return source_files
end

-- 获取相对路径
function M.get_relative_path(absolute_path, base_path)
    local system = require('qt-assistant.system')
    local normalized_abs = system.normalize_path(absolute_path)
    local normalized_base = system.normalize_path(base_path or get_config().project_root)

    if normalized_base and normalized_abs:sub(1, #normalized_base) == normalized_base then
        local rel = normalized_abs:sub(#normalized_base + 1)
        return rel:gsub("^[/\\]", "")
    end

    return normalized_abs
end

-- 验证文件路径
function M.validate_file_path(file_path)
    -- 检查路径是否包含非法字符
    if file_path:match("[<>:\"|?*]") then
        return false, "File path contains illegal characters"
    end
    
    -- 检查路径长度
    if #file_path > 260 then
        return false, "File path is too long"
    end
    
    return true
end

-- 获取文件信息
function M.get_file_info(file_path)
    local stat = vim.loop.fs_stat(file_path)
    if not stat then
        return nil
    end
    
    return {
        exists = true,
        type = stat.type,
        size = stat.size,
        mtime = stat.mtime.sec,
        mode = stat.mode
    }
end

-- 清理空目录
function M.cleanup_empty_directories(dir_path)
    local handle = vim.loop.fs_scandir(dir_path)
    if not handle then
        return
    end
    
    local has_files = false
    while true do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then break end
        
        if name ~= "." and name ~= ".." then
            if type == "directory" then
                M.cleanup_empty_directories(dir_path .. "/" .. name)
                -- 检查子目录是否仍然存在
                local sub_stat = vim.loop.fs_stat(dir_path .. "/" .. name)
                if sub_stat then
                    has_files = true
                end
            else
                has_files = true
            end
        end
    end
    
    -- 如果目录为空，删除它
    if not has_files then
        vim.loop.fs_rmdir(dir_path)
    end
end

return M
