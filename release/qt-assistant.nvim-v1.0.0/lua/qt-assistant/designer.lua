-- Qt Assistant Plugin - UI设计师集成模块
-- UI Designer integration module

local M = {}
local file_manager = require('qt-assistant.file_manager')

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
end

-- 检测系统中可用的UI编辑器
function M.detect_available_editors()
    local system = require('qt-assistant.system')
    local editors = {}
    
    -- 检测Qt Designer
    local designer_cmd = get_config().designer.designer_path
    local designer_path = system.find_qt_tool(designer_cmd)
    if designer_path then
        editors.designer = {
            name = "Qt Designer",
            command = designer_path,
            args = {"{file}"},
            available = true
        }
    else
        editors.designer = {
            name = "Qt Designer",
            command = designer_cmd,
            available = false
        }
    end
    
    -- 检测Qt Creator
    local creator_cmd = get_config().designer.creator_path
    local creator_path = system.find_qt_tool(creator_cmd)
    if creator_path then
        editors.creator = {
            name = "Qt Creator",
            command = creator_path,
            args = {"{file}"},
            available = true
        }
    else
        editors.creator = {
            name = "Qt Creator",
            command = creator_cmd,
            available = false
        }
    end
    
    -- 检测自定义编辑器
    local custom_config = get_config().designer.custom_editor
    if custom_config.command and custom_config.command ~= "" then
        local custom_path = system.find_executable(custom_config.command)
        if custom_path then
            editors.custom = {
                name = "Custom Editor",
                command = custom_path,
                args = custom_config.args or {"{file}"},
                available = true
            }
        else
            editors.custom = {
                name = "Custom Editor",
                command = custom_config.command,
                available = false
            }
        end
    end
    
    return editors
end

-- 查找项目中的UI文件
function M.find_ui_files(project_path)
    project_path = project_path or get_config().project_root
    local system = require('qt-assistant.system')
    
    local ui_files = {}
    
    -- 递归搜索UI文件
    local function scan_directory(dir, max_depth, current_depth)
        current_depth = current_depth or 0
        if current_depth >= (max_depth or 4) then
            return
        end
        
        local handle = vim.loop.fs_scandir(dir)
        if not handle then return end
        
        while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then break end
            
            local full_path = system.join_path(dir, name)
            
            if type == "file" and name:match("%.ui$") then
                -- 分析UI文件信息
                local ui_info = M.analyze_ui_file(full_path)
                ui_info.path = full_path
                ui_info.relative_path = file_manager.get_relative_path(full_path, project_path)
                table.insert(ui_files, ui_info)
                
            elseif type == "directory" and not name:match("^%.") and name ~= "build" then
                scan_directory(full_path, max_depth, current_depth + 1)
            end
        end
    end
    
    scan_directory(project_path, 4)
    
    return ui_files
end

-- 分析UI文件信息
function M.analyze_ui_file(ui_file_path)
    local ui_info = {
        name = vim.fn.fnamemodify(ui_file_path, ":t:r"),  -- 文件名不含扩展名
        class_name = "",
        widgets = {},
        connections = {},
        has_custom_code = false
    }
    
    -- 读取UI文件内容
    local content = file_manager.read_file(ui_file_path)
    if not content then
        return ui_info
    end
    
    -- 解析XML内容获取类名
    local class_match = content:match('<class>([^<]+)</class>')
    if class_match then
        ui_info.class_name = class_match
    end
    
    -- 解析主要控件
    for widget_match in content:gmatch('<widget class="([^"]+)" name="([^"]+)"') do
        local widget_class, widget_name = widget_match:match('([^"]+)", "([^"]+)')
        if widget_class and widget_name then
            table.insert(ui_info.widgets, {
                class = widget_class,
                name = widget_name
            })
        end
    end
    
    -- 解析信号槽连接
    for connection in content:gmatch('<connection>.-</connection>') do
        local sender = connection:match('<sender>([^<]+)</sender>')
        local signal = connection:match('<signal>([^<]+)</signal>')
        local receiver = connection:match('<receiver>([^<]+)</receiver>')
        local slot = connection:match('<slot>([^<]+)</slot>')
        
        if sender and signal and receiver and slot then
            table.insert(ui_info.connections, {
                sender = sender,
                signal = signal,
                receiver = receiver,
                slot = slot
            })
        end
    end
    
    return ui_info
end

-- 打开UI设计师
function M.open_designer(ui_file)
    -- 如果没有指定文件，尝试从当前缓冲区获取
    if not ui_file then
        ui_file = M.get_current_ui_file()
    end
    
    -- 如果仍然没有文件，让用户选择
    if not ui_file then
        M.select_ui_file_to_open()
        return
    end
    
    -- 检查文件是否存在
    if not file_manager.file_exists(ui_file) then
        vim.notify("UI file not found: " .. ui_file, vim.log.levels.ERROR)
        return false
    end
    
    -- 获取可用的编辑器
    local editors = M.detect_available_editors()
    local default_editor = get_config().designer.default_editor
    
    local editor = editors[default_editor]
    if not editor or not editor.available then
        -- 尝试找到第一个可用的编辑器
        for _, ed in pairs(editors) do
            if ed.available then
                editor = ed
                break
            end
        end
    end
    
    if not editor or not editor.available then
        vim.notify("No UI editor available. Please configure designer settings.", vim.log.levels.ERROR)
        return false
    end
    
    -- 构建命令
    local cmd = {editor.command}
    for _, arg in ipairs(editor.args or {}) do
        local processed_arg = arg:gsub("{file}", ui_file)
        table.insert(cmd, processed_arg)
    end
    
    -- 启动编辑器
    vim.notify(string.format("Opening %s with %s...", vim.fn.fnamemodify(ui_file, ":t"), editor.name), vim.log.levels.INFO)
    
    local job_id = vim.fn.jobstart(cmd, {
        detach = true,
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                vim.notify(string.format("%s exited with code %d", editor.name, exit_code), vim.log.levels.WARN)
            end
        end
    })
    
    if job_id <= 0 then
        vim.notify("Failed to start " .. editor.name, vim.log.levels.ERROR)
        return false
    end
    
    return true
end

-- 打开当前文件对应的UI设计师
function M.open_designer_current()
    local current_file = vim.fn.expand('%:p')
    local ui_file = nil
    
    -- 如果当前文件就是UI文件
    if current_file:match("%.ui$") then
        ui_file = current_file
    else
        -- 尝试找到对应的UI文件
        ui_file = M.find_corresponding_ui_file(current_file)
    end
    
    if ui_file then
        M.open_designer(ui_file)
    else
        vim.notify("No corresponding UI file found for current file", vim.log.levels.WARN)
        M.select_ui_file_to_open()
    end
end

-- 查找对应的UI文件
function M.find_corresponding_ui_file(source_file)
    local base_name = vim.fn.fnamemodify(source_file, ":t:r")  -- 文件名不含扩展名
    local project_root = get_config().project_root
    local system = require('qt-assistant.system')
    
    -- 常见的UI文件位置
    local possible_paths = {
        system.join_path(project_root, "ui", base_name .. ".ui"),
        system.join_path(project_root, base_name .. ".ui"),
        system.join_path(vim.fn.fnamemodify(source_file, ":h"), base_name .. ".ui"),
        system.join_path(project_root, "forms", base_name .. ".ui")
    }
    
    for _, path in ipairs(possible_paths) do
        if file_manager.file_exists(path) then
            return path
        end
    end
    
    return nil
end

-- 获取当前UI文件
function M.get_current_ui_file()
    local current_file = vim.fn.expand('%:p')
    
    if current_file:match("%.ui$") then
        return current_file
    end
    
    return nil
end

-- 选择UI文件打开
function M.select_ui_file_to_open()
    local ui_files = M.find_ui_files()
    
    if #ui_files == 0 then
        vim.notify("No UI files found in project", vim.log.levels.WARN)
        return
    end
    
    local file_options = {}
    for _, ui_info in ipairs(ui_files) do
        table.insert(file_options, ui_info.relative_path .. " (" .. ui_info.class_name .. ")")
    end
    
    vim.ui.select(file_options, {
        prompt = 'Select UI file to open:'
    }, function(choice, idx)
        if choice and idx then
            M.open_designer(ui_files[idx].path)
        end
    end)
end

-- 预览UI文件
function M.preview_ui(ui_file)
    if not ui_file then
        ui_file = M.get_current_ui_file()
    end
    
    if not ui_file then
        vim.notify("No UI file specified", vim.log.levels.ERROR)
        return
    end
    
    if not file_manager.file_exists(ui_file) then
        vim.notify("UI file not found: " .. ui_file, vim.log.levels.ERROR)
        return
    end
    
    -- 分析UI文件
    local ui_info = M.analyze_ui_file(ui_file)
    
    -- 显示预览信息
    M.show_ui_preview(ui_info, ui_file)
end

-- 显示UI预览
function M.show_ui_preview(ui_info, ui_file)
    local preview_lines = {}
    
    table.insert(preview_lines, "=== UI File Preview ===")
    table.insert(preview_lines, "File: " .. file_manager.get_relative_path(ui_file))
    table.insert(preview_lines, "Class: " .. (ui_info.class_name or "Unknown"))
    table.insert(preview_lines, "")
    
    if #ui_info.widgets > 0 then
        table.insert(preview_lines, "Widgets:")
        for _, widget in ipairs(ui_info.widgets) do
            table.insert(preview_lines, string.format("  • %s (%s)", widget.name, widget.class))
        end
        table.insert(preview_lines, "")
    end
    
    if #ui_info.connections > 0 then
        table.insert(preview_lines, "Signal/Slot Connections:")
        for _, conn in ipairs(ui_info.connections) do
            table.insert(preview_lines, string.format("  • %s::%s -> %s::%s", 
                                                     conn.sender, conn.signal, conn.receiver, conn.slot))
        end
        table.insert(preview_lines, "")
    end
    
    table.insert(preview_lines, "Actions:")
    table.insert(preview_lines, "  d - Open in Designer")
    table.insert(preview_lines, "  s - Sync UI file")
    table.insert(preview_lines, "  q - Close")
    
    -- 创建预览窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, preview_lines)
    
    local width = 70
    local height = math.min(#preview_lines + 2, 20)
    
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
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'd', '', {
        callback = function()
            close_window()
            M.open_designer(ui_file)
        end,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 's', '', {
        callback = function()
            close_window()
            M.sync_ui(ui_file)
        end,
        noremap = true,
        silent = true
    })
end

-- 同步UI文件
function M.sync_ui(ui_file)
    if not ui_file then
        ui_file = M.get_current_ui_file()
    end
    
    if not ui_file then
        vim.notify("No UI file specified", vim.log.levels.ERROR)
        return
    end
    
    -- 分析UI文件
    local ui_info = M.analyze_ui_file(ui_file)
    
    -- 查找对应的头文件和源文件
    local base_name = vim.fn.fnamemodify(ui_file, ":t:r")
    local corresponding_files = M.find_corresponding_source_files(base_name)
    
    if #corresponding_files == 0 then
        vim.notify("No corresponding source files found for UI file", vim.log.levels.WARN)
        return
    end
    
    -- 更新头文件和源文件
    for _, file_path in ipairs(corresponding_files) do
        if file_path:match("%.h$") then
            M.sync_header_file(file_path, ui_info)
        elseif file_path:match("%.cpp$") then
            M.sync_source_file(file_path, ui_info)
        end
    end
    
    vim.notify("UI file synchronized with source files", vim.log.levels.INFO)
end

-- 查找对应的源文件
function M.find_corresponding_source_files(base_name)
    local project_root = get_config().project_root
    local system = require('qt-assistant.system')
    local files = {}
    
    -- 可能的文件位置
    local possible_paths = {
        system.join_path(project_root, "include", base_name .. ".h"),
        system.join_path(project_root, "include", "ui", base_name .. ".h"), 
        system.join_path(project_root, "src", base_name .. ".cpp"),
        system.join_path(project_root, "src", "ui", base_name .. ".cpp"),
        system.join_path(project_root, base_name .. ".h"),
        system.join_path(project_root, base_name .. ".cpp")
    }
    
    for _, path in ipairs(possible_paths) do
        if file_manager.file_exists(path) then
            table.insert(files, path)
        end
    end
    
    return files
end

-- 同步头文件
function M.sync_header_file(header_file, ui_info)
    -- 这里可以实现自动更新头文件中的UI相关声明
    -- 比如添加新的槽函数声明等
    vim.notify("Header file sync not implemented yet", vim.log.levels.INFO)
end

-- 同步源文件  
function M.sync_source_file(source_file, ui_info)
    -- 这里可以实现自动更新源文件中的UI相关代码
    -- 比如添加新的槽函数实现等
    vim.notify("Source file sync not implemented yet", vim.log.levels.INFO)
end

-- 获取UI编辑器状态
function M.get_editor_status()
    local editors = M.detect_available_editors()
    local status = {}
    
    for editor_type, editor_info in pairs(editors) do
        status[editor_type] = {
            name = editor_info.name,
            available = editor_info.available,
            command = editor_info.command
        }
    end
    
    return status
end

return M