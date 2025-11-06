-- Qt Assistant Plugin Entry Point

-- Check Neovim version
if vim.fn.has('nvim-0.8') ~= 1 then
    vim.notify('Qt Assistant requires Neovim 0.8 or higher', vim.log.levels.ERROR)
    return
end

-- Prevent duplicate loading
if vim.g.loaded_qt_assistant then
    return
end
vim.g.loaded_qt_assistant = 1

-- Lazy loading helper with error handling
local function ensure_loaded()
    if not package.loaded['qt-assistant'] then
        local ok, qt_assistant = pcall(require, 'qt-assistant')
        if not ok then
            vim.notify('Failed to load qt-assistant: ' .. qt_assistant, vim.log.levels.ERROR)
            return false
        end
    end
    return true
end

-- ==================== Core Commands ====================

-- Main interface
vim.api.nvim_create_user_command('QtAssistant', function()
    if ensure_loaded() then
        require('qt-assistant').show_main_interface()
    end
end, { desc = 'Open Qt Assistant interface' })

-- Project management
vim.api.nvim_create_user_command('QtNewProject', function(opts)
    if ensure_loaded() then
        local args = vim.split(opts.args, '%s+')
        if #args >= 3 then
            -- QtNewProject <name> <template> <cxx_standard>
            local project_manager = require('qt-assistant.project_manager')
            project_manager.new_project(args[1], args[2], args[3])
        elseif #args >= 2 then
            -- QtNewProject <name> <template>
            local project_manager = require('qt-assistant.project_manager')
            project_manager.new_project(args[1], args[2])
        else
            -- Interactive mode
            local project_manager = require('qt-assistant.project_manager')
            project_manager.new_project_interactive()
        end
    end
end, { 
    nargs = '*',
    desc = 'Create new Qt project [name] [template] [cxx_standard]',
    complete = function(arg_lead, cmd_line, cursor_pos)
        local args = vim.split(cmd_line, '%s+')
        local arg_count = #args - 1  -- Subtract command name
        
        if arg_count == 1 then
            -- Complete template type
            return {'widget_app', 'console_app', 'quick_app'}
        elseif arg_count == 2 then
            -- Complete C++ standard
            return {'11', '14', '17', '20', '23'}
        end
        return {}
    end
})

vim.api.nvim_create_user_command('QtOpenProject', function(opts)
    if not ensure_loaded() then return end
    if opts.args ~= '' then
        require('qt-assistant').open_project(opts.args)
    else
        require('qt-assistant').open_project_interactive()
    end
end, {
    nargs = '?',
    desc = 'Open Qt project',
    complete = 'dir'
})

-- ==================== Multi-Module Project Commands ====================

vim.api.nvim_create_user_command('QtAddModule', function(opts)
    if not ensure_loaded() then return end
    local args = vim.split(opts.args, '%s+')
    if #args >= 2 then
        require('qt-assistant.project_manager').add_module(args[1], args[2])
    else
        require('qt-assistant.project_manager').add_module_interactive()
    end
end, {
    nargs = '*',
    complete = function(arg_lead, cmd_line, cursor_pos)
        local args = vim.split(cmd_line, '%s+')
        if #args == 2 then
            -- Complete module name (no completion needed)
            return {}
        elseif #args == 3 then
            -- Complete module type
            local project_manager = require('qt-assistant.project_manager')
            return project_manager.get_available_module_types()
        end
        return {}
    end,
    desc = 'Add module to multi-module Qt project'
})

-- ==================== UI Designer Commands (PRD Core) ====================

vim.api.nvim_create_user_command('QtNewUi', function(opts)
    if not ensure_loaded() then return end
    if opts.args ~= '' then
        require('qt-assistant').create_new_ui(opts.args)
    else
        require('qt-assistant').create_new_ui_interactive()
    end
end, { 
    nargs = '?',
    desc = 'Create new UI file with Qt Designer'
})

vim.api.nvim_create_user_command('QtEditUi', function(opts)
    if not ensure_loaded() then return end
    if opts.args ~= '' then
        require('qt-assistant').edit_ui_file(opts.args)
    else
        local designer = require("qt-assistant.designer")
        designer.select_ui_file_to_open()
    end
end, { 
    nargs = '?',
    desc = 'Edit existing UI file with Qt Designer',
    complete = function()
        pcall(ensure_loaded)
        local ok, qt_assistant = pcall(require, 'qt-assistant')
        if ok then
            return qt_assistant.get_ui_files_for_completion()
        end
        return {}
    end
})

vim.api.nvim_create_user_command('QtDesigner', function(opts)
    if not ensure_loaded() then return end
    require('qt-assistant').open_designer(opts.args ~= '' and opts.args or nil)
end, { 
    nargs = '?',
    desc = 'Open Qt Designer',
    complete = 'file'
})

-- ==================== Class Creation Commands ====================

vim.api.nvim_create_user_command('QtCreateClass', function(opts)
    if not ensure_loaded() then return end
    local args = vim.split(opts.args, '%s+')
    if #args >= 2 then
        if #args >= 3 and args[3]:match("%.ui$") then
            -- From UI file: QtCreateClass <ClassName> <ClassType> <UIFile>
            require('qt-assistant').create_class_from_ui(args[3], args[1])
        else
            -- Regular class creation
            require('qt-assistant').create_class(args[1], args[2])
        end
    else
        require('qt-assistant').create_class_interactive()
    end
end, { 
    nargs = '*',
    desc = 'Create Qt class, optionally from UI file',
    complete = function(arglead, cmdline, cursorpos)
        local args = vim.split(cmdline, '%s+')
        if #args <= 2 then
            return {'main_window', 'dialog', 'widget', 'model'}
        elseif #args == 3 then
            pcall(ensure_loaded)
            local ok, qt_assistant = pcall(require, 'qt-assistant')
            if ok then
                return qt_assistant.get_ui_files_for_completion()
            end
        end
        return {}
    end
})

-- ==================== Build Commands ====================

vim.api.nvim_create_user_command('QtBuild', function()
    if not ensure_loaded() then return end
    require('qt-assistant').build_project()
end, { desc = 'Build Qt project' })

vim.api.nvim_create_user_command('QtRun', function()
    if not ensure_loaded() then return end
    require('qt-assistant').run_project()
end, { desc = 'Run Qt project' })

-- ==================== CMake Commands ====================

vim.api.nvim_create_user_command('QtCMakePresets', function()
    if not ensure_loaded() then return end
    require('qt-assistant.cmake').generate_cmake_presets()
end, { desc = 'Generate CMakePresets.json for Qt project' })

vim.api.nvim_create_user_command('QtBuildPreset', function(opts)
    if not ensure_loaded() then return end
    local preset = opts.args ~= '' and opts.args or nil
    require('qt-assistant.cmake').build_with_preset(preset)
end, {
    desc = 'Build Qt project with CMake preset',
    nargs = '?',
    complete = function()
        local cmake = require('qt-assistant.cmake')
        return cmake.get_available_presets()
    end
})

vim.api.nvim_create_user_command('QtCMakeFormat', function()
    if not ensure_loaded() then return end
    require('qt-assistant.cmake').format_cmake_file()
end, { desc = 'Format CMakeLists.txt file' })

vim.api.nvim_create_user_command('QtCMakeBackup', function()
    if not ensure_loaded() then return end
    require('qt-assistant.cmake').backup_cmake_file()
end, { desc = 'Backup CMakeLists.txt file' })

-- ==================== Debug Commands ====================

vim.api.nvim_create_user_command('QtDebug', function()
    if not ensure_loaded() then return end
    require('qt-assistant').debug_application()
end, { desc = 'Debug Qt application with nvim-dap' })

vim.api.nvim_create_user_command('QtDebugAttach', function()
    if not ensure_loaded() then return end
    require('qt-assistant').attach_to_process()
end, { desc = 'Attach debugger to running Qt process' })

vim.api.nvim_create_user_command('QtDebugStatus', function()
    if not ensure_loaded() then return end
    require('qt-assistant').show_debug_status()
end, { desc = 'Show Qt debug configuration status' })

vim.api.nvim_create_user_command('QtDebugSetup', function()
    if not ensure_loaded() then return end
    require('qt-assistant.debug').setup_debugging()
end, { desc = 'Setup complete Qt debugging environment' })

-- ==================== LSP Commands ====================

vim.api.nvim_create_user_command('QtLspSetup', function()
    if not ensure_loaded() then return end
    require('qt-assistant').setup_qt_lsp()
end, { desc = 'Setup clangd LSP for Qt development' })

vim.api.nvim_create_user_command('QtLspGenerate', function()
    if not ensure_loaded() then return end
    require('qt-assistant').generate_compile_commands()
end, { desc = 'Generate compile_commands.json for clangd' })

vim.api.nvim_create_user_command('QtLspStatus', function()
    if not ensure_loaded() then return end
    require('qt-assistant').show_lsp_status()
end, { desc = 'Show clangd LSP status' })

-- ==================== Help ====================

vim.api.nvim_create_user_command('QtHelp', function()
    if not ensure_loaded() then return end
    require('qt-assistant').show_help()
end, { desc = 'Show Qt Assistant help' })


-- Lazy initialization - only setup when first command is used
local initialized = false
local original_ensure_loaded = ensure_loaded

local function lazy_init()
    if initialized then
        return true
    end
    local ok, qt_assistant = pcall(require, 'qt-assistant')
    if ok and qt_assistant.setup then
        qt_assistant.setup({})
    end
    initialized = true
    return true
end

-- Override ensure_loaded to include lazy init
ensure_loaded = function()
    if not original_ensure_loaded() then
        return false
    end
    lazy_init()
    return true
end
