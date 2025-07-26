-- Qt Assistant Plugin - 用户界面模块
-- User interface module

local M = {}

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
end

-- 浮动窗口配置
local float_win_config = {
    relative = 'editor',
    width = 60,
    height = 20,
    col = math.floor((vim.o.columns - 60) / 2),
    row = math.floor((vim.o.lines - 20) / 2),
    style = 'minimal',
    border = 'rounded'
}

-- 显示类创建器界面
function M.show_class_creator()
    local core = require('qt-assistant.core')
    local class_types = core.get_supported_class_types()
    
    -- 创建选择菜单内容
    local menu_items = {}
    table.insert(menu_items, "Qt Assistant - Class Creator")
    table.insert(menu_items, "=" .. string.rep("=", 40))
    table.insert(menu_items, "")
    
    for i, class_type in ipairs(class_types) do
        local class_info = core.get_class_type_info(class_type)
        if class_info then
            table.insert(menu_items, string.format("%d. %s", i, class_info.name))
            table.insert(menu_items, string.format("   %s", class_info.description))
            table.insert(menu_items, "")
        end
    end
    
    table.insert(menu_items, "Enter class type number (1-" .. #class_types .. "): ")
    
    -- 显示浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, menu_items)
    
    local win = vim.api.nvim_open_win(buf, true, float_win_config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    
    -- 设置键盘映射
    local function close_window()
        vim.api.nvim_win_close(win, true)
    end
    
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
    
    -- 处理数字选择
    for i = 1, #class_types do
        vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
            callback = function()
                close_window()
                M.show_class_input(class_types[i])
            end,
            noremap = true,
            silent = true
        })
    end
end

-- 显示类名输入界面
function M.show_class_input(class_type)
    local core = require('qt-assistant.core')
    local class_info = core.get_class_type_info(class_type)
    
    -- 创建输入提示
    local prompt = string.format("Create %s\nEnter class name: ", class_info.name)
    
    vim.ui.input({prompt = prompt}, function(class_name)
        if class_name and class_name ~= "" then
            -- 显示选项配置界面
            M.show_options_config(class_name, class_type)
        end
    end)
end

-- 显示选项配置界面
function M.show_options_config(class_name, class_type)
    local core = require('qt-assistant.core')
    local class_info = core.get_class_type_info(class_type)
    
    local options_items = {}
    table.insert(options_items, "Class Configuration")
    table.insert(options_items, "=" .. string.rep("=", 30))
    table.insert(options_items, "")
    table.insert(options_items, "Class Name: " .. class_name)
    table.insert(options_items, "Class Type: " .. class_info.name)
    table.insert(options_items, "Base Class: " .. class_info.base_class)
    table.insert(options_items, "")
    table.insert(options_items, "Options:")
    
    local options = {
        generate_ui = class_info.files and vim.tbl_contains(class_info.files, "ui"),
        add_to_cmake = get_config().auto_update_cmake,
        generate_comments = get_config().generate_comments
    }
    
    local option_keys = {}
    local option_index = 1
    
    if options.generate_ui then
        table.insert(options_items, string.format("  %d. [x] Generate UI file", option_index))
        option_keys[option_index] = "generate_ui"
        option_index = option_index + 1
    end
    
    table.insert(options_items, string.format("  %d. [%s] Add to CMakeLists.txt", 
                                            option_index, options.add_to_cmake and "x" or " "))
    option_keys[option_index] = "add_to_cmake"
    option_index = option_index + 1
    
    table.insert(options_items, string.format("  %d. [%s] Generate comments", 
                                            option_index, options.generate_comments and "x" or " "))
    option_keys[option_index] = "generate_comments"
    option_index = option_index + 1
    
    table.insert(options_items, "")
    table.insert(options_items, "Press number to toggle, 'c' to create, 'q' to quit")
    
    -- 创建浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, options_items)
    
    local config = vim.tbl_extend('force', float_win_config, {height = #options_items + 2})
    local win = vim.api.nvim_open_win(buf, true, config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(win, 'cursorline', false)
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    
    local function close_window()
        vim.api.nvim_win_close(win, true)
    end
    
    local function update_display()
        -- 重新生成选项显示
        local new_items = {}
        for i = 1, 8 do
            table.insert(new_items, options_items[i])
        end
        
        local new_option_index = 1
        if options.generate_ui then
            new_items[9] = string.format("  %d. [x] Generate UI file", new_option_index)
            new_option_index = new_option_index + 1
        end
        
        if new_option_index <= option_index then
            new_items[8 + new_option_index] = string.format("  %d. [%s] Add to CMakeLists.txt", 
                                                           new_option_index, options.add_to_cmake and "x" or " ")
            new_option_index = new_option_index + 1
        end
        
        if new_option_index <= option_index then
            new_items[8 + new_option_index] = string.format("  %d. [%s] Generate comments", 
                                                           new_option_index, options.generate_comments and "x" or " ")
        end
        
        for i = #new_items + 1, #options_items do
            table.insert(new_items, options_items[i])
        end
        
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_items)
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
    
    -- 创建类
    vim.api.nvim_buf_set_keymap(buf, 'n', 'c', '', {
        callback = function()
            close_window()
            M.create_class_with_options(class_name, class_type, options)
        end,
        noremap = true,
        silent = true
    })
    
    -- 选项切换
    for i, key in pairs(option_keys) do
        vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
            callback = function()
                options[key] = not options[key]
                update_display()
            end,
            noremap = true,
            silent = true
        })
    end
end

-- 使用选项创建类
function M.create_class_with_options(class_name, class_type, options)
    local core = require('qt-assistant.core')
    
    vim.notify("Creating " .. class_type .. " class: " .. class_name, vim.log.levels.INFO)
    
    local success, error_msg = core.create_qt_class(class_name, class_type, options)
    
    if success then
        vim.notify("Class created successfully!", vim.log.levels.INFO)
        
        -- 询问是否打开创建的文件
        vim.ui.select({'Yes', 'No'}, {
            prompt = 'Open created files?'
        }, function(choice)
            if choice == 'Yes' then
                M.open_created_files(class_name, class_type)
            end
        end)
    else
        vim.notify("Error creating class: " .. (error_msg or "Unknown error"), vim.log.levels.ERROR)
    end
end

-- 打开创建的文件
function M.open_created_files(class_name, class_type)
    local file_manager = require('qt-assistant.file_manager')
    local target_dirs = file_manager.determine_target_directories(class_type)
    local filename = file_manager.class_name_to_filename(class_name)
    
    local files_to_open = {}
    
    -- 收集要打开的文件
    if target_dirs.header then
        local header_file = target_dirs.header .. "/" .. filename .. ".h"
        if file_manager.file_exists(header_file) then
            table.insert(files_to_open, header_file)
        end
    end
    
    if target_dirs.source then
        local source_file = target_dirs.source .. "/" .. filename .. ".cpp"
        if file_manager.file_exists(source_file) then
            table.insert(files_to_open, source_file)
        end
    end
    
    if target_dirs.ui then
        local ui_file = target_dirs.ui .. "/" .. filename .. ".ui"
        if file_manager.file_exists(ui_file) then
            table.insert(files_to_open, ui_file)
        end
    end
    
    -- 打开文件
    for _, file_path in ipairs(files_to_open) do
        vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    end
    
    if #files_to_open > 0 then
        vim.notify("Opened " .. #files_to_open .. " files", vim.log.levels.INFO)
    end
end

-- 显示项目脚本管理器
function M.show_script_manager()
    local scripts = require('qt-assistant.scripts')
    local available_scripts = scripts.get_available_scripts()
    
    local menu_items = {}
    table.insert(menu_items, "Qt Assistant - Script Manager")
    table.insert(menu_items, "=" .. string.rep("=", 40))
    table.insert(menu_items, "")
    
    for i, script in ipairs(available_scripts) do
        table.insert(menu_items, string.format("%d. %s", i, script.display_name))
        table.insert(menu_items, string.format("   %s", script.description))
        table.insert(menu_items, "")
    end
    
    table.insert(menu_items, "Actions:")
    table.insert(menu_items, "s - Show script status")
    table.insert(menu_items, "i - Initialize scripts")
    table.insert(menu_items, "q - Quit")
    
    -- 创建浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, menu_items)
    
    local config = vim.tbl_extend('force', float_win_config, {
        width = 70,
        height = math.min(#menu_items + 2, 25)
    })
    local win = vim.api.nvim_open_win(buf, true, config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    
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
    
    -- 显示脚本状态
    vim.api.nvim_buf_set_keymap(buf, 'n', 's', '', {
        callback = function()
            close_window()
            scripts.show_script_status()
        end,
        noremap = true,
        silent = true
    })
    
    -- 初始化脚本
    vim.api.nvim_buf_set_keymap(buf, 'n', 'i', '', {
        callback = function()
            close_window()
            scripts.init_scripts_directory()
            vim.notify("Scripts initialized!", vim.log.levels.INFO)
        end,
        noremap = true,
        silent = true
    })
    
    -- 运行脚本
    for i, script in ipairs(available_scripts) do
        vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
            callback = function()
                close_window()
                M.show_script_options(script.name)
            end,
            noremap = true,
            silent = true
        })
    end
end

-- 显示脚本选项
function M.show_script_options(script_name)
    local scripts = require('qt-assistant.scripts')
    
    vim.ui.select({'Run in background', 'Run in terminal', 'Edit script'}, {
        prompt = 'Choose action for ' .. script_name .. ':'
    }, function(choice)
        if choice == 'Run in background' then
            scripts.run_script(script_name, {in_terminal = false})
        elseif choice == 'Run in terminal' then
            scripts.run_script(script_name, {in_terminal = true})
        elseif choice == 'Edit script' then
            scripts.edit_script(script_name)
        end
    end)
end

-- 显示项目管理界面
function M.show_project_manager()
    local project_manager = require('qt-assistant.project_manager')
    local current_project = project_manager.get_current_project()
    
    local menu_items = {}
    table.insert(menu_items, "Qt Assistant - Project Manager")
    table.insert(menu_items, "=" .. string.rep("=", 40))
    table.insert(menu_items, "")
    
    if current_project then
        table.insert(menu_items, "Current Project: " .. current_project.path)
        table.insert(menu_items, "Project Type: " .. current_project.type)
        table.insert(menu_items, "")
    else
        table.insert(menu_items, "No project currently loaded")
        table.insert(menu_items, "")
    end
    
    table.insert(menu_items, "Actions:")
    table.insert(menu_items, "1. Auto Open Project (Smart & Fast)")
    table.insert(menu_items, "2. Quick Project Switcher (⚡ Recent Projects)")
    table.insert(menu_items, "3. Select Project (Choose Manually)")
    table.insert(menu_items, "4. Create new project")
    table.insert(menu_items, "5. Show project templates")
    table.insert(menu_items, "6. Build project")
    table.insert(menu_items, "7. Run project")
    table.insert(menu_items, "8. Clean project")
    table.insert(menu_items, "")
    table.insert(menu_items, "Advanced Options:")
    table.insert(menu_items, "s - Search Qt projects")
    table.insert(menu_items, "g - Global search all drives (comprehensive)")
    table.insert(menu_items, "r - Recent projects")
    table.insert(menu_items, "m - Manual path input")
    table.insert(menu_items, "")
    table.insert(menu_items, "Press number/letter to select, 'q' to quit")
    
    -- 创建浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, menu_items)
    
    local config = vim.tbl_extend('force', float_win_config, {
        width = 70,
        height = math.min(#menu_items + 2, 20)
    })
    local win = vim.api.nvim_open_win(buf, true, config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    
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
    
    -- 功能选择
    local actions = {
        ['1'] = function()
            close_window()
            project_manager.show_smart_project_selector()
        end,
        ['2'] = function()
            close_window()
            project_manager.show_quick_project_switcher()
        end,
        ['3'] = function()
            close_window()
            project_manager.show_smart_project_selector_with_choice()
        end,
        ['4'] = function()
            close_window()
            vim.ui.input({prompt = 'Project name: '}, function(name)
                if name then
                    vim.ui.select({'widget_app', 'quick_app', 'console_app', 'library'}, {
                        prompt = 'Select template:'
                    }, function(template)
                        if template then
                            project_manager.new_project(name, template)
                        end
                    end)
                end
            end)
        end,
        ['5'] = function()
            close_window()
            project_manager.list_templates()
        end,
        ['6'] = function()
            close_window()
            local build_manager = require('qt-assistant.build_manager')
            build_manager.build_project()
        end,
        ['7'] = function()
            close_window()
            local build_manager = require('qt-assistant.build_manager')
            build_manager.run_project()
        end,
        ['8'] = function()
            close_window()
            local build_manager = require('qt-assistant.build_manager')
            build_manager.clean_project()
        end,
        -- 高级选项
        ['s'] = function()
            close_window()
            project_manager.search_and_select_project()
        end,
        ['g'] = function()
            close_window()
            project_manager.start_global_search()
        end,
        ['r'] = function()
            close_window()
            project_manager.show_recent_projects()
        end,
        ['m'] = function()
            close_window()
            vim.ui.input({prompt = 'Project path: ', default = vim.fn.getcwd(), completion = 'dir'}, function(path)
                if path then
                    project_manager.open_project(path)
                end
            end)
        end
    }
    
    for key, action in pairs(actions) do
        vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
            callback = action,
            noremap = true,
            silent = true
        })
    end
end

-- 显示UI设计师管理界面
function M.show_designer_manager()
    local designer = require('qt-assistant.designer')
    local ui_files = designer.find_ui_files()
    local editor_status = designer.get_editor_status()
    
    local menu_items = {}
    table.insert(menu_items, "Qt Assistant - UI Designer Manager")
    table.insert(menu_items, "=" .. string.rep("=", 50))
    table.insert(menu_items, "")
    
    -- 显示可用编辑器状态
    table.insert(menu_items, "Available Editors:")
    for editor_type, status in pairs(editor_status) do
        local status_text = status.available and "AVAILABLE" or "NOT FOUND"
        table.insert(menu_items, string.format("  • %s: %s", status.name, status_text))
    end
    table.insert(menu_items, "")
    
    -- 显示UI文件
    if #ui_files > 0 then
        table.insert(menu_items, "UI Files in Project:")
        for i, ui_info in ipairs(ui_files) do
            table.insert(menu_items, string.format("  %d. %s (%s)", i, ui_info.relative_path, ui_info.class_name))
        end
        table.insert(menu_items, "")
    else
        table.insert(menu_items, "No UI files found in project")
        table.insert(menu_items, "")
    end
    
    table.insert(menu_items, "Actions:")
    table.insert(menu_items, "d - Open Designer with current file")
    table.insert(menu_items, "p - Preview current UI file")
    table.insert(menu_items, "s - Sync UI files")
    table.insert(menu_items, "1-9 - Open specific UI file")
    table.insert(menu_items, "q - Quit")
    
    -- 创建浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, menu_items)
    
    local config = vim.tbl_extend('force', float_win_config, {
        width = 80,
        height = math.min(#menu_items + 2, 25)
    })
    local win = vim.api.nvim_open_win(buf, true, config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(win, 'cursorline', false)
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    
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
            designer.open_designer_current()
        end,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'p', '', {
        callback = function()
            close_window()
            designer.preview_ui()
        end,
        noremap = true,
        silent = true
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 's', '', {
        callback = function()
            close_window()
            designer.sync_ui()
        end,
        noremap = true,
        silent = true
    })
    
    -- UI文件快速打开
    for i = 1, math.min(#ui_files, 9) do
        vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
            callback = function()
                close_window()
                designer.open_designer(ui_files[i].path)
            end,
            noremap = true,
            silent = true
        })
    end
end

-- 显示构建状态管理界面
function M.show_build_manager()
    local build_manager = require('qt-assistant.build_manager')
    build_manager.show_build_status()
end

-- 显示插件帮助信息
function M.show_info_window(info_lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, info_lines)
    
    local config = vim.tbl_extend('force', float_win_config, {
        width = 80,
        height = math.min(#info_lines + 2, 30)
    })
    local win = vim.api.nvim_open_win(buf, true, config)
    
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    local function close_window()
        vim.api.nvim_win_close(win, true)
    end
    
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
end

function M.show_help()
    local help_items = {
        "Qt Assistant Plugin - Help",
        string.rep("=", 40),
        "",
        "Commands:",
        "  :QtCreateClass <name> <type>  - Create Qt class",
        "  :QtCreateUI <name> <type>     - Create UI file", 
        "  :QtCreateModel <name>         - Create data model",
        "  :QtAssistant                  - Interactive interface",
        "  :QtScript <name>              - Run project script",
        "",
        "Project Management:",
        "  :QtOpenProject [path]         - Open Qt project",
        "  :QtNewProject <name> <type>   - Create new project",
        "  :QtBuildProject [type]        - Build project",
        "  :QtRunProject                 - Run project",
        "  :QtCleanProject               - Clean project",
        "",
        "UI Designer:",
        "  :QtOpenDesigner [file]        - Open Qt Designer",
        "  :QtOpenDesignerCurrent        - Open Designer with current file",
        "  :QtPreviewUI [file]           - Preview UI file",
        "  :QtSyncUI [file]              - Sync UI file",
        "",
        "Supported Class Types:",
        "  main_window  - Main window class",
        "  dialog       - Dialog class",
        "  widget       - Custom widget class",
        "  model        - Data model class",
        "  delegate     - Item delegate class",
        "  thread       - Thread class",
        "  utility      - Utility class",
        "  singleton    - Singleton class",
        "",
        "Available Scripts:",
        "  build        - Build project",
        "  clean        - Clean build files",
        "  run          - Run application",
        "  debug        - Debug application",
        "  test         - Run tests",
        "",
        "Project Templates:",
        "  widget_app   - Qt Widgets Application",
        "  quick_app    - Qt Quick Application", 
        "  console_app  - Qt Console Application",
        "  library      - Qt Library",
        "",
        "Configuration:",
        "  The plugin can be configured in your init.lua:",
        "  require('qt-assistant').setup({",
        "    project_root = vim.fn.getcwd(),",
        "    naming_convention = 'snake_case',",
        "    auto_update_cmake = true",
        "  })",
        "",
        "Press 'q' or <Esc> to close this help"
    }
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_items)
    
    local config = vim.tbl_extend('force', float_win_config, {
        width = 80,
        height = math.min(#help_items + 2, 30)
    })
    local win = vim.api.nvim_open_win(buf, true, config)
    
    vim.api.nvim_win_set_option(win, 'number', false)
    vim.api.nvim_win_set_option(win, 'relativenumber', false)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    local function close_window()
        vim.api.nvim_win_close(win, true)
    end
    
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
end

return M