-- Qt Assistant Plugin - CMake集成模块
-- CMake integration module

local M = {}
local file_manager = require('qt-assistant.file_manager')
local system = require('qt-assistant.system')

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
end

-- 查找CMakeLists.txt文件 (根据不同的目录更新对应目录的cmakelists.txt文档)
function M.find_cmake_file(start_dir)
    start_dir = system.normalize_path(start_dir or vim.fn.getcwd())
    local project_root = system.normalize_path(file_manager.get_project_root())

    -- 从当前目录开始向上查找CMakeLists.txt
    local current_dir = start_dir

    while current_dir and current_dir ~= '' do
        local cmake_file = system.join_path(current_dir, "CMakeLists.txt")

        if file_manager.file_exists(cmake_file) then
            return cmake_file
        end

        -- 检查是否已到达项目根目录
        if project_root and system.normalize_path(current_dir) == project_root then
            break
        end

        -- 向上移动一级目录
        local parent = vim.fn.fnamemodify(current_dir, ":h")
        if parent == current_dir then
            break -- reached filesystem root
        end
        current_dir = parent
    end

    return nil
end

-- 读取CMakeLists.txt内容
function M.read_cmake_file(start_dir)
    local cmake_file = M.find_cmake_file(start_dir)
    if not cmake_file then
        return nil, "CMakeLists.txt not found"
    end
    
    return file_manager.read_file(cmake_file)
end

-- 写入CMakeLists.txt内容
function M.write_cmake_file(content, start_dir)
    local cmake_file = M.find_cmake_file(start_dir)
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
    local system = require('qt-assistant.system')
    local config = get_config()

    -- 选择起始目录：优先使用新建文件所在目录（最近的CMakeLists）
    local start_dir = config.project_root
    for _, info in pairs(files) do
        if info.full_path then
            start_dir = system.normalize_path(vim.fn.fnamemodify(info.full_path, ":h"))
            break
        end
    end

    local cmake_file = M.find_cmake_file(start_dir)
    if not cmake_file then
        vim.notify("Warning: CMakeLists.txt not found near " .. tostring(start_dir), vim.log.levels.WARN)
        return false
    end

    local cmake_dir = system.normalize_path(vim.fn.fnamemodify(cmake_file, ":h"))
    local cmake_content = file_manager.read_file(cmake_file)
    if not cmake_content then
        vim.notify("Warning: Failed to read CMakeLists.txt", vim.log.levels.WARN)
        return false
    end
    
    local modified = false
    local new_content = cmake_content
    
    for file_type, file_info in pairs(files) do
        if file_type == "source" and file_info.name:match("%.cpp$") then
            local absolute = file_info.full_path
            local relative_path = absolute and file_manager.get_relative_path(absolute, cmake_dir)
                or (config.directories.source .. "/" .. file_info.name)
            
            if not M.is_file_in_cmake(cmake_content, relative_path) then
                new_content = M.add_cpp_file_to_cmake(new_content, relative_path)
                modified = true
            end
            
        elseif file_type == "header" and file_info.name:match("%.h$") then
            local absolute = file_info.full_path
            local relative_path = absolute and file_manager.get_relative_path(absolute, cmake_dir)
                or (config.directories.include .. "/" .. file_info.name)
            
            if not M.is_file_in_cmake(cmake_content, relative_path) then
                new_content = M.add_header_file_to_cmake(new_content, relative_path)
                modified = true
            end
            
        elseif file_type == "ui" and file_info.name:match("%.ui$") then
            local absolute = file_info.full_path
            local relative_path = absolute and file_manager.get_relative_path(absolute, cmake_dir)
                or (config.directories.ui .. "/" .. file_info.name)
            
            if not M.is_file_in_cmake(cmake_content, relative_path) then
                new_content = M.add_ui_file_to_cmake(new_content, relative_path)
                modified = true
            end
        end
    end
    
    if modified then
        new_content = ensure_source_groups(new_content, config)
        local success, write_error = M.write_cmake_file(new_content, start_dir)
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
        -- 如果没有SOURCES变量，尝试在add_executable/add_library后添加
        local add_exec_pattern = "(add_executable%s*%([^)]+)"
        local add_lib_pattern = "(add_library%s*%([^)]+)"
        local replacement = "%1\n    " .. file_path

        local new_content = cmake_content:gsub(add_exec_pattern, replacement)
        if new_content == cmake_content then
            new_content = cmake_content:gsub(add_lib_pattern, replacement)
        end

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

-- 确保存在source_group分组，便于IDE查看
local function ensure_source_groups(cmake_content, config)
    if cmake_content:find("source_group%s*%(") then
        return cmake_content
    end

    local dirs = config.directories or {}
    local include_dir = dirs.include or "include"
    local source_dir = dirs.source or "src"
    local ui_dir = dirs.ui or "ui"

    local function find_block_end(variable_name)
        local pattern = "set%s*%(%s*" .. variable_name .. "%s*"
        local pos_start, pos_end = cmake_content:find(pattern)
        if not pos_start then
            return nil
        end

        local paren_count = 1
        local pos = pos_end + 1
        while pos <= #cmake_content and paren_count > 0 do
            local char = cmake_content:sub(pos, pos)
            if char == "(" then
                paren_count = paren_count + 1
            elseif char == ")" then
                paren_count = paren_count - 1
                if paren_count == 0 then
                    return pos
                end
            end
            pos = pos + 1
        end
        return pos_end
    end

    local insert_pos = math.max(
        find_block_end("UI_FILES") or 0,
        find_block_end("HEADERS") or 0,
        find_block_end("SOURCES") or 0
    )

    local lines = {
        "",
        "# Group files for IDEs (auto-generated)",
        "set_property(GLOBAL PROPERTY USE_FOLDERS ON)",
        string.format("source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/%s PREFIX \"Header Files\" FILES ${HEADERS})", include_dir),
        string.format("source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/%s PREFIX \"Source Files\" FILES ${SOURCES})", source_dir),
        string.format("source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/%s PREFIX \"UI Files\" FILES ${UI_FILES})", ui_dir),
        ""
    }

    local block = table.concat(lines, "\n")

    if insert_pos > 0 then
        return cmake_content:sub(1, insert_pos) .. "\n" .. block .. cmake_content:sub(insert_pos + 1)
    end

    return cmake_content .. block
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

-- 生成CMakePresets.json文件
function M.generate_cmake_presets()
    local cmake_file = M.find_cmake_file()
    if not cmake_file then
        vim.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
        return false
    end

    local project_root = vim.fn.fnamemodify(cmake_file, ":h")
    local presets_file = project_root .. "/CMakePresets.json"

    -- 检查是否已存在
    if file_manager.file_exists(presets_file) then
        vim.ui.select({'Yes', 'No'}, {
            prompt = 'CMakePresets.json already exists. Overwrite?'
        }, function(choice)
            if choice == 'Yes' then
                M.write_cmake_presets_file(presets_file)
            end
        end)
    else
        M.write_cmake_presets_file(presets_file)
    end

    return true
end

-- 写入CMakePresets.json文件
function M.write_cmake_presets_file(presets_file)
    local presets_content = [[
{
    "version": 3,
    "configurePresets": [
        {
            "name": "default",
            "displayName": "Default Config",
            "description": "Default build using Ninja generator",
            "generator": "Ninja",
            "binaryDir": "${sourceDir}/build/${presetName}",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Debug",
                "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
            }
        },
        {
            "name": "debug",
            "inherits": "default",
            "displayName": "Debug",
            "description": "Debug build configuration",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Debug"
            }
        },
        {
            "name": "release",
            "inherits": "default",
            "displayName": "Release",
            "description": "Release build configuration",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Release"
            }
        },
        {
            "name": "relwithdebinfo",
            "inherits": "default",
            "displayName": "RelWithDebInfo",
            "description": "Release with debug info",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "RelWithDebInfo"
            }
        }
    ],
    "buildPresets": [
        {
            "name": "debug",
            "configurePreset": "debug"
        },
        {
            "name": "release",
            "configurePreset": "release"
        }
    ],
    "testPresets": [
        {
            "name": "debug",
            "configurePreset": "debug",
            "output": {"outputOnFailure": true}
        },
        {
            "name": "release",
            "configurePreset": "release",
            "output": {"outputOnFailure": true}
        }
    ]
}
]]

    local success, error_msg = file_manager.write_file(presets_file, presets_content)
    if success then
        vim.notify("CMakePresets.json created successfully", vim.log.levels.INFO)
        vim.notify("Use: cmake --preset=debug to build", vim.log.levels.INFO)
    else
        vim.notify("Error creating CMakePresets.json: " .. error_msg, vim.log.levels.ERROR)
    end

    return success
end

-- 获取可用的CMake预设
function M.get_available_presets()
    local cmake_file = M.find_cmake_file()
    if not cmake_file then
        return {}
    end

    local project_root = vim.fn.fnamemodify(cmake_file, ":h")
    local presets_file = project_root .. "/CMakePresets.json"

    if not file_manager.file_exists(presets_file) then
        return {}
    end

    local content = file_manager.read_file(presets_file)
    if not content then
        return {}
    end

    -- 简单解析预设名称（真实实现应该使用JSON解析）
    local presets = {}
    for preset_name in content:gmatch('"name":%s*"([^"]+)"') do
        if preset_name ~= "default" then -- 跳过default预设
            table.insert(presets, preset_name)
        end
    end

    return presets
end

-- 使用预设构建项目
function M.build_with_preset(preset_name)
    if not preset_name then
        local presets = M.get_available_presets()
        if #presets == 0 then
            vim.notify("No CMake presets available. Generate presets first.", vim.log.levels.WARN)
            return false
        end

        vim.ui.select(presets, {
            prompt = 'Select CMake preset:'
        }, function(choice)
            if choice then
                M.build_with_preset(choice)
            end
        end)
        return true
    end

    local cmake_file = M.find_cmake_file()
    if not cmake_file then
        vim.notify("CMakeLists.txt not found", vim.log.levels.ERROR)
        return false
    end

    local project_root = vim.fn.fnamemodify(cmake_file, ":h")
    local system = require('qt-assistant.system')
    local cmake_path = system.find_executable("cmake")

    if not cmake_path then
        vim.notify("❌ CMake not found. Please install CMake.", vim.log.levels.ERROR)
        return false
    end

    vim.notify("🔨 Building with preset: " .. preset_name, vim.log.levels.INFO)

    -- 配置步骤
    local configure_cmd = {cmake_path, "--preset=" .. preset_name}

    vim.fn.jobstart(configure_cmd, {
        cwd = project_root,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    vim.notify("✅ Configure completed with preset: " .. preset_name, vim.log.levels.INFO)
                    -- 构建步骤
                    local build_cmd = {cmake_path, "--build", "--preset=" .. preset_name}
                    vim.fn.jobstart(build_cmd, {
                        cwd = project_root,
                        on_exit = function(_, build_exit_code)
                            vim.schedule(function()
                                if build_exit_code == 0 then
                                    vim.notify("🎉 Build completed successfully!", vim.log.levels.INFO)
                                else
                                    vim.notify("❌ Build failed (exit code: " .. build_exit_code .. ")", vim.log.levels.ERROR)
                                end
                            end)
                        end
                    })
                else
                    vim.notify("❌ Configure failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                end
            end)
        end
    })

    return true
end

return M