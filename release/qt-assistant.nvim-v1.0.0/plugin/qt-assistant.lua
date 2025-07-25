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

vim.api.nvim_create_user_command('QtInitScripts', function()
    ensure_loaded()
    require('qt-assistant').init_scripts()
end, { desc = 'Initialize Qt project scripts' })

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