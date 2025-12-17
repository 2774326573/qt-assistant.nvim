-- Qt Assistant Plugin - 用户界面模块
-- User interface module

local M = {}

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
end

-- 显示主界面
function M.show_main_interface()
    local menu_items = {
        "Qt Assistant - Main Interface",
        "=" .. string.rep("=", 50),
        "",
        "Project Management:",
        "  p - New Project (Interactive)",
        "  P - Quick Project (C++17 Widget App)",
        "  o - Open Project",
        "",
        "Build & Run:",
        "  b - Build Project",
        "  r - Run Project",
        "  q - Quick Build & Run",
        "",
        "C++ Standard Builds:",
        "  1 - Build with C++11",
        "  4 - Build with C++14",
        "  7 - Build with C++17",
        "  2 - Build with C++20",
        "",
        "UI & Classes:",
        "  d - Open Qt Designer",
        "  u - Create New UI File",
        "  c - Create Qt Class",
        "",
        "Configuration:",
        "  s - Show Current Config",
        "  t - Select C++ Standard",
        "  R - Reconfigure Project",
        "",
        "Other:",
        "  h - Help",
        "  ESC - Close",
        "",
    }
    
    -- 创建浮动窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, menu_items)
    
    local width = 60
    local height = #menu_items + 2
    local win_config = {
        relative = 'editor',
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
        style = 'minimal',
        border = 'rounded',
        title = " Qt Assistant ",
        title_pos = "center"
    }
    
    local win = vim.api.nvim_open_win(buf, true, win_config)
    
    -- 设置窗口选项
    vim.api.nvim_win_set_option(win, "number", false)
    vim.api.nvim_win_set_option(win, "relativenumber", false)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    
    -- 设置键位映射
    local keymaps = {
        -- 关闭窗口
        ['<Esc>'] = function() vim.api.nvim_win_close(win, true) end,
        
        -- 项目管理
        ['p'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant.project_manager').new_project_interactive()
        end,
        ['P'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').new_project_quick()
        end,
        ['o'] = function()
            vim.api.nvim_win_close(win, true)
            vim.cmd('QtOpenProject')
        end,
        
        -- 构建运行
        ['b'] = function()
            vim.api.nvim_win_close(win, true)
            vim.cmd('QtBuild')
        end,
        ['r'] = function()
            vim.api.nvim_win_close(win, true)
            vim.cmd('QtRun')
        end,
        ['q'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').quick_build_and_run()
        end,
        
        -- C++标准构建
        ['1'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').build_with_std('11')
        end,
        ['4'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').build_with_std('14')
        end,
        ['7'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').build_with_std('17')
        end,
        ['2'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').build_with_std('20')
        end,
        
        -- UI和类
        ['d'] = function()
            vim.api.nvim_win_close(win, true)
            vim.cmd('QtDesigner')
        end,
        ['u'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').create_new_ui_interactive()
        end,
        ['c'] = function()
            vim.api.nvim_win_close(win, true)
            vim.cmd('QtCreateClass')
        end,
        
        -- 配置
        ['s'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').show_current_config()
        end,
        ['t'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').select_cxx_standard()
        end,
        ['R'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').reconfigure_project()
        end,
        
        -- 帮助
        ['h'] = function()
            vim.api.nvim_win_close(win, true)
            require('qt-assistant').show_help()
        end,
    }
    
    -- 应用键位映射
    for key, fn in pairs(keymaps) do
        vim.api.nvim_buf_set_keymap(buf, 'n', key, '', {
            noremap = true,
            silent = true,
            callback = fn
        })
    end
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
    local class_types = {
        'main_window',
        'dialog', 
        'widget',
        'model',
        'delegate',
        'thread',
        'utility',
        'singleton'
    }
    
    -- 创建选择菜单内容
    local menu_items = {}
    table.insert(menu_items, "Qt Assistant - Class Creator")
    table.insert(menu_items, "=" .. string.rep("=", 40))
    table.insert(menu_items, "")
    
    for i, class_type in ipairs(class_types) do
        local class_info = get_class_type_info(class_type)
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

-- 获取类类型信息的本地函数
local function get_class_type_info(class_type)
    local class_info = {
        main_window = {
            name = "Main Window",
            description = "继承自QMainWindow的主窗口类",
            base_class = "QMainWindow",
            files = {"header", "source", "ui"}
        },
        dialog = {
            name = "Dialog",
            description = "继承自QDialog的对话框类",
            base_class = "QDialog", 
            files = {"header", "source", "ui"}
        },
        widget = {
            name = "Widget",
            description = "继承自QWidget的自定义控件类",
            base_class = "QWidget",
            files = {"header", "source"}
        },
        model = {
            name = "Data Model",
            description = "继承自QAbstractItemModel的数据模型类",
            base_class = "QAbstractItemModel",
            files = {"header", "source"}
        },
        delegate = {
            name = "Item Delegate", 
            description = "继承自QStyledItemDelegate的代理类",
            base_class = "QStyledItemDelegate",
            files = {"header", "source"}
        },
        thread = {
            name = "Thread",
            description = "继承自QThread的线程类",
            base_class = "QThread",
            files = {"header", "source"}
        },
        utility = {
            name = "Utility",
            description = "实用工具类",
            base_class = "QObject",
            files = {"header", "source"}
        },
        singleton = {
            name = "Singleton",
            description = "单例模式类",
            base_class = "QObject",
            files = {"header", "source"}
        }
    }
    return class_info[class_type] or {}
end

-- 显示类名输入界面
function M.show_class_input(class_type)
    local class_info = get_class_type_info(class_type)
    
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
    local class_info = get_class_type_info(class_type)
    
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
        generate_comments = get_config().generate_comments,
        target_subdir = nil,
        custom_dir = nil
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

    table.insert(options_items, "  p. Target directory: " .. (options.custom_dir or "[default]") .. " (press p to change)")
    
    table.insert(options_items, "")
    table.insert(options_items, "Target subdir: (relative to include/src/ui) [default]")
    table.insert(options_items, "")
    table.insert(options_items, "Press number to toggle, 'd' to change subdir, 'c' to create, 'q' to quit")
    
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
        local new_items = {
            "Class Configuration",
            "=" .. string.rep("=", 30),
            "",
            "Class Name: " .. class_name,
            "Class Type: " .. class_info.name,
            "Base Class: " .. class_info.base_class,
            "",
            "Options:"
        }

        local new_option_index = 1
        if options.generate_ui then
            table.insert(new_items, string.format("  %d. [x] Generate UI file", new_option_index))
            new_option_index = new_option_index + 1
        end

        table.insert(new_items, string.format("  %d. [%s] Add to CMakeLists.txt", new_option_index, options.add_to_cmake and "x" or " "))
        new_option_index = new_option_index + 1

        table.insert(new_items, string.format("  %d. [%s] Generate comments", new_option_index, options.generate_comments and "x" or " "))

        table.insert(new_items, "")
        local subdir_line = options.target_subdir and options.target_subdir ~= '' and options.target_subdir or "[default]"
        table.insert(new_items, "Target subdir: (relative to include/src/ui) " .. subdir_line)
        table.insert(new_items, "")
        table.insert(new_items, "Press number to toggle, 'd' to change subdir, 'c' to create, 'q' to quit")

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

    -- 自定义子目录
    vim.api.nvim_buf_set_keymap(buf, 'n', 'd', '', {
        callback = function()
            vim.ui.input({
                prompt = "Target subdir (relative to include/src/ui, empty for default): ",
                default = options.target_subdir or ""
            }, function(input)
                if input ~= nil then
                    options.target_subdir = input
                    update_display()
                end
            end)
        end,
        noremap = true,
        silent = true
    })

    -- 自定义目录（覆盖默认目录放置所有文件）
    vim.api.nvim_buf_set_keymap(buf, 'n', 'p', '', {
        callback = function()
            vim.ui.input({
                prompt = "Target directory (absolute or relative to cwd): ",
                default = options.custom_dir or "",
                completion = 'dir'
            }, function(input)
                if input ~= nil and input ~= '' then
                    options.custom_dir = vim.fs.normalize(input)
                else
                    options.custom_dir = nil
                end
                update_display()
            end)
        end,
        noremap = true,
        silent = true
    })

            update_display()
end

-- 使用选项创建类
function M.create_class_with_options(class_name, class_type, options)
    vim.notify("Creating " .. class_type .. " class: " .. class_name, vim.log.levels.INFO)
    
    -- 延迟加载core模块以避免循环依赖
    local ok, core = pcall(require, 'qt-assistant.core')
    if not ok then
        vim.notify('Error loading qt-assistant.core: ' .. tostring(core), vim.log.levels.ERROR)
        return
    end
    
    local success, error_msg = core.create_qt_class(class_name, class_type, options)
    
    if success then
        vim.notify("Class created successfully!", vim.log.levels.INFO)
        
        -- 询问是否打开创建的文件
        vim.ui.select({'Yes', 'No'}, {
            prompt = 'Open created files?'
        }, function(choice)
            if choice == 'Yes' then
                M.open_created_files(class_name, class_type, options)
            end
        end)
    else
        vim.notify("Error creating class: " .. (error_msg or "Unknown error"), vim.log.levels.ERROR)
    end
end

-- 打开创建的文件
function M.open_created_files(class_name, class_type, options)
    local file_manager = require('qt-assistant.file_manager')
    local system = require('qt-assistant.system')
    local target_dirs = file_manager.determine_target_directories(class_type, options)
    local filename = file_manager.class_name_to_filename(class_name)
    
    local files_to_open = {}
    
    -- 收集要打开的文件
    if target_dirs.header then
        local header_file = system.join_path(target_dirs.header, filename .. ".h")
        if file_manager.file_exists(header_file) then
            table.insert(files_to_open, header_file)
        end
    end
    
    if target_dirs.source then
        local source_file = system.join_path(target_dirs.source, filename .. ".cpp")
        if file_manager.file_exists(source_file) then
            table.insert(files_to_open, source_file)
        end
    end
    
    if target_dirs.ui then
        local ui_file = system.join_path(target_dirs.ui, filename .. ".ui")
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
    table.insert(menu_items, "1. Open project (interactive)")
    table.insert(menu_items, "2. Create new project")
    table.insert(menu_items, "3. Show project templates")
    table.insert(menu_items, "4. Build project")
    table.insert(menu_items, "5. Run project")
    table.insert(menu_items, "6. Clean project")
    table.insert(menu_items, "m. Open project by path")
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
            require('qt-assistant').open_project_interactive()
        end,
        ['2'] = function()
            close_window()
            vim.ui.input({prompt = 'Project name: '}, function(name)
                if name then
                    local templates = {
                        'widget_app',
                        'quick_app',
                        'console_app',
                        'static_lib',
                        'shared_lib',
                        'plugin'
                    }
                    vim.ui.select(templates, {
                        prompt = 'Select template:'
                    }, function(template)
                        if template then
                            project_manager.new_project(name, template)
                        end
                    end)
                end
            end)
        end,
        ['3'] = function()
            close_window()
            project_manager.list_templates()
        end,
        ['4'] = function()
            close_window()
            local build_manager = require('qt-assistant.build_manager')
            build_manager.build_project()
        end,
        ['5'] = function()
            close_window()
            local build_manager = require('qt-assistant.build_manager')
            build_manager.run_project()
        end,
        ['6'] = function()
            close_window()
            local build_manager = require('qt-assistant.build_manager')
            build_manager.clean_project()
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