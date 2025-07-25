-- Neovim Qt Assistant Plugin - Final Main Module
-- Qt项目辅助插件主模块（最终版）

local M = {}

-- 内联配置管理，避免循环依赖
M._config = nil

-- 初始化插件
function M.setup(user_config)
    -- 默认配置
    local default_config = {
        project_root = vim.fn.getcwd(),
        directories = {
            source = "src",
            include = "include", 
            ui = "ui",
            resource = "resource",
            scripts = "scripts"
        },
        naming_convention = "snake_case",
        auto_update_cmake = true,
        generate_comments = true,
        template_path = vim.fn.stdpath('config') .. '/qt-templates',
        qt_project = {
            auto_detect = true,
            build_type = "Debug",
            build_dir = "build",
            parallel_build = true,
            build_jobs = 4
        },
        designer = {
            designer_path = "designer",
            creator_path = "qtcreator",
            default_editor = "designer",
            custom_editor = { command = "", args = {"--file", "{file}"} },
            auto_sync = true,
            enable_preview = true
        },
        debug = {
            enabled = false,
            log_level = "INFO",
            log_file = vim.fn.stdpath('data') .. '/qt-assistant.log'
        },
        enable_default_keymaps = true
    }
    
    M._config = vim.tbl_deep_extend('force', default_config, user_config or {})
    
    -- 更新外部config模块的配置（如果存在）
    local ok, config_module = pcall(require, 'qt-assistant.config')
    if ok then
        config_module.setup(user_config)
    end
    
    -- 设置快捷键（如果用户配置了）
    M.setup_keymaps()
    
    vim.notify("Qt Assistant Plugin loaded successfully!", vim.log.levels.INFO)
end

-- 获取配置
function M.get_config()
    return M._config or {}
end

-- 设置快捷键映射
function M.setup_keymaps()
    if M._config and M._config.enable_default_keymaps then
        local map = vim.keymap.set
        
        -- 基础操作
        map('n', '<leader>qc', function() M.show_main_interface() end, { desc = 'Qt Assistant' })
        map('n', '<leader>qh', '<cmd>help qt-assistant<cr>', { desc = 'Qt Help' })
        
        -- 项目管理
        map('n', '<leader>qp', function() M.smart_project_selector() end, { desc = 'Smart Project Selector' })
        map('n', '<leader>qpo', function() M.show_project_manager() end, { desc = 'Open Project' })
        map('n', '<leader>qpm', function() M.show_project_manager() end, { desc = 'Project Manager' })
        map('n', '<leader>qps', function() M.search_qt_projects() end, { desc = 'Search Qt Projects' })
        map('n', '<leader>qpq', function() M.quick_search_project() end, { desc = 'Quick Search Project' })
        map('n', '<leader>qpr', function() M.show_recent_projects() end, { desc = 'Recent Projects' })
        
        -- 构建管理  
        map('n', '<leader>qb', function() M.build_project() end, { desc = 'Build Project' })
        map('n', '<leader>qr', function() M.run_project() end, { desc = 'Run Project' })
        map('n', '<leader>qcl', function() M.clean_project() end, { desc = 'Clean Project' })
        map('n', '<leader>qbs', function() M.show_build_status() end, { desc = 'Build Status' })
        
        -- UI设计师
        map('n', '<leader>qud', function() M.open_designer() end, { desc = 'Open Designer' })
        map('n', '<leader>quc', function() M.open_designer_current() end, { desc = 'Designer Current' })
        map('n', '<leader>qum', function() M.show_designer_manager() end, { desc = 'Designer Manager' })
        
        -- 脚本管理
        map('n', '<leader>qsb', function() M.run_script('build') end, { desc = 'Script Build' })
        map('n', '<leader>qsr', function() M.run_script('run') end, { desc = 'Script Run' })
        map('n', '<leader>qsd', function() M.run_script('debug') end, { desc = 'Script Debug' })
        
        -- 系统信息
        map('n', '<leader>qsi', function() M.show_system_info() end, { desc = 'System Info' })
    end
end

-- ==================== 接口函数 ====================
-- 以下函数使用延迟加载避免循环依赖

-- 创建Qt类的主函数
function M.create_class(class_name, class_type, options)
    if not class_name or class_name == '' then
        vim.notify('Error: Class name is required', vim.log.levels.ERROR)
        return
    end
    
    -- 延迟加载需要的模块
    local core = require('qt-assistant.core')
    local templates = require('qt-assistant.templates')
    
    -- 初始化模板
    templates.init(M._config.template_path)
    
    -- 验证类名
    if not core.validate_class_name(class_name) then
        vim.notify('Error: Invalid class name format', vim.log.levels.ERROR)
        return
    end
    
    -- 创建类
    local success, error_msg = core.create_qt_class(class_name, class_type, options)
    
    if success then
        vim.notify(string.format('Successfully created %s class: %s', class_type, class_name), vim.log.levels.INFO)
    else
        vim.notify(string.format('Error creating class: %s', error_msg), vim.log.levels.ERROR)
    end
end

-- 创建UI类
function M.create_ui_class(ui_name, ui_type)
    M.create_class(ui_name, ui_type, {include_ui = true})
end

-- 创建数据模型
function M.create_model_class(model_name)
    M.create_class(model_name, 'model', {})
end

-- 获取项目信息
function M.get_project_info()
    return {
        root = M._config.project_root,
        directories = M._config.directories,
        cmake_file = M._config.project_root .. '/CMakeLists.txt'
    }
end

-- 显示主界面
function M.show_main_interface()
    local ui = require('qt-assistant.ui')
    ui.show_class_creator()
end

-- 项目管理
function M.open_project(path)
    local project_manager = require('qt-assistant.project_manager')
    project_manager.open_project(path)
end

function M.new_project(name, type)
    local project_manager = require('qt-assistant.project_manager')
    project_manager.new_project(name, type)
end

function M.show_project_manager()
    local ui = require('qt-assistant.ui')
    ui.show_project_manager()
end

-- 智能搜索Qt项目
function M.search_qt_projects()
    local project_manager = require('qt-assistant.project_manager')
    project_manager.search_and_select_project()
end

-- 快速搜索Qt项目（当前目录优先）
function M.quick_search_project()
    local project_manager = require('qt-assistant.project_manager')
    project_manager.quick_search_project()
end

-- 显示最近项目
function M.show_recent_projects()
    local project_manager = require('qt-assistant.project_manager')
    project_manager.show_recent_projects()
end

-- 智能项目选择器（整合所有功能）
function M.smart_project_selector()
    local project_manager = require('qt-assistant.project_manager')
    project_manager.show_smart_project_selector()
end

-- 构建管理
function M.build_project(build_type)
    local build_manager = require('qt-assistant.build_manager')
    build_manager.build_project(build_type)
end

function M.run_project()
    local build_manager = require('qt-assistant.build_manager')
    build_manager.run_project()
end

function M.clean_project()
    local build_manager = require('qt-assistant.build_manager')
    build_manager.clean_project()
end

function M.show_build_status()
    local build_manager = require('qt-assistant.build_manager')
    build_manager.show_build_status()
end

-- 脚本管理
function M.init_scripts()
    local scripts = require('qt-assistant.scripts')
    scripts.init_scripts_directory()
end

function M.run_script(script_name)
    local scripts = require('qt-assistant.scripts')
    scripts.run_script(script_name, {in_terminal = true})
end

-- UI设计师
function M.open_designer(ui_file)
    local designer = require('qt-assistant.designer')
    designer.open_designer(ui_file)
end

function M.open_designer_current()
    local designer = require('qt-assistant.designer')
    designer.open_designer_current()
end

function M.preview_ui(ui_file)
    local designer = require('qt-assistant.designer')
    designer.preview_ui(ui_file)
end

function M.sync_ui(ui_file)
    local designer = require('qt-assistant.designer') 
    designer.sync_ui(ui_file)
end

function M.show_designer_manager()
    local ui = require('qt-assistant.ui')
    ui.show_designer_manager()
end

-- 系统信息
function M.show_system_info()
    local system = require('qt-assistant.system')
    system.show_system_info()
end

-- 快捷键帮助
function M.show_keymaps()
    local config = M.get_config()
    local keymaps_enabled = config.enable_default_keymaps
    
    local keymaps = {
        "=== Qt Assistant Keymaps ===",
        "",
        "Basic Commands:",
        "  :QtAssistant         - Open main interface",
        "  :QtCreateClass       - Create Qt class",
        "  :QtCreateUI          - Create UI file",
        "  :QtCreateModel       - Create data model",
        "",
        "Project Management:",
        "  :QtSmartSelector     - Smart project selector (all-in-one)",
        "  :QtSearchProjects    - Search for Qt projects",
        "  :QtQuickSearch       - Quick search (current dir first)",
        "  :QtRecentProjects    - Show recent projects",
        "  :QtOpenProject       - Open project",
        "  :QtNewProject        - Create new project",
        "  :QtProjectManager    - Project manager interface",
        "",
        "Build System:",
        "  :QtBuildProject      - Build project",
        "  :QtRunProject        - Run project",
        "  :QtCleanProject      - Clean project",
        "  :QtBuildStatus       - Show build status",
        "",
        "UI Designer:",
        "  :QtOpenDesigner      - Open Qt Designer",
        "  :QtOpenDesignerCurrent - Open Designer for current file",
        "  :QtPreviewUI         - Preview UI file",
        "  :QtSyncUI            - Sync UI file with source",
        "  :QtDesignerManager   - Designer manager interface",
        "",
        "Scripts:",
        "  :QtInitScripts       - Initialize project scripts",
        "  :QtScript <name>     - Run project script",
        "",
        "System:",
        "  :QtSystemInfo        - Show system information",
        "  :QtKeymaps          - Show this help",
        "",
    }
    
    if keymaps_enabled then
        vim.list_extend(keymaps, {
            "Default Keymaps (ENABLED):",
            "  <leader>qc          - Qt Assistant",
            "  <leader>qh          - Qt Help",
            "  <leader>qp          - Smart Project Selector (⭐ MAIN)",
            "  <leader>qpo         - Open Project",
            "  <leader>qpm         - Project Manager",
            "  <leader>qps         - Search Qt Projects",
            "  <leader>qpq         - Quick Search Project",
            "  <leader>qpr         - Recent Projects",
            "  <leader>qb          - Build Project",
            "  <leader>qr          - Run Project",
            "  <leader>qcl         - Clean Project",
            "  <leader>qbs         - Build Status",
            "  <leader>qud         - Open Designer",
            "  <leader>quc         - Designer Current",
            "  <leader>qum         - Designer Manager",
            "  <leader>qsb         - Script Build",
            "  <leader>qsr         - Script Run",
            "  <leader>qsd         - Script Debug",
            "  <leader>qsi         - System Info",
        })
    else
        vim.list_extend(keymaps, {
            "Default Keymaps (DISABLED):",
            "  To enable, add to your config:",
            "  require('qt-assistant').setup({",
            "    enable_default_keymaps = true",
            "  })",
        })
    end
    
    -- 创建帮助窗口
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, keymaps)
    
    local width = 50
    local height = math.min(#keymaps + 2, 25)
    
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