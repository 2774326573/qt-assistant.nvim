-- Neovim Qt Assistant Plugin - Main Module
-- Qt项目辅助插件主模块

local M = {}

-- 默认配置
local default_config = {
    -- 项目根目录
    project_root = vim.fn.getcwd(),
    
    -- 默认目录结构
    directories = {
        source = "src",
        include = "include", 
        ui = "ui",
        resource = "resource",
        scripts = "scripts"
    },
    
    -- 文件命名规范 snake_case 或 camelCase
    naming_convention = "snake_case",
    
    -- 自动更新CMakeLists.txt
    auto_update_cmake = true,
    
    -- 生成注释
    generate_comments = true,
    
    -- 模板路径
    template_path = vim.fn.stdpath('config') .. '/qt-templates',
    
    -- Qt项目配置
    qt_project = {
        -- 自动检测项目类型
        auto_detect = true,
        
        -- 构建配置
        build_type = "Debug", -- Debug, Release, RelWithDebInfo, MinSizeRel
        
        -- 构建目录
        build_dir = "build",
        
        -- 并行构建
        parallel_build = true,
        
        -- 构建线程数
        build_jobs = 4
    },
    
    -- UI设计师配置
    designer = {
        -- Qt Designer路径
        designer_path = "designer",
        
        -- Qt Creator路径
        creator_path = "qtcreator",
        
        -- 默认UI编辑器
        default_editor = "designer", -- designer, creator, custom
        
        -- 自定义UI编辑器
        custom_editor = {
            command = "",
            args = {"--file", "{file}"}
        },
        
        -- 自动同步UI文件
        auto_sync = true,
        
        -- UI文件预览
        enable_preview = true
    },
    
    -- 调试配置
    debug = {
        -- 启用调试模式
        enabled = false,
        
        -- 调试日志级别
        log_level = "INFO", -- DEBUG, INFO, WARN, ERROR
        
        -- 调试输出文件
        log_file = vim.fn.stdpath('data') .. '/qt-assistant.log'
    }
}

-- 插件配置
M.config = {}

-- 初始化插件
function M.setup(user_config)
    M.config = vim.tbl_deep_extend('force', default_config, user_config or {})
    
    -- 导入子模块
    M.system = require('qt-assistant.system')
    M.core = require('qt-assistant.core')
    M.templates = require('qt-assistant.templates')
    M.file_manager = require('qt-assistant.file_manager')
    M.ui = require('qt-assistant.ui')
    M.cmake = require('qt-assistant.cmake')
    M.scripts = require('qt-assistant.scripts')
    M.project_manager = require('qt-assistant.project_manager')
    M.designer = require('qt-assistant.designer')
    M.build_manager = require('qt-assistant.build_manager')
    
    -- 设置用户命令
    M.setup_commands()
    
    -- 初始化模板目录
    M.templates.init(M.config.template_path)
    
    print("Qt Assistant Plugin loaded successfully!")
end

-- 设置用户命令
function M.setup_commands()
    -- 创建Qt类
    vim.api.nvim_create_user_command('QtCreateClass', function(opts)
        local args = vim.split(opts.args, ' ')
        local class_name = args[1]
        local class_type = args[2] or 'widget'
        local options = {}
        
        -- 解析额外选项
        for i = 3, #args do
            local option = args[i]
            if option:match('^--') then
                local key = option:sub(3)
                options[key] = true
            end
        end
        
        M.create_class(class_name, class_type, options)
    end, {
        nargs = '+',
        desc = 'Create Qt class',
        complete = function(ArgLead, CmdLine, CursorPos)
            return {'main_window', 'dialog', 'widget', 'model', 'delegate', 'thread', 'utility'}
        end
    })
    
    -- 创建Qt UI
    vim.api.nvim_create_user_command('QtCreateUI', function(opts)
        local args = vim.split(opts.args, ' ')
        local ui_name = args[1]
        local ui_type = args[2] or 'widget'
        M.create_ui(ui_name, ui_type)
    end, {
        nargs = '+',
        desc = 'Create Qt UI file'
    })
    
    -- 创建数据模型
    vim.api.nvim_create_user_command('QtCreateModel', function(opts)
        local model_name = opts.args
        M.create_model(model_name)
    end, {
        nargs = 1,
        desc = 'Create Qt data model'
    })
    
    -- 交互式类创建器
    vim.api.nvim_create_user_command('QtAssistant', function()
        M.ui.show_class_creator()
    end, {
        nargs = 0,
        desc = 'Open Qt Assistant interactive interface'
    })
    
    -- 项目脚本管理
    vim.api.nvim_create_user_command('QtScript', function(opts)
        local script_name = opts.args
        M.scripts.run_script(script_name)
    end, {
        nargs = 1,
        desc = 'Run Qt project script',
        complete = function()
            return {'build', 'clean', 'run', 'debug', 'test'}
        end
    })
    
    -- 项目管理命令
    vim.api.nvim_create_user_command('QtOpenProject', function(opts)
        local project_path = opts.args ~= "" and opts.args or nil
        M.project_manager.open_project(project_path)
    end, {
        nargs = '?',
        desc = 'Open Qt project',
        complete = 'dir'
    })
    
    vim.api.nvim_create_user_command('QtBuildProject', function(opts)
        local build_type = opts.args ~= "" and opts.args or nil
        M.build_manager.build_project(build_type)
    end, {
        nargs = '?',
        desc = 'Build Qt project',
        complete = function()
            return {'Debug', 'Release', 'RelWithDebInfo', 'MinSizeRel'}
        end
    })
    
    vim.api.nvim_create_user_command('QtRunProject', function()
        M.build_manager.run_project()
    end, {
        nargs = 0,
        desc = 'Run Qt project'
    })
    
    vim.api.nvim_create_user_command('QtCleanProject', function()
        M.build_manager.clean_project()
    end, {
        nargs = 0,
        desc = 'Clean Qt project'
    })
    
    -- UI设计师命令
    vim.api.nvim_create_user_command('QtOpenDesigner', function(opts)
        local ui_file = opts.args ~= "" and opts.args or nil
        M.designer.open_designer(ui_file)
    end, {
        nargs = '?',
        desc = 'Open Qt Designer',
        complete = 'file'
    })
    
    vim.api.nvim_create_user_command('QtOpenDesignerCurrent', function()
        M.designer.open_designer_current()
    end, {
        nargs = 0,
        desc = 'Open Qt Designer with current file'
    })
    
    vim.api.nvim_create_user_command('QtPreviewUI', function(opts)
        local ui_file = opts.args ~= "" and opts.args or nil
        M.designer.preview_ui(ui_file)
    end, {
        nargs = '?',
        desc = 'Preview UI file',
        complete = 'file'
    })
    
    vim.api.nvim_create_user_command('QtSyncUI', function(opts)
        local ui_file = opts.args ~= "" and opts.args or nil
        M.designer.sync_ui(ui_file)
    end, {
        nargs = '?',
        desc = 'Sync UI file',
        complete = 'file'
    })
    
    -- 项目模板命令
    vim.api.nvim_create_user_command('QtNewProject', function(opts)
        local args = vim.split(opts.args, ' ')
        local project_name = args[1]
        local template_type = args[2] or 'widget_app'
        M.project_manager.new_project(project_name, template_type)
    end, {
        nargs = '+',
        desc = 'Create new Qt project',
        complete = function(ArgLead, CmdLine, CursorPos)
            return {'widget_app', 'quick_app', 'console_app', 'library'}
        end
    })
    
    vim.api.nvim_create_user_command('QtListTemplates', function()
        M.project_manager.list_templates()
    end, {
        nargs = 0,
        desc = 'List available project templates'
    })
    
    -- 系统信息命令
    vim.api.nvim_create_user_command('QtSystemInfo', function()
        M.system.show_system_info()
    end, {
        nargs = 0,
        desc = 'Show system information'
    })
end

-- 创建Qt类的主函数
function M.create_class(class_name, class_type, options)
    if not class_name or class_name == '' then
        vim.notify('Error: Class name is required', vim.log.levels.ERROR)
        return
    end
    
    -- 验证类名
    if not M.core.validate_class_name(class_name) then
        vim.notify('Error: Invalid class name format', vim.log.levels.ERROR)
        return
    end
    
    -- 创建类
    local success, error_msg = M.core.create_qt_class(class_name, class_type, options)
    
    if success then
        vim.notify(string.format('Successfully created %s class: %s', class_type, class_name), vim.log.levels.INFO)
    else
        vim.notify(string.format('Error creating class: %s', error_msg), vim.log.levels.ERROR)
    end
end

-- 创建Qt UI文件
function M.create_ui(ui_name, ui_type)
    local success, error_msg = M.core.create_qt_ui(ui_name, ui_type)
    
    if success then
        vim.notify(string.format('Successfully created UI: %s', ui_name), vim.log.levels.INFO)
    else
        vim.notify(string.format('Error creating UI: %s', error_msg), vim.log.levels.ERROR)
    end
end

-- 创建数据模型
function M.create_model(model_name)
    M.create_class(model_name, 'model', {})
end

-- 获取项目信息
function M.get_project_info()
    return {
        root = M.config.project_root,
        directories = M.config.directories,
        cmake_file = M.config.project_root .. '/CMakeLists.txt'
    }
end

return M