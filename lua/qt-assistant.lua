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
    
    -- 初始化模板目录
    M.templates.init(M.config.template_path)
    
    -- 设置快捷键（如果用户配置了）
    M.setup_keymaps()
    
    vim.notify("Qt Assistant Plugin loaded successfully!", vim.log.levels.INFO)
end

-- 设置快捷键映射
function M.setup_keymaps()
    -- 用户可以在配置中启用默认快捷键
    if M.config.enable_default_keymaps then
        local map = vim.keymap.set
        
        -- 基础操作
        map('n', '<leader>qc', function() M.show_main_interface() end, { desc = 'Qt Assistant' })
        map('n', '<leader>qh', '<cmd>help qt-assistant<cr>', { desc = 'Qt Help' })
        
        -- 项目管理
        map('n', '<leader>qpo', function() M.show_project_manager() end, { desc = 'Open Project' })
        map('n', '<leader>qpm', function() M.show_project_manager() end, { desc = 'Project Manager' })
        
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

-- ==================== 接口函数 ====================
-- 以下函数对应plugin文件中定义的命令

-- 显示主界面
function M.show_main_interface()
    if M.ui then
        M.ui.show_class_creator()
    else
        vim.notify('UI module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

-- 项目管理
function M.open_project(path)
    if M.project_manager then
        M.project_manager.open_project(path)
    else
        vim.notify('Project manager not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.new_project(name, type)
    if M.project_manager then
        M.project_manager.new_project(name, type)
    else
        vim.notify('Project manager not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.show_project_manager()
    if M.ui then
        M.ui.show_project_manager()
    else
        vim.notify('UI module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

-- 构建管理
function M.build_project(build_type)
    if M.build_manager then
        M.build_manager.build_project(build_type)
    else
        vim.notify('Build manager not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.run_project()
    if M.build_manager then
        M.build_manager.run_project()
    else
        vim.notify('Build manager not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.clean_project()
    if M.build_manager then
        M.build_manager.clean_project()
    else
        vim.notify('Build manager not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.show_build_status()
    if M.build_manager then
        M.build_manager.show_build_status()
    else
        vim.notify('Build manager not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

-- 脚本管理
function M.init_scripts()
    if M.scripts then
        M.scripts.init_scripts_directory()
    else
        vim.notify('Scripts module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.run_script(script_name)
    if M.scripts then
        M.scripts.run_script(script_name, {in_terminal = true})
    else
        vim.notify('Scripts module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

-- UI设计师
function M.open_designer(ui_file)
    if M.designer then
        M.designer.open_designer(ui_file)
    else
        vim.notify('Designer module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.open_designer_current()
    if M.designer then
        M.designer.open_designer_current()
    else
        vim.notify('Designer module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.preview_ui(ui_file)
    if M.designer then
        M.designer.preview_ui(ui_file)
    else
        vim.notify('Designer module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.sync_ui(ui_file)
    if M.designer then
        M.designer.sync_ui(ui_file)
    else
        vim.notify('Designer module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

function M.show_designer_manager()
    if M.ui then
        M.ui.show_designer_manager()
    else
        vim.notify('UI module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

-- 系统信息
function M.show_system_info()
    if M.system then
        M.system.show_system_info()
    else
        vim.notify('System module not loaded. Please call setup() first.', vim.log.levels.ERROR)
    end
end

-- 快捷键帮助
function M.show_keymaps()
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
        "Default Keymaps (if enabled):",
        "  <leader>qc          - Qt Assistant",
        "  <leader>qb          - Build Project",
        "  <leader>qr          - Run Project",
        "  <leader>qud         - Open Designer",
    }
    
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