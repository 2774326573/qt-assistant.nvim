-- Qt Assistant Plugin Entry Point
-- 这个文件定义插件的命令和自动命令

-- 检查Neovim版本
if vim.fn.has('nvim-0.8') ~= 1 then
    vim.notify('Qt Assistant requires Neovim 0.8 or higher', vim.log.levels.ERROR)
    return
end

-- 防止重复加载
if vim.g.loaded_qt_assistant then
    return
end
vim.g.loaded_qt_assistant = 1

-- 延迟加载的辅助函数
local function ensure_loaded()
    if not package.loaded['qt-assistant'] then
        require('qt-assistant')
    end
end

-- 创建用户命令
vim.api.nvim_create_user_command('QtAssistant', function()
    ensure_loaded()
    require('qt-assistant').show_main_interface()
end, { desc = 'Open Qt Assistant interface' })

vim.api.nvim_create_user_command('QtCreateClass', function(opts)
    ensure_loaded()
    local args = vim.split(opts.args, '%s+')
    if #args >= 2 then
        require('qt-assistant').create_class(args[1], args[2])
    else
        vim.notify('Usage: QtCreateClass <ClassName> <ClassType>', vim.log.levels.ERROR)
    end
end, { 
    nargs = '+',
    desc = 'Create Qt class',
    complete = function()
        return {'main_window', 'dialog', 'widget', 'model', 'delegate', 'thread', 'utility', 'singleton'}
    end
})

vim.api.nvim_create_user_command('QtCreateUI', function(opts)
    ensure_loaded()
    local args = vim.split(opts.args, '%s+')
    if #args >= 2 then
        require('qt-assistant').create_ui_class(args[1], args[2])
    else
        vim.notify('Usage: QtCreateUI <ClassName> <UIType>', vim.log.levels.ERROR)
    end
end, { 
    nargs = '+',
    desc = 'Create Qt UI class',
    complete = function()
        return {'main_window', 'dialog', 'widget'}
    end
})

vim.api.nvim_create_user_command('QtCreateModel', function(opts)
    ensure_loaded()
    if opts.args ~= '' then
        require('qt-assistant').create_model_class(opts.args)
    else
        vim.notify('Usage: QtCreateModel <ModelName>', vim.log.levels.ERROR)
    end
end, { nargs = 1, desc = 'Create Qt model class' })

vim.api.nvim_create_user_command('QtOpenProject', function(opts)
    ensure_loaded()
    if opts.args ~= '' then
        require('qt-assistant').open_project(opts.args)
    else
        require('qt-assistant').show_project_manager()
    end
end, { 
    nargs = '?',
    desc = 'Open Qt project',
    complete = 'dir'
})

vim.api.nvim_create_user_command('QtNewProject', function(opts)
    ensure_loaded()
    local args = vim.split(opts.args, '%s+')
    if #args >= 2 then
        require('qt-assistant').new_project(args[1], args[2])
    else
        vim.notify('Usage: QtNewProject <ProjectName> <ProjectType>', vim.log.levels.ERROR)
    end
end, { 
    nargs = '+',
    desc = 'Create new Qt project',
    complete = function()
        return {'widget_app', 'quick_app', 'console_app', 'library'}
    end
})

vim.api.nvim_create_user_command('QtBuildProject', function(opts)
    ensure_loaded()
    require('qt-assistant').build_project(opts.args ~= '' and opts.args or nil)
end, { 
    nargs = '?',
    desc = 'Build Qt project',
    complete = function()
        return {'Debug', 'Release', 'RelWithDebInfo', 'MinSizeRel'}
    end
})

vim.api.nvim_create_user_command('QtRunProject', function()
    ensure_loaded()
    require('qt-assistant').run_project()
end, { desc = 'Run Qt project' })

vim.api.nvim_create_user_command('QtCleanProject', function()
    ensure_loaded()
    require('qt-assistant').clean_project()
end, { desc = 'Clean Qt project' })

-- Code formatting commands
vim.api.nvim_create_user_command('QtFormatFile', function(opts)
    ensure_loaded()
    require('qt-assistant').format_current_file(opts.args ~= '' and opts.args or nil)
end, { 
    nargs = '?',
    desc = 'Format current file',
    complete = function()
        return {'clang_format', 'astyle'}
    end
})

vim.api.nvim_create_user_command('QtFormatProject', function(opts)
    ensure_loaded()
    require('qt-assistant').format_project(opts.args ~= '' and opts.args or nil)
end, { 
    nargs = '?',
    desc = 'Format entire project',
    complete = function()
        return {'clang_format', 'astyle'}
    end
})

vim.api.nvim_create_user_command('QtFormatterStatus', function()
    ensure_loaded()
    require('qt-assistant').show_formatter_status()
end, { desc = 'Show formatter status' })

vim.api.nvim_create_user_command('QtCreateClangFormat', function()
    ensure_loaded()
    require('qt-assistant').create_clang_format_config()
end, { desc = 'Create .clang-format configuration file' })

vim.api.nvim_create_user_command('QtInitScripts', function()
    ensure_loaded()
    require('qt-assistant').init_scripts()
end, { desc = 'Initialize Qt project scripts' })

vim.api.nvim_create_user_command('QtGenerateScripts', function()
    ensure_loaded()
    require('qt-assistant').generate_scripts()
end, { desc = 'Generate all Qt project scripts' })

vim.api.nvim_create_user_command('QtGenerateAllScripts', function()
    ensure_loaded()
    require('qt-assistant').generate_scripts()
end, { desc = 'Generate all Qt project scripts (alias)' })

vim.api.nvim_create_user_command('QtScriptGenerator', function()
    ensure_loaded()
    require('qt-assistant').show_script_generator()
end, { desc = 'Open interactive script generator' })

vim.api.nvim_create_user_command('QtGenerateScript', function(opts)
    ensure_loaded()
    if opts.args ~= '' then
        require('qt-assistant').generate_single_script(opts.args)
    else
        require('qt-assistant').show_script_generator()
    end
end, { 
    nargs = '?',
    desc = 'Generate specific Qt project script',
    complete = function()
        return {'build', 'run', 'debug', 'clean', 'test', 'deploy'}
    end
})

vim.api.nvim_create_user_command('QtEditScript', function(opts)
    ensure_loaded()
    if opts.args ~= '' then
        require('qt-assistant').edit_script(opts.args)
    else
        local script_name = vim.fn.input('Script name to edit: ')
        if script_name and script_name ~= '' then
            require('qt-assistant').edit_script(script_name)
        end
    end
end, { 
    nargs = '?',
    desc = 'Edit Qt project script',
    complete = function()
        pcall(ensure_loaded)
        local ok, qt_assistant = pcall(require, 'qt-assistant')
        if ok then
            return qt_assistant.list_scripts()
        end
        return {'build', 'run', 'debug', 'clean', 'test', 'deploy'}
    end
})

vim.api.nvim_create_user_command('QtScript', function(opts)
    ensure_loaded()
    if opts.args ~= '' then
        require('qt-assistant').run_script(opts.args)
    else
        vim.notify('Usage: QtScript <ScriptName>', vim.log.levels.ERROR)
    end
end, { 
    nargs = 1,
    desc = 'Run Qt project script',
    complete = function()
        return {'build', 'clean', 'run', 'debug', 'test'}
    end
})

vim.api.nvim_create_user_command('QtOpenDesigner', function(opts)
    ensure_loaded()
    require('qt-assistant').open_designer(opts.args ~= '' and opts.args or nil)
end, { 
    nargs = '?',
    desc = 'Open Qt Designer',
    complete = 'file'
})

vim.api.nvim_create_user_command('QtOpenDesignerCurrent', function()
    ensure_loaded()
    require('qt-assistant').open_designer_current()
end, { desc = 'Open Qt Designer for current file' })

vim.api.nvim_create_user_command('QtPreviewUI', function(opts)
    ensure_loaded()
    require('qt-assistant').preview_ui(opts.args ~= '' and opts.args or nil)
end, { 
    nargs = '?',
    desc = 'Preview UI file',
    complete = 'file'
})

vim.api.nvim_create_user_command('QtSyncUI', function(opts)
    ensure_loaded()
    require('qt-assistant').sync_ui(opts.args ~= '' and opts.args or nil)
end, { 
    nargs = '?',
    desc = 'Sync UI file with source',
    complete = 'file'
})

vim.api.nvim_create_user_command('QtProjectManager', function()
    ensure_loaded()
    require('qt-assistant').show_project_manager()
end, { desc = 'Open Qt project manager' })

vim.api.nvim_create_user_command('QtSearchProjects', function()
    ensure_loaded()
    require('qt-assistant').search_qt_projects()
end, { desc = 'Search for Qt projects' })


vim.api.nvim_create_user_command('QtRecentProjects', function()
    ensure_loaded()
    require('qt-assistant').show_recent_projects()
end, { desc = 'Show recent Qt projects' })

vim.api.nvim_create_user_command('QtSmartSelector', function()
    ensure_loaded()
    require('qt-assistant').smart_project_selector()
end, { desc = 'Smart project selector (auto open)' })

vim.api.nvim_create_user_command('QtChooseProject', function()
    ensure_loaded()
    require('qt-assistant').smart_project_selector_with_choice()
end, { desc = 'Choose project from all available options' })

vim.api.nvim_create_user_command('QtQuickSwitcher', function()
    ensure_loaded()
    require('qt-assistant').quick_project_switcher()
end, { desc = 'Quick project switcher (recent projects)' })

vim.api.nvim_create_user_command('QtGlobalSearch', function()
    ensure_loaded()
    require('qt-assistant').global_search_projects()
end, { desc = 'Global search Qt projects across all drives' })

vim.api.nvim_create_user_command('QtDesignerManager', function()
    ensure_loaded()
    require('qt-assistant').show_designer_manager()
end, { desc = 'Open Qt Designer manager' })

vim.api.nvim_create_user_command('QtBuildStatus', function()
    ensure_loaded()
    require('qt-assistant').show_build_status()
end, { desc = 'Show Qt build status' })

vim.api.nvim_create_user_command('QtSystemInfo', function()
    ensure_loaded()
    require('qt-assistant').show_system_info()
end, { desc = 'Show Qt system information' })

vim.api.nvim_create_user_command('QtKeymaps', function()
    ensure_loaded()
    require('qt-assistant').show_keymaps()
end, { desc = 'Show Qt Assistant keymaps' })

-- 添加交互式类创建命令
vim.api.nvim_create_user_command('QtQuickClass', function()
    ensure_loaded()
    require('qt-assistant').quick_create_class()
end, { desc = 'Quick class creator (interactive)' })

vim.api.nvim_create_user_command('QtCreateMainWindow', function()
    ensure_loaded()
    require('qt-assistant').create_class_interactive('main_window')
end, { desc = 'Create main window class (interactive)' })

vim.api.nvim_create_user_command('QtCreateDialog', function()
    ensure_loaded()
    require('qt-assistant').create_class_interactive('dialog')
end, { desc = 'Create dialog class (interactive)' })

vim.api.nvim_create_user_command('QtCreateWidget', function()
    ensure_loaded()
    require('qt-assistant').create_class_interactive('widget')
end, { desc = 'Create widget class (interactive)' })

vim.api.nvim_create_user_command('QtCreateModelClass', function()
    ensure_loaded()
    require('qt-assistant').create_class_interactive('model')
end, { desc = 'Create model class (interactive)' })

vim.api.nvim_create_user_command('QtCreateThread', function()
    ensure_loaded()
    require('qt-assistant').create_class_interactive('thread')
end, { desc = 'Create thread class (interactive)' })

vim.api.nvim_create_user_command('QtCreateDelegate', function()
    ensure_loaded()
    require('qt-assistant').create_class_interactive('delegate')
end, { desc = 'Create delegate class (interactive)' })

vim.api.nvim_create_user_command('QtCreateUtility', function()
    ensure_loaded()
    require('qt-assistant').create_class_interactive('utility')
end, { desc = 'Create utility class (interactive)' })

vim.api.nvim_create_user_command('QtCreateSingleton', function()
    ensure_loaded()
    require('qt-assistant').create_class_interactive('singleton')
end, { desc = 'Create singleton class (interactive)' })

-- 设置默认快捷键
local function setup_keymaps()
    local map = vim.keymap.set
    
    -- 基础操作
    map('n', '<leader>qc', '<cmd>QtAssistant<cr>', { desc = 'Qt Assistant' })
    map('n', '<leader>qh', '<cmd>help qt-assistant<cr>', { desc = 'Qt Help' })
    
    -- 快速类创建
    map('n', '<leader>qcc', '<cmd>QtQuickClass<cr>', { desc = 'Quick Class Creator' })
    map('n', '<leader>qcw', '<cmd>QtCreateMainWindow<cr>', { desc = 'Create Main Window' })
    map('n', '<leader>qcd', '<cmd>QtCreateDialog<cr>', { desc = 'Create Dialog' })
    map('n', '<leader>qcv', '<cmd>QtCreateWidget<cr>', { desc = 'Create Widget' })
    map('n', '<leader>qcm', '<cmd>QtCreateModelClass<cr>', { desc = 'Create Model' })
    
    -- 项目管理
    map('n', '<leader>qpo', '<cmd>QtSmartSelector<cr>', { desc = 'Smart Open Project' })
    map('n', '<leader>qpm', '<cmd>QtProjectManager<cr>', { desc = 'Project Manager' })
    map('n', '<leader>qpc', '<cmd>QtChooseProject<cr>', { desc = 'Choose Project' })
    map('n', '<leader>qpw', '<cmd>QtQuickSwitcher<cr>', { desc = 'Quick Project Switcher' })
    map('n', '<leader>qpr', '<cmd>QtRecentProjects<cr>', { desc = 'Recent Projects' })
    map('n', '<leader>qps', '<cmd>QtSearchProjects<cr>', { desc = 'Search Projects' })
    map('n', '<leader>qpg', '<cmd>QtGlobalSearch<cr>', { desc = 'Global Search' })
    
    -- 构建管理
    map('n', '<leader>qb', '<cmd>QtBuildProject<cr>', { desc = 'Build Project' })
    map('n', '<leader>qr', '<cmd>QtRunProject<cr>', { desc = 'Run Project' })
    map('n', '<leader>qcl', '<cmd>QtCleanProject<cr>', { desc = 'Clean Project' })
    map('n', '<leader>qbs', '<cmd>QtBuildStatus<cr>', { desc = 'Build Status' })
    
    -- UI设计师
    map('n', '<leader>qud', '<cmd>QtOpenDesigner<cr>', { desc = 'Open Designer' })
    map('n', '<leader>quc', '<cmd>QtOpenDesignerCurrent<cr>', { desc = 'Designer Current' })
    map('n', '<leader>qum', '<cmd>QtDesignerManager<cr>', { desc = 'Designer Manager' })
    
    -- 脚本管理
    map('n', '<leader>qsb', '<cmd>QtScript build<cr>', { desc = 'Script Build' })
    map('n', '<leader>qsr', '<cmd>QtScript run<cr>', { desc = 'Script Run' })
    map('n', '<leader>qsd', '<cmd>QtScript debug<cr>', { desc = 'Script Debug' })
    map('n', '<leader>qsc', '<cmd>QtScript clean<cr>', { desc = 'Script Clean' })
    map('n', '<leader>qst', '<cmd>QtScript test<cr>', { desc = 'Script Test' })
    map('n', '<leader>qsp', '<cmd>QtScript deploy<cr>', { desc = 'Script Deploy' })
    map('n', '<leader>qsa', '<cmd>QtGenerateAllScripts<cr>', { desc = 'Generate All Scripts' })
    map('n', '<leader>qsI', '<cmd>QtInitScripts<cr>', { desc = 'Init Scripts' })
    map('n', '<leader>qsg', '<cmd>QtGenerateScripts<cr>', { desc = 'Generate Scripts' })
    map('n', '<leader>qsG', '<cmd>QtScriptGenerator<cr>', { desc = 'Script Generator' })
    map('n', '<leader>qse', '<cmd>QtEditScript<cr>', { desc = 'Edit Script' })
    
    -- 系统信息
    map('n', '<leader>qis', '<cmd>QtSystemInfo<cr>', { desc = 'System Info' })
    map('n', '<leader>qik', '<cmd>QtKeymaps<cr>', { desc = 'Show Keymaps' })
end

-- 自动设置快捷键
setup_keymaps()

-- 自动初始化插件配置
vim.schedule(function()
    ensure_loaded()
    local ok, qt_assistant = pcall(require, 'qt-assistant')
    if ok and qt_assistant.setup then
        qt_assistant.setup({})
    end
end)