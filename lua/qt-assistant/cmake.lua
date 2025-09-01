-- Qt Assistant Plugin - CMake集成模块
-- CMake integration module

local M = {}
local file_manager = require('qt-assistant.file_manager')

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
end

-- 查找CMakeLists.txt文件
function M.find_cmake_file()
    local config = get_config()
    local cmake_file = config.project_root .. "/CMakeLists.txt"
    
    if file_manager.file_exists(cmake_file) then
        return cmake_file
    end
    
    return nil
end

-- 读取CMakeLists.txt内容
function M.read_cmake_file()
    local cmake_file = M.find_cmake_file()
    if not cmake_file then
        return nil, "CMakeLists.txt not found"
    end
    
    return file_manager.read_file(cmake_file)
end

-- 写入CMakeLists.txt内容
function M.write_cmake_file(content)
    local cmake_file = M.find_cmake_file()
    if not cmake_file then
        return false, "CMakeLists.txt not found"
    end
    
    return file_manager.write_file(cmake_file, content)
end

-- 解析CMakeLists.txt中的源文件列表
function M.parse_source_files(cmake_content)
    local source_files = {
        cpp = {},
        h = {},
        ui = {}
    }
    
    -- 查找 set(SOURCES ...) 或 add_executable 中的源文件
    local sources_block = cmake_content:match("set%s*%(%s*SOURCES%s*([^)]+)%)") or
                         cmake_content:match("add_executable%s*%([^)]*([%w%s%./_-]+%.cpp[^)]*)")
    
    if sources_block then
        for file in sources_block:gmatch("([%w%s%./_-]+%.cpp)") do
            table.insert(source_files.cpp, file:match("^%s*(.-)%s*$")) -- trim whitespace
        end
        
        for file in sources_block:gmatch("([%w%s%./_-]+%.h)") do
            table.insert(source_files.h, file:match("^%s*(.-)%s*$"))
        end
    end
    
    -- 查找Qt UI文件
    local ui_block = cmake_content:match("set%s*%(%s*UI_FILES%s*([^)]+)%)") or
                    cmake_content:match("qt5_wrap_ui%s*%([^)]*([%w%s%./_-]+%.ui[^)]*)")
    
    if ui_block then
        for file in ui_block:gmatch("([%w%s%./_-]+%.ui)") do
            table.insert(source_files.ui, file:match("^%s*(.-)%s*$"))
        end
    end
    
    return source_files
end

-- 添加源文件到CMakeLists.txt
function M.add_source_files(files)
    local cmake_content, error_msg = M.read_cmake_file()
    if not cmake_content then
        vim.notify("Warning: " .. error_msg, vim.log.levels.WARN)
        return false
    end
    
    local modified = false
    local new_content = cmake_content
    
    -- 获取相对路径
    local config = get_config()
    
    for file_type, file_info in pairs(files) do
        if file_type == "source" and file_info.name:match("%.cpp$") then
            local relative_path = config.directories.source .. "/" .. 
                                 M.get_file_subdir(file_info.type) .. "/" .. file_info.name
            
            if not M.is_file_in_cmake(cmake_content, relative_path) then
                new_content = M.add_cpp_file_to_cmake(new_content, relative_path)
                modified = true
            end
            
        elseif file_type == "header" and file_info.name:match("%.h$") then
            local relative_path = config.directories.include .. "/" .. 
                                 M.get_file_subdir(file_info.type) .. "/" .. file_info.name
            
            if not M.is_file_in_cmake(cmake_content, relative_path) then
                new_content = M.add_header_file_to_cmake(new_content, relative_path)
                modified = true
            end
            
        elseif file_type == "ui" and file_info.name:match("%.ui$") then
            local relative_path = config.directories.ui .. "/" .. file_info.name
            
            if not M.is_file_in_cmake(cmake_content, relative_path) then
                new_content = M.add_ui_file_to_cmake(new_content, relative_path)
                modified = true
            end
        end
    end
    
    if modified then
        local success, write_error = M.write_cmake_file(new_content)
        if success then
            vim.notify("CMakeLists.txt updated successfully", vim.log.levels.INFO)
        else
            vim.notify("Error updating CMakeLists.txt: " .. write_error, vim.log.levels.ERROR)
            return false
        end
    end
    
    return true
end

-- 获取文件子目录
function M.get_file_subdir(file_type)
    if file_type == "ui" then
        return "ui"
    elseif file_type == "model" or file_type == "delegate" or file_type == "thread" then
        return "core"
    elseif file_type == "utility" or file_type == "singleton" then
        return "utils"
    else
        return "ui" -- 默认为UI目录
    end
end

-- 检查文件是否已在CMakeLists.txt中
function M.is_file_in_cmake(cmake_content, file_path)
    -- 标准化路径分隔符
    local normalized_path = file_path:gsub("\\", "/")
    local escaped_path = normalized_path:gsub("([%.%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
    
    return cmake_content:find(escaped_path) ~= nil
end

-- 添加CPP文件到CMakeLists.txt
function M.add_cpp_file_to_cmake(cmake_content, file_path)
    -- 查找SOURCES变量定义
    local sources_start, sources_end = cmake_content:find("set%s*%(%s*SOURCES%s*")
    
    if sources_start then
        -- 找到SOURCES定义的结束位置
        local paren_count = 1
        local pos = sources_end + 1
        local sources_content_end = sources_end
        
        while pos <= #cmake_content and paren_count > 0 do
            local char = cmake_content:sub(pos, pos)
            if char == "(" then
                paren_count = paren_count + 1
            elseif char == ")" then
                paren_count = paren_count - 1
                if paren_count == 0 then
                    sources_content_end = pos - 1
                end
            end
            pos = pos + 1
        end
        
        -- 在SOURCES列表末尾添加新文件
        local before = cmake_content:sub(1, sources_content_end)
        local after = cmake_content:sub(sources_content_end + 1)
        
        return before .. "\n    " .. file_path .. after
        
    else
        -- 如果没有SOURCES变量，尝试在add_executable后添加
        local add_exec_pattern = "(add_executable%s*%([^)]+)"
        local replacement = "%1\n    " .. file_path
        
        local new_content = cmake_content:gsub(add_exec_pattern, replacement)
        
        if new_content == cmake_content then
            -- 如果都没找到，在文件末尾添加SOURCES变量
            return cmake_content .. "\n\n# Additional sources\nset(ADDITIONAL_SOURCES\n    " .. 
                   file_path .. "\n)\n"
        end
        
        return new_content
    end
end

-- 添加头文件到CMakeLists.txt
function M.add_header_file_to_cmake(cmake_content, file_path)
    -- 查找HEADERS变量定义
    local headers_start = cmake_content:find("set%s*%(%s*HEADERS%s*")
    
    if headers_start then
        return M.add_to_variable_block(cmake_content, "HEADERS", file_path)
    else
        -- 如果没有HEADERS变量，创建一个
        local sources_pos = cmake_content:find("set%s*%(%s*SOURCES")
        if sources_pos then
            local before = cmake_content:sub(1, sources_pos - 1)
            local after = cmake_content:sub(sources_pos)
            return before .. "set(HEADERS\n    " .. file_path .. "\n)\n\n" .. after
        else
            return cmake_content .. "\n\n# Header files\nset(HEADERS\n    " .. file_path .. "\n)\n"
        end
    end
end

-- 添加UI文件到CMakeLists.txt
function M.add_ui_file_to_cmake(cmake_content, file_path)
    -- 查找UI_FILES变量定义或qt_wrap_ui调用
    local ui_start = cmake_content:find("set%s*%(%s*UI_FILES%s*") or
                    cmake_content:find("qt5_wrap_ui%s*%(") or
                    cmake_content:find("qt6_wrap_ui%s*%(")
    
    if ui_start then
        if cmake_content:find("set%s*%(%s*UI_FILES%s*") then
            return M.add_to_variable_block(cmake_content, "UI_FILES", file_path)
        else
            -- 添加到qt_wrap_ui调用中
            local pattern = "(qt[56]_wrap_ui%s*%([^)]+)"
            local replacement = "%1\n    " .. file_path
            return cmake_content:gsub(pattern, replacement)
        end
    else
        -- 创建UI_FILES变量
        return cmake_content .. "\n\n# UI files\nset(UI_FILES\n    " .. file_path .. "\n)\n" ..
               "qt_wrap_ui(UI_HEADERS ${UI_FILES})\n"
    end
end

-- 添加文件到指定的变量块
function M.add_to_variable_block(cmake_content, variable_name, file_path)
    local pattern = "(set%s*%(%s*" .. variable_name .. "%s*[^)]*)"
    local pos_start, pos_end = cmake_content:find(pattern)
    
    if pos_start then
        -- 找到变量块的结束位置
        local paren_count = 1
        local pos = pos_end + 1
        local content_end = pos_end
        
        while pos <= #cmake_content and paren_count > 0 do
            local char = cmake_content:sub(pos, pos)
            if char == "(" then
                paren_count = paren_count + 1
            elseif char == ")" then
                paren_count = paren_count - 1
                if paren_count == 0 then
                    content_end = pos - 1
                end
            end
            pos = pos + 1
        end
        
        local before = cmake_content:sub(1, content_end)
        local after = cmake_content:sub(content_end + 1)
        
        return before .. "\n    " .. file_path .. after
    end
    
    return cmake_content
end

-- 验证CMakeLists.txt语法
function M.validate_cmake_syntax(cmake_content)
    local errors = {}
    
    -- 检查括号匹配
    local paren_count = 0
    local line_num = 1
    
    for i = 1, #cmake_content do
        local char = cmake_content:sub(i, i)
        
        if char == "(" then
            paren_count = paren_count + 1
        elseif char == ")" then
            paren_count = paren_count - 1
            if paren_count < 0 then
                table.insert(errors, "Line " .. line_num .. ": Unmatched closing parenthesis")
                paren_count = 0
            end
        elseif char == "\n" then
            line_num = line_num + 1
        end
    end
    
    if paren_count > 0 then
        table.insert(errors, "Unmatched opening parenthesis(es)")
    end
    
    return #errors == 0, errors
end

-- 格式化CMakeLists.txt
function M.format_cmake_file()
    local cmake_content, error_msg = M.read_cmake_file()
    if not cmake_content then
        return false, error_msg
    end
    
    -- 简单的格式化：统一缩进
    local lines = {}
    local indent_level = 0
    
    for line in cmake_content:gmatch("[^\r\n]*") do
        local trimmed = line:match("^%s*(.-)%s*$")
        
        if trimmed ~= "" then
            -- 计算缩进
            if trimmed:match("^end") or trimmed:match("%)%s*$") then
                indent_level = math.max(0, indent_level - 1)
            end
            
            local formatted_line = string.rep("    ", indent_level) .. trimmed
            table.insert(lines, formatted_line)
            
            if trimmed:match("^%w+%s*%(") and not trimmed:match("%)%s*$") then
                indent_level = indent_level + 1
            end
        else
            table.insert(lines, "")
        end
    end
    
    local formatted_content = table.concat(lines, "\n")
    return M.write_cmake_file(formatted_content)
end

-- 添加UI文件到CMakeLists.txt
function M.add_ui_file(ui_file_path)
    local cmake_content, error_msg = M.read_cmake_file()
    if not cmake_content then
        vim.notify("Warning: " .. error_msg, vim.log.levels.WARN)
        return false
    end
    
    -- 获取相对路径
    local config = get_config()
    local relative_path = file_manager.get_relative_path(ui_file_path, config.project_root)
    
    if M.is_file_in_cmake(cmake_content, relative_path) then
        vim.notify("UI file already in CMakeLists.txt: " .. relative_path, vim.log.levels.INFO)
        return true
    end
    
    local new_content = M.add_ui_file_to_cmake(cmake_content, relative_path)
    
    local success, write_error = M.write_cmake_file(new_content)
    if success then
        vim.notify("Added UI file to CMakeLists.txt: " .. relative_path, vim.log.levels.INFO)
        return true
    else
        vim.notify("Error updating CMakeLists.txt: " .. write_error, vim.log.levels.ERROR)
        return false
    end
end

-- 备份CMakeLists.txt
function M.backup_cmake_file()
    local cmake_file = M.find_cmake_file()
    if not cmake_file then
        return false, "CMakeLists.txt not found"
    end
    
    local backup_file = cmake_file .. ".backup." .. os.time()
    local content = file_manager.read_file(cmake_file)
    
    if content then
        local success = file_manager.write_file(backup_file, content)
        if success then
            vim.notify("CMakeLists.txt backed up to: " .. backup_file, vim.log.levels.INFO)
            return true
        end
    end
    
    return false, "Failed to create backup"
end

return M