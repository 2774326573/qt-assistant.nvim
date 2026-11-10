-- Headless checks for qt-assistant.nvim.
-- Covers module load, user commands, keymap/callback resolution, and build-system detection.

local failures = {}
local passed = 0

local function check(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        io.stdout:write('ok   ' .. name .. '\n')
    else
        table.insert(failures, name .. ': ' .. tostring(err))
        io.stderr:write('FAIL ' .. name .. ': ' .. tostring(err) .. '\n')
    end
end

local function eq(actual, expected, msg)
    if actual ~= expected then
        error((msg or 'values differ') .. '\n  expected: ' .. vim.inspect(expected) .. '\n  actual:   ' .. vim.inspect(actual), 2)
    end
end

local function truthy(value, msg)
    if not value then
        error(msg or 'expected truthy value', 2)
    end
end

local root = vim.fn.getcwd()
local function read_source(path)
    local lines = vim.fn.readfile(root .. '/' .. path)
    if not lines or #lines == 0 then
        error('unable to read ' .. path)
    end
    return table.concat(lines, '\n')
end

local REQUIRED_MODULES = {
    'qt-assistant',
    'qt-assistant.build_manager',
    'qt-assistant.cmake',
    'qt-assistant.config',
    'qt-assistant.core',
    'qt-assistant.debug',
    'qt-assistant.designer',
    'qt-assistant.file_manager',
    'qt-assistant.history',
    'qt-assistant.lsp',
    'qt-assistant.project_manager',
    'qt-assistant.scripts',
    'qt-assistant.system',
    'qt-assistant.templates',
    'qt-assistant.ui',
}

-- Every user command must resolve to these real functions.
local COMMAND_TARGETS = {
    QtAssistant = { { 'qt-assistant', 'show_main_interface' } },
    QtNewProject = {
        { 'qt-assistant.project_manager', 'new_project' },
        { 'qt-assistant.project_manager', 'new_project_interactive' },
        { 'qt-assistant.project_manager', 'new_project_interactive_preset' },
    },
    QtOpenProject = {
        { 'qt-assistant', 'open_project' },
        { 'qt-assistant', 'open_project_interactive' },
    },
    QtAddModule = {
        { 'qt-assistant.project_manager', 'add_module' },
        { 'qt-assistant.project_manager', 'add_module_interactive' },
        { 'qt-assistant.project_manager', 'get_available_module_types' },
    },
    QtNewUi = {
        { 'qt-assistant', 'create_new_ui' },
        { 'qt-assistant', 'create_new_ui_interactive' },
    },
    QtEditUi = {
        { 'qt-assistant', 'edit_ui_file' },
        { 'qt-assistant.designer', 'select_ui_file_to_open' },
    },
    QtDesigner = { { 'qt-assistant', 'open_designer' } },
    QtCreateClass = {
        { 'qt-assistant', 'create_class' },
        { 'qt-assistant', 'create_class_from_ui' },
        { 'qt-assistant', 'create_class_interactive' },
    },
    QtBuild = { { 'qt-assistant', 'build_project' }, { 'qt-assistant.build_manager', 'build_project' } },
    QtRun = { { 'qt-assistant', 'run_project' }, { 'qt-assistant.build_manager', 'run_project' } },
    QtClean = { { 'qt-assistant', 'clean_project' }, { 'qt-assistant.build_manager', 'clean_project' } },
    QtInstall = { { 'qt-assistant', 'install_project' }, { 'qt-assistant.build_manager', 'install_project' } },
    QtPackage = { { 'qt-assistant', 'package_project' }, { 'qt-assistant.build_manager', 'package_project' } },
    QtCMakePresets = { { 'qt-assistant.cmake', 'generate_cmake_presets' } },
    QtBuildPreset = {
        { 'qt-assistant.cmake', 'build_with_preset' },
        { 'qt-assistant.cmake', 'get_available_presets' },
    },
    QtCMakeFormat = { { 'qt-assistant.cmake', 'format_cmake_file' } },
    QtCMakeBackup = { { 'qt-assistant.cmake', 'backup_cmake_file' } },
    QtDebug = { { 'qt-assistant', 'debug_application' }, { 'qt-assistant.debug', 'debug_application' } },
    QtDebugAttach = { { 'qt-assistant', 'attach_to_process' }, { 'qt-assistant.debug', 'attach_to_process' } },
    QtDebugStatus = { { 'qt-assistant', 'show_debug_status' }, { 'qt-assistant.debug', 'show_debug_status' } },
    QtDebugSetup = { { 'qt-assistant.debug', 'setup_debugging' }, { 'qt-assistant.debug', 'init' } },
    QtScripts = {
        { 'qt-assistant.ui', 'show_script_manager' },
        { 'qt-assistant.scripts', 'get_available_scripts' },
        { 'qt-assistant.scripts', 'run_script' },
        { 'qt-assistant.scripts', 'edit_script' },
        { 'qt-assistant.scripts', 'init_scripts_directory' },
        { 'qt-assistant.scripts', 'show_script_status' },
    },
    QtHelp = { { 'qt-assistant', 'show_help' } },
    QtGenerateDoc = { { 'qt-assistant', 'generate_documentation' } },
    QtAddThirdParty = { { 'qt-assistant', 'add_third_party_library' } },
    QtCreateThirdPartyCMake = { { 'qt-assistant', 'create_third_party_cmake' } },
    QtThirdPartyDoc = { { 'qt-assistant', 'generate_third_party_doc' } },
    QtDoctor = {
        { 'qt-assistant.system', 'get_os' },
        { 'qt-assistant.system', 'find_executable' },
        { 'qt-assistant.config', 'get_vcpkg_toolchain_file' },
        { 'qt-assistant.build_manager', 'detect_build_system' },
    },
}

local KEYMAP_FUNCTIONS = {
    'show_main_interface',
    'show_help',
    'new_project_interactive',
    'new_project_quick',
    'open_project_interactive',
    'open_designer',
    'create_new_ui_interactive',
    'create_class_interactive',
    'create_class_from_current_ui',
    'create_class_from_ui_file',
    'build_project',
    'run_project',
    'quick_build_and_run',
    'build_with_std',
    'debug_application',
    'attach_to_process',
    'show_current_config',
    'select_cxx_standard',
    'reconfigure_project',
    'find_and_open_ui',
}

local function function_exists(module_name, fn_name)
    local ok, mod = pcall(require, module_name)
    if not ok then
        error('module missing: ' .. module_name .. ' (' .. tostring(mod) .. ')')
    end
    if type(mod[fn_name]) ~= 'function' then
        error(module_name .. '.' .. fn_name .. ' is ' .. type(mod[fn_name]))
    end
end

local function install_window_fallback()
    local original_open = vim.api.nvim_open_win
    vim.api.nvim_open_win = function(buf, enter, config)
        config = vim.tbl_extend('force', {}, config or {})
        local max_h = math.max(1, (vim.o.lines or 24) - 2)
        local max_w = math.max(1, (vim.o.columns or 80) - 2)
        config.height = math.max(1, math.min(config.height or max_h, max_h))
        config.width = math.max(1, math.min(config.width or max_w, max_w))
        config.row = math.max(0, config.row or 0)
        config.col = math.max(0, config.col or 0)
        local ok, win_or_err = pcall(original_open, buf, enter, config)
        if ok then
            return win_or_err
        end
        return vim.api.nvim_get_current_win()
    end
    return original_open
end

local function resolve_calls(source, label)
    local loaded = {}
    local function mod(name)
        if not loaded[name] then
            local ok, value = pcall(require, name)
            if not ok then
                error(label .. ' failed to load ' .. name .. ': ' .. tostring(value))
            end
            loaded[name] = value
        end
        return loaded[name]
    end

    for module_name, fn_name in source:gmatch("require%s*%(%s*['\"]([^'\"]+)['\"]%s*%)%.([%w_]+)%s*%(") do
        function_exists(module_name, fn_name)
        mod(module_name)
    end

    local aliases = {}
    for name, module_name in source:gmatch("local%s+([%w_]+)%s*=%s*require%s*%(%s*['\"]([^'\"]+)['\"]%s*%)") do
        aliases[name] = module_name
    end
    local pos = 1
    while true do
        local start_at, end_at, alias, fn_name = source:find("([%w_]+)%.([%w_]+)%s*%(", pos)
        if not start_at then
            break
        end
        local prev = start_at > 1 and source:sub(start_at - 1, start_at - 1) or ''
        if not prev:match('[%w_%.]') then
            local module_name = aliases[alias]
            if module_name then
                function_exists(module_name, fn_name)
            end
        end
        pos = end_at + 1
    end
end

local function temp_dir(name)
    local dir = vim.fn.tempname() .. '-' .. name
    vim.fn.mkdir(dir, 'p')
    return dir
end

local function write_file(path, lines)
    vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
    vim.fn.writefile(lines, path)
end

check('required modules exist', function()
    for _, name in ipairs(REQUIRED_MODULES) do
        local ok, mod = pcall(require, name)
        if not ok then
            error('failed to require ' .. name .. ': ' .. tostring(mod))
        end
        if type(mod) ~= 'table' then
            error(name .. ' did not return a table')
        end
    end
end)

check('debug API is present', function()
    local debug_mod = require('qt-assistant.debug')
    for _, fn_name in ipairs({ 'init', 'setup_debugging', 'debug_application', 'attach_to_process', 'show_debug_status', 'inspect_toolchain', 'launch_config' }) do
        eq(type(debug_mod[fn_name]), 'function', fn_name)
    end
    local missing = debug_mod.dap_status()
    eq(missing, false)
end)

check('debugger preference prefers codelldb then gdb on Windows', function()
    local debug_mod = require('qt-assistant.debug')
    local report = debug_mod.inspect_toolchain('windows', function(name)
        if name == 'cdb' then
            return 'C:/cdb.exe'
        elseif name == 'gdb' then
            return 'C:/gdb.exe'
        elseif name == 'codelldb' then
            return 'C:/codelldb.exe'
        end
        return nil
    end)
    eq(report.selected, 'codelldb')
    eq(report.cdb, 'C:/cdb.exe')
    eq(report.dap_capable, true)

    local cdb_only = debug_mod.inspect_toolchain('windows', function(name)
        if name == 'cdb' then
            return 'C:/cdb.exe'
        end
        return nil
    end)
    eq(cdb_only.selected, nil)
    eq(cdb_only.dap_capable, false)
    eq(cdb_only.cdb, 'C:/cdb.exe')
end)

check('linux prefers gdb over codelldb', function()
    local debug_mod = require('qt-assistant.debug')
    local report = debug_mod.inspect_toolchain('linux', function(name)
        if name == 'gdb' or name == 'codelldb' then
            return '/usr/bin/' .. name
        end
        return nil
    end)
    eq(report.selected, 'gdb')
    local launch = debug_mod.launch_config('gdb', '/tmp/demo')
    eq(launch.type, 'gdb')
    eq(launch.request, 'launch')
    eq(launch.setupCommands[1].text, '-enable-pretty-printing')
    local lldb = debug_mod.launch_config('lldb', '/tmp/demo')
    eq(lldb.setupCommands, nil)
end)

check('registered commands resolve to real functions', function()
    vim.g.loaded_qt_assistant = nil
    vim.cmd('runtime plugin/qt-assistant.lua')
    local defined = vim.api.nvim_get_commands({})
    local seen = 0
    for name in pairs(COMMAND_TARGETS) do
        seen = seen + 1
        if not defined[name] then
            error('user command is not registered: ' .. name)
        end
        for _, target in ipairs(COMMAND_TARGETS[name]) do
            function_exists(target[1], target[2])
        end
    end
    truthy(seen >= 26, 'expected at least 26 commands, mapped ' .. seen)
    local source = read_source('plugin/qt-assistant.lua')
    for name in source:gmatch("nvim_create_user_command%s*%(%s*['\"](Qt[%w_]+)['\"]") do
        if not COMMAND_TARGETS[name] then
            error('registered command has no function target in the test map: ' .. name)
        end
    end
end)

check('command, keymap, and UI callbacks resolve', function()
    resolve_calls(read_source('plugin/qt-assistant.lua'), 'plugin')
    resolve_calls(read_source('lua/qt-assistant.lua'), 'qt-assistant')
    resolve_calls(read_source('lua/qt-assistant/ui.lua'), 'ui')

    local qa = require('qt-assistant')
    local source = read_source('lua/qt-assistant.lua')
    local body = source:match('function M%.setup_keymaps%(%)(.-)\nfunction M%.quick_build_and_run')
    truthy(body, 'setup_keymaps body was not found')
    local seen = {}
    for fn_name in body:gmatch('M%.([%w_]+)%s*%(') do
        seen[fn_name] = true
        eq(type(qa[fn_name]), 'function', 'keymap calls missing qt-assistant.' .. fn_name)
    end
    for _, fn_name in ipairs(KEYMAP_FUNCTIONS) do
        if not seen[fn_name] then
            error('documented keymap function is not referenced by setup_keymaps: ' .. fn_name)
        end
    end

    local ui = require('qt-assistant.ui')
    local ui_source = read_source('lua/qt-assistant/ui.lua')
    for fn_name in ui_source:gmatch('M%.([%w_]+)%s*%(') do
        eq(type(ui[fn_name]), 'function', 'ui callback missing qt-assistant.ui.' .. fn_name)
    end
end)

check('build system detection prefers cmake, then qmake, then xmake', function()
    local config = require('qt-assistant.config')
    local build_manager = require('qt-assistant.build_manager')
    local base = temp_dir('detect')

    local function detect(dir, preference)
        config.setup({
            project_root = dir,
            build_system = preference or 'auto',
            enable_default_keymaps = false,
            vcpkg = { enabled = false },
        })
        return build_manager.detect_build_system(dir)
    end

    local empty = base .. '/empty'
    vim.fn.mkdir(empty, 'p')
    eq(detect(empty), nil)

    local cmake_dir = base .. '/cmake'
    write_file(cmake_dir .. '/CMakeLists.txt', { 'cmake_minimum_required(VERSION 3.16)', 'project(Demo)' })
    eq(detect(cmake_dir), 'cmake')

    local qmake_dir = base .. '/qmake'
    write_file(qmake_dir .. '/demo.pro', { 'QT += core', 'TARGET = demo' })
    eq(detect(qmake_dir), 'qmake')

    local xmake_dir = base .. '/xmake'
    write_file(xmake_dir .. '/xmake.lua', { 'target("demo")', '    add_rules("qt.console")' })
    eq(detect(xmake_dir), 'xmake')

    local both = base .. '/both'
    write_file(both .. '/CMakeLists.txt', { 'project(Both)' })
    write_file(both .. '/xmake.lua', { 'target("both")' })
    write_file(both .. '/both.pro', { 'QT += core' })
    eq(detect(both, 'auto'), 'cmake', 'auto detection must keep cmake ahead of qmake and xmake')
    eq(detect(both, 'xmake'), 'xmake')
    eq(detect(both, 'qmake'), 'qmake')
    eq(detect(cmake_dir, 'xmake'), 'cmake', 'missing xmake.lua falls back to the file that exists')

    local project_manager = require('qt-assistant.project_manager')
    eq(project_manager.detect_project_type(xmake_dir), 'xmake')
    eq(project_manager.detect_project_type(cmake_dir), 'cmake')
    eq(project_manager.detect_project_type(qmake_dir), 'qmake')
end)

check('xmake build, clean, install, and run argv', function()
    local build_manager = require('qt-assistant.build_manager')
    eq(build_manager.xmake_mode('Debug'), 'debug')
    eq(build_manager.xmake_mode('Release'), 'release')
    eq(build_manager.xmake_mode('RelWithDebInfo'), 'releasedbg')

    local build_cmd = build_manager.xmake_build_argv('/usr/bin/xmake', '/work/demo', 'Debug')
    eq(table.concat(build_cmd, ' '), '/usr/bin/xmake -P /work/demo -m debug -y')
    local clean_cmd = build_manager.xmake_clean_argv('/usr/bin/xmake', '/work/demo')
    eq(clean_cmd[4], 'clean')
    local install_cmd = build_manager.xmake_install_argv('/usr/bin/xmake', '/work/demo', '/opt/demo')
    eq(table.concat(install_cmd, ' '), '/usr/bin/xmake -P /work/demo install -y -o /opt/demo')
    local run_cmd = build_manager.xmake_run_argv('/usr/bin/xmake', '/work/demo', 'Release')
    eq(table.concat(run_cmd, ' '), '/usr/bin/xmake -P /work/demo -m release run -y')
    eq(table.concat(build_manager.cmake_clean_argv('cmake', '/work/demo/build'), ' '), 'cmake --build /work/demo/build --target clean')
end)

check('xmake build is dispatched through Qt build_project', function()
    local dir = temp_dir('xmake-build')
    write_file(dir .. '/xmake.lua', {
        'add_rules("mode.debug", "mode.release")',
        'target("demo")',
        '    add_rules("qt.console")',
    })
    require('qt-assistant.config').setup({
        project_root = dir,
        build_system = 'auto',
        enable_default_keymaps = false,
        vcpkg = { enabled = false },
    })

    local system = require('qt-assistant.system')
    local original_find = system.find_executable
    local original_jobstart = vim.fn.jobstart
    local captured
    system.find_executable = function(name)
        if name == 'xmake' or name == 'xmake.exe' then
            return '/usr/bin/xmake'
        end
        return original_find(name)
    end
    vim.fn.jobstart = function(cmd, opts)
        captured = { cmd = cmd, cwd = opts and opts.cwd }
        if opts and opts.on_exit then
            vim.schedule(function()
                opts.on_exit(1, 0)
            end)
        end
        return 1
    end

    local ok_call, err = pcall(function()
        require('qt-assistant.build_manager').build_project('Debug')
        local finished = vim.wait(1000, function()
            return captured ~= nil
        end)
        truthy(finished, 'xmake build did not start')
        eq(captured.cmd[1], '/usr/bin/xmake')
        eq(table.concat(captured.cmd, ' '), '/usr/bin/xmake -P ' .. dir .. ' -m debug -y')
        eq(captured.cwd, dir)
    end)

    system.find_executable = original_find
    vim.fn.jobstart = original_jobstart
    if not ok_call then
        error(err)
    end
end)

check('xmake executable lookup and project generation', function()
    local dir = temp_dir('xmake-gen')
    local project_root = dir .. '/generated'
    vim.fn.mkdir(project_root .. '/build/linux/x86_64/debug', 'p')
    local exe = project_root .. '/build/linux/x86_64/debug/WidgetDemo'
    write_file(exe, { '' })
    vim.fn.setfperm(exe, 'rwxr-xr-x')

    local project_manager = require('qt-assistant.project_manager')
    local content = project_manager.generate_xmake_content('widget_app', 'WidgetDemo', '17', {
        enable_tests = true,
        test_framework = 'qt',
    })
    truthy(content:find('qt%.widgetapp', 1), 'widget rule missing')
    truthy(content:find('c%+%+17', 1), 'c++ standard missing')
    truthy(content:find('WidgetDemo_tests', 1, true), 'test target missing')
    truthy(content:find('ui/%*%.ui', 1) or content:find('ui/*.ui', 1, true), 'ui files missing')

    local created = project_manager.new_project('WidgetDemo', 'widget_app', '17', dir, {
        enable_tests = false,
        generate_xmake = true,
    })
    eq(created, true)
    local generated_root = dir .. '/WidgetDemo'
    eq(vim.fn.filereadable(generated_root .. '/CMakeLists.txt'), 1)
    eq(vim.fn.filereadable(generated_root .. '/xmake.lua'), 1)
    eq(vim.fn.filereadable(generated_root .. '/src/main.cpp'), 1)
    local generated = table.concat(vim.fn.readfile(generated_root .. '/xmake.lua'), '\n')
    truthy(generated:find('qt%.widgetapp', 1), 'generated xmake.lua is not a Qt widget app')

    require('qt-assistant.config').setup({
        project_root = project_root,
        build_system = 'xmake',
        enable_default_keymaps = false,
    })
    write_file(project_root .. '/xmake.lua', content)
    local found = require('qt-assistant.build_manager').find_project_executable('Debug')
    eq(found, exe)
end)

check('scripts module serves builtins and file overrides', function()
    local dir = temp_dir('scripts')
    require('qt-assistant.config').setup({
        project_root = dir,
        enable_default_keymaps = false,
        vcpkg = { enabled = false },
    })
    local scripts = require('qt-assistant.scripts')
    local available = scripts.get_available_scripts()
    eq(#available, 5)
    eq(available[1].name, 'build')
    eq(scripts.init_scripts_directory(), true)
    eq(vim.fn.filereadable(dir .. '/scripts/README.md'), 1)
    write_file(dir .. '/scripts/build.sh', { '#!/bin/sh', '# custom build', 'echo build' })
    local overridden = false
    local builtin_hidden = true
    for _, script in ipairs(scripts.get_available_scripts()) do
        if script.name == 'build' and script.builtin then
            builtin_hidden = false
        elseif script.name == 'build' and script.path then
            overridden = true
            eq(script.description, 'custom build')
        end
    end
    eq(overridden, true)
    eq(builtin_hidden, true)
    eq(scripts.edit_script('clean'), false)
end)

check('keymap callbacks can run', function()
    local dir = temp_dir('keymaps')
    write_file(dir .. '/sample.ui', {
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<ui version="4.0"><class>Sample</class>',
        '<widget class="QWidget" name="Sample"/>',
        '</ui>',
    })
    vim.cmd('cd ' .. vim.fn.fnameescape(dir))
    local qa = require('qt-assistant')
    qa.setup({
        project_root = dir,
        enable_default_keymaps = true,
        keymaps = { preset = 'full' },
        vcpkg = { enabled = false },
        export = { enabled = false },
    })

    local original_input = vim.fn.input
    local original_inputlist = vim.fn.inputlist
    local original_ui_input = vim.ui.input
    local original_ui_select = vim.ui.select
    local original_notify = vim.notify
    local original_open = install_window_fallback()
    vim.fn.input = function()
        return ''
    end
    vim.fn.inputlist = function()
        return 0
    end
    vim.ui.input = function(_, cb)
        if cb then
            cb(nil)
        end
    end
    vim.ui.select = function(_, _, cb)
        if cb then
            cb(nil)
        end
    end

    local ok_call, err = pcall(function()
        local function invoke(mode, bufnr)
            local maps = vim.api.nvim_get_keymap(mode)
            if bufnr then
                maps = vim.api.nvim_buf_get_keymap(bufnr, mode)
            end
            for _, map in ipairs(maps) do
                local lhs = map.lhs or ''
                local mine = lhs:find('q', 1, true) or lhs:find('gd', 1, true) or lhs:find('gc', 1, true) or lhs:find('gu', 1, true)
                if mine and map.callback then
                    local ran, callback_err = pcall(map.callback)
                    if not ran then
                        error('keymap ' .. lhs .. ' failed: ' .. tostring(callback_err))
                    end
                end
            end
        end
        invoke('n')
        vim.cmd('edit ' .. vim.fn.fnameescape(dir .. '/sample.ui'))
        invoke('n', vim.api.nvim_get_current_buf())
        vim.cmd('enew')
        local cpp = dir .. '/sample.cpp'
        write_file(cpp, { 'int main(){return 0;}' })
        vim.cmd('edit ' .. vim.fn.fnameescape(cpp))
        invoke('n', vim.api.nvim_get_current_buf())
        local ui = require('qt-assistant.ui')
        ui.show_class_creator()
        ui.show_script_manager()
        ui.show_project_manager()
        ui.show_designer_manager()
        ui.show_build_manager()
    end)

    vim.wait(50)
    vim.notify = original_notify
    vim.api.nvim_open_win = original_open
    vim.fn.input = original_input
    vim.fn.inputlist = original_inputlist
    vim.ui.input = original_ui_input
    vim.ui.select = original_ui_select
    vim.cmd('cd ' .. vim.fn.fnameescape(root))
    if not ok_call then
        error(err)
    end
end)

check('every user command loads without error', function()
    local dir = temp_dir('commands')
    write_file(dir .. '/CMakeLists.txt', {
        'cmake_minimum_required(VERSION 3.16)',
        'project(Smoke LANGUAGES CXX)',
    })
    vim.cmd('cd ' .. vim.fn.fnameescape(dir))
    require('qt-assistant.config').setup({
        project_root = dir,
        enable_default_keymaps = false,
        vcpkg = { enabled = false },
        export = { enabled = false },
        third_party = { enabled = false },
    })

    local original_input = vim.fn.input
    local original_inputlist = vim.fn.inputlist
    local original_ui_input = vim.ui.input
    local original_ui_select = vim.ui.select
    local original_notify = vim.notify
    local original_jobstart = vim.fn.jobstart
    local original_open = install_window_fallback()
    vim.notify = function(msg, level)
        io.stdout:write(string.format('notify %s: %s\n', tostring(level), tostring(msg):gsub('\n', ' | ')))
    end
    vim.fn.input = function()
        return ''
    end
    vim.fn.inputlist = function()
        return 0
    end
    vim.ui.input = function(_, cb)
        if cb then
            cb(nil)
        end
    end
    vim.ui.select = function(_, _, cb)
        if cb then
            cb(nil)
        end
    end
    vim.fn.jobstart = function(_, opts)
        if opts and opts.on_exit then
            vim.schedule(function()
                opts.on_exit(1, 0)
            end)
        end
        return 1
    end
    vim.api.nvim_open_win = function(buf, enter, config)
        config = vim.tbl_extend('force', {}, config or {})
        local max_h = math.max(1, (vim.o.lines or 24) - 2)
        local max_w = math.max(1, (vim.o.columns or 80) - 2)
        if not config.height or config.height > max_h then
            config.height = math.min(max_h, config.height or max_h)
        end
        if not config.width or config.width > max_w then
            config.width = math.min(max_w, config.width or max_w)
        end
        if config.height < 1 then
            config.height = 1
        end
        if config.width < 1 then
            config.width = 1
        end
        config.row = math.max(0, config.row or 0)
        config.col = math.max(0, config.col or 0)
        local ok, win_or_err = pcall(original_open, buf, enter, config)
        if ok then
            return win_or_err
        end
        return vim.api.nvim_get_current_win()
    end

    local ok_call, err = pcall(function()
        local commands = {}
        for name in pairs(COMMAND_TARGETS) do
            table.insert(commands, name)
        end
        table.sort(commands)
        for _, name in ipairs(commands) do
            local ran, cmd_err = pcall(vim.cmd, name)
            if not ran then
                error(name .. ' failed: ' .. tostring(cmd_err))
            end
        end
        vim.wait(200)
    end)

    vim.notify = original_notify
    vim.fn.input = original_input
    vim.fn.inputlist = original_inputlist
    vim.ui.input = original_ui_input
    vim.ui.select = original_ui_select
    vim.fn.jobstart = original_jobstart
    vim.api.nvim_open_win = original_open
    vim.cmd('cd ' .. vim.fn.fnameescape(root))
    if not ok_call then
        error(err)
    end
end)

io.stdout:write(string.format('\n%d passed, %d failed\n', passed, #failures))
io.stdout:flush()
if #failures > 0 then
    vim.cmd('cquit 1')
else
    vim.cmd('qa!')
end
