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
        local args = {}
        for _, part in ipairs(vim.split(opts.args, '%s+')) do
            if part ~= '' then
                table.insert(args, part)
            end
        end
        if #args >= 3 then
            -- QtNewProject <name> <template> [cxx_standard] [tests|gtest] [xmake]
            local project_manager = require('qt-assistant.core.project_manager')
            local enable_tests = false
            local test_framework = nil
            local generate_xmake = false
            local cxx_standard = nil
            for i = 3, #args do
                local flag = tostring(args[i]):lower()
                if flag == 'tests' or flag == 'test' or flag == 'with_tests' then
                    enable_tests = true
                    test_framework = 'qt'
                elseif flag == 'gtest' or flag == 'googletest' then
                    enable_tests = true
                    test_framework = 'gtest'
                elseif flag == 'xmake' then
                    generate_xmake = true
                elseif flag:match('^%d%d$') then
                    cxx_standard = flag
                end
            end
            project_manager.new_project(args[1], args[2], cxx_standard or '17', nil, {
                enable_tests = enable_tests,
                test_framework = test_framework,
                generate_xmake = generate_xmake,
            })
        elseif #args >= 2 then
            -- QtNewProject <name> <template>
            -- Semi-interactive: still prompt for location/tests/C++ standard
            local project_manager = require('qt-assistant.core.project_manager')
            project_manager.new_project_interactive_preset(args[1], args[2])
        else
            -- Interactive mode
            local project_manager = require('qt-assistant.core.project_manager')
            project_manager.new_project_interactive()
        end
    end
end, { 
    nargs = '*',
    desc = 'Create new Qt project [name] [template] [cxx_standard] [tests|gtest] [xmake]',
    complete = function(arg_lead, cmd_line, cursor_pos)
        local args = vim.split(cmd_line, '%s+')
        local arg_count = #args - 1  -- Subtract command name
        
        if arg_count == 1 then
            -- Complete template type
            return {'widget_app', 'console_app', 'quick_app', 'static_lib', 'shared_lib', 'plugin'}
        elseif arg_count == 2 then
            -- Complete C++ standard
            return {'11', '14', '17', '20', '23'}
        elseif arg_count >= 3 then
            return {'tests', 'gtest', 'xmake', '11', '14', '17', '20', '23'}
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
        -- QtAddModule <name> <type> [tests|gtest]
        local enable_tests = false
        local test_framework = nil
        if #args >= 3 then
            local flag = tostring(args[3]):lower()
            if flag == 'tests' or flag == 'test' or flag == 'with_tests' then
                enable_tests = true
                test_framework = 'qt'
            elseif flag == 'gtest' or flag == 'googletest' then
                enable_tests = true
                test_framework = 'gtest'
            end
        end
        require('qt-assistant.core.project_manager').add_module(args[1], args[2], nil, { enable_tests = enable_tests, test_framework = test_framework })
    else
        require('qt-assistant.core.project_manager').add_module_interactive()
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
            local project_manager = require('qt-assistant.core.project_manager')
            return project_manager.get_available_module_types()
        elseif #args == 4 then
            return { 'tests', 'gtest' }
        end
        return {}
    end,
    desc = 'Add module to multi-module Qt project [name] [type] [tests|gtest]'
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
        local designer = require("qt-assistant.core.designer")
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
            return {'main_window', 'dialog', 'widget', 'model', 'delegate', 'thread', 'utility', 'singleton'}
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

vim.api.nvim_create_user_command('QtClean', function()
    if not ensure_loaded() then return end
    require('qt-assistant').clean_project()
end, { desc = 'Clean Qt project (CMake, qmake, or xmake)' })

vim.api.nvim_create_user_command('QtInstall', function(opts)
    if not ensure_loaded() then return end
    local prefix = opts.args ~= '' and opts.args or nil
    require('qt-assistant').install_project(prefix)
end, {
    nargs = '?',
    desc = 'Install CMake or xmake project (optional prefix)',
    complete = 'dir'
})

vim.api.nvim_create_user_command('QtPackage', function()
    if not ensure_loaded() then return end
    require('qt-assistant').package_project()
end, { desc = 'Package CMake project via CPack' })

-- ==================== CMake Commands ====================

vim.api.nvim_create_user_command('QtCMakePresets', function(opts)
    if not ensure_loaded() then return end
    local generator = opts and opts.args ~= '' and opts.args or nil
    require('qt-assistant.core.cmake').generate_cmake_presets(generator)
end, { desc = 'Generate CMakePresets.json for Qt project', nargs = '?' })

vim.api.nvim_create_user_command('QtBuildPreset', function(opts)
    if not ensure_loaded() then return end
    local preset = opts.args ~= '' and opts.args or nil
    require('qt-assistant.core.cmake').build_with_preset(preset)
end, {
    desc = 'Build Qt project with CMake preset',
    nargs = '?',
    complete = function()
        local cmake = require('qt-assistant.core.cmake')
        return cmake.get_available_presets()
    end
})

vim.api.nvim_create_user_command('QtCMakeFormat', function()
    if not ensure_loaded() then return end
    require('qt-assistant.core.cmake').format_cmake_file()
end, { desc = 'Format CMakeLists.txt file' })

vim.api.nvim_create_user_command('QtCMakeBackup', function()
    if not ensure_loaded() then return end
    require('qt-assistant.core.cmake').backup_cmake_file()
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
    require('qt-assistant.core.debug').setup_debugging()
end, { desc = 'Setup complete Qt debugging environment' })

vim.api.nvim_create_user_command('QtTemplatesReload', function()
    local ok, templates = pcall(require, 'qt-assistant.core.templates')
    if ok then
        templates.load_builtin_templates()
        vim.notify('Qt助手: 内置模板已重新加载 (templates/ 目录)', vim.log.levels.INFO)
    end
end, { desc = 'Reload built-in Qt templates from templates/ directory' })

vim.api.nvim_create_user_command('QtTemplatesOpenCustomDir', function()
    local config = require('qt-assistant.core.config').get()
    local dir = config.templates and config.templates.custom_dir
    if not dir then
        vim.notify('Qt助手: 未配置 templates.custom_dir (在 setup 中设置宿主自定义模板目录)', vim.log.levels.WARN)
        return
    end
    if vim.fn.isdirectory(dir) == 1 then
        if vim.fn.has('win32') == 1 then
            vim.fn.system('explorer.exe ' .. vim.fn.shellescape(dir))
        end
    else
        vim.notify('Qt助手: 目录不存在: ' .. dir, vim.log.levels.ERROR)
    end
end, { desc = 'Open the host custom template directory' })

-- ==================== Help ====================

vim.api.nvim_create_user_command('QtScripts', function()
    if not ensure_loaded() then return end
    require('qt-assistant.ui').show_script_manager()
end, { desc = 'Open the Qt project script manager' })

vim.api.nvim_create_user_command('QtHelp', function()
    if not ensure_loaded() then return end
    require('qt-assistant').show_help()
end, { desc = 'Show Qt Assistant help' })

-- ==================== Documentation ====================

-- 离线文档查询 (docset: SQLite 索引 + HTML, 纯 nvim 内渲染, 无需外部程序)
vim.api.nvim_create_user_command('QtDocs', function(opts)
    if not ensure_loaded() then return end
    require('qt-assistant.core.docset').show(opts.args)
end, {
    nargs = '?',
    desc = 'Qt offline docs: search docset and render page in nvim (defaults to <cword>)',
    complete = function(arg_lead)
        pcall(ensure_loaded)
        local ok, docset = pcall(require, 'qt-assistant.core.docset')
        if ok then
            return docset.complete(arg_lead)
        end
        return {}
    end
})

vim.api.nvim_create_user_command('QtGenerateDoc', function(opts)
    if not ensure_loaded() then return end
    local args = {}
    for _, part in ipairs(vim.split(opts.args, '%s+')) do
        if part ~= '' then
            table.insert(args, part)
        end
    end
    local doc_type = args[1] or "project_doc"
    local output_file = args[2]
    require('qt-assistant').generate_documentation(doc_type, output_file)
end, {
    nargs = '*',
    desc = 'Generate documentation [type] [output_file]',
    complete = function(arg_lead, cmd_line, cursor_pos)
        local args = vim.split(cmd_line, '%s+')
        local arg_count = #args - 1
        
        if arg_count == 1 then
            return {'project_doc', 'api_doc', 'module_doc', 'third_party_lib_doc'}
        elseif arg_count == 2 then
            return {'file'}
        end
        return {}
    end
})

-- ==================== Third-party Library Management ====================

vim.api.nvim_create_user_command('QtAddThirdParty', function()
    if not ensure_loaded() then return end
    require('qt-assistant').add_third_party_library()
end, { desc = 'Add third-party library configuration' })

vim.api.nvim_create_user_command('QtCreateThirdPartyCMake', function()
    if not ensure_loaded() then return end
    require('qt-assistant').create_third_party_cmake()
end, { desc = 'Create third-party CMake configuration file' })

vim.api.nvim_create_user_command('QtThirdPartyDoc', function()
    if not ensure_loaded() then return end
    require('qt-assistant').generate_third_party_doc()
end, { desc = 'Generate third-party library integration documentation' })

-- ==================== Diagnostics ====================

vim.api.nvim_create_user_command('QtDoctor', function()
    if not ensure_loaded() then return end

    local config = require('qt-assistant.core.config').get()
    local system = require('qt-assistant.core.system')

    local function fmt(v)
        if v == nil then return 'nil' end
        if v == vim.NIL then return 'nil' end
        if type(v) == 'boolean' then return v and 'true' or 'false' end
        return tostring(v)
    end

    local vcpkg_root = config.vcpkg and config.vcpkg.vcpkg_root or nil
    local vcpkg_enabled = config.vcpkg and config.vcpkg.enabled or false
    local toolchain = require('qt-assistant.core.config').get_vcpkg_toolchain_file()

    vim.notify('QtDoctor: os=' .. fmt(system.get_os()), vim.log.levels.INFO)
    vim.notify('QtDoctor: vcpkg.enabled=' .. fmt(vcpkg_enabled), vim.log.levels.INFO)
    vim.notify('QtDoctor: vcpkg.root=' .. fmt(vcpkg_root), vim.log.levels.INFO)
    vim.notify('QtDoctor: vcpkg.toolchain=' .. fmt(toolchain), vim.log.levels.INFO)

    if config.export then
        vim.notify('QtDoctor: export.enabled=' .. fmt(config.export.enabled)
            .. ' deploy_qt=' .. fmt(config.export.deploy_qt)
            .. ' compiler_runtime=' .. fmt(config.export.deploy_compiler_runtime), vim.log.levels.INFO)
    end

    local build_manager = require('qt-assistant.core.build_manager')
    vim.notify('QtDoctor: build_system=' .. fmt(build_manager.detect_build_system())
        .. ' preference=' .. fmt(config.build_system or 'auto'), vim.log.levels.INFO)

    local tools = { 'cmake', 'qmake', 'xmake', 'windeployqt', 'macdeployqt', 'uic', 'designer', 'gdb', 'lldb', 'codelldb' }
    if system.get_os() == 'windows' then
        table.insert(tools, 'cdb')
    end
    for _, name in ipairs(tools) do
        local exe_tool = name == 'cmake' or name == 'xmake' or name == 'gdb' or name == 'lldb' or name == 'codelldb' or name == 'cdb'
        local p = exe_tool and system.find_executable(name) or system.find_qt_tool(name)
        vim.notify('QtDoctor: ' .. name .. '=' .. fmt(p), vim.log.levels.INFO)
    end
end, { desc = 'Show environment/tooling diagnostics (vcpkg/Qt tools/xmake/export)' })


-- Lazy initialization - only setup when first command is used
local initialized = false
local original_ensure_loaded = ensure_loaded

local function lazy_init()
    if initialized then
        return true
    end
    local ok, qt_assistant = pcall(require, 'qt-assistant')
    if ok and qt_assistant.setup then
        -- Do not overwrite user configuration. Only auto-setup if not already configured.
        local cfg = require('qt-assistant.core.config')
        if not cfg._config then
            qt_assistant.setup({})
        end
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
