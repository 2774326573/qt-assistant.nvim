-- Qt Assistant Plugin - 文件管理模块
-- File management module

local M = {}

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
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
function M.determine_target_directories(class_type)
    local config = get_config()
    local system = require('qt-assistant.system')
    local project_root = config.project_root
    local dirs = config.directories
    
    local target_dirs = {}
    
    if class_type == "main_window" or class_type == "dialog" or class_type == "widget" then
        target_dirs.header = system.join_path(project_root, dirs.include, "ui")
        target_dirs.source = system.join_path(project_root, dirs.source, "ui")
        target_dirs.ui = system.join_path(project_root, dirs.ui)
    elseif class_type == "model" or class_type == "delegate" then
        target_dirs.header = system.join_path(project_root, dirs.include, "core")
        target_dirs.source = system.join_path(project_root, dirs.source, "core")
    elseif class_type == "thread" then
        target_dirs.header = system.join_path(project_root, dirs.include, "core")
        target_dirs.source = system.join_path(project_root, dirs.source, "core")
    elseif class_type == "utility" or class_type == "singleton" then
        target_dirs.header = system.join_path(project_root, dirs.include, "utils")
        target_dirs.source = system.join_path(project_root, dirs.source, "utils")
    else
        -- 默认目录
        target_dirs.header = system.join_path(project_root, dirs.include)
        target_dirs.source = system.join_path(project_root, dirs.source)
        target_dirs.ui = system.join_path(project_root, dirs.ui)
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
            local file_path = target_dir .. "/" .. file_info.name
            
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
    local file = io.open(file_path, "w")
    if not file then
        return false, "Failed to open file for writing: " .. file_path
    end
    
    file:write(content)
    file:close()
    
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
    base_path = base_path or get_config().project_root
    
    -- 简单的相对路径计算
    if absolute_path:sub(1, #base_path) == base_path then
        return absolute_path:sub(#base_path + 2) -- +2 to skip the "/"
    end
    
    return absolute_path
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