-- Qt Assistant - Project script manager
-- Built-in actions delegate to the plugin (build/clean/run/debug/test).
-- Files under <project>/scripts override a built-in when they share its name.

local M = {}

local BUILTINS = {
    {
        name = 'build',
        display_name = 'Build project',
        description = 'Build the current Qt project',
        builtin = true,
    },
    {
        name = 'clean',
        display_name = 'Clean build files',
        description = 'Clean the current project build',
        builtin = true,
    },
    {
        name = 'run',
        display_name = 'Run application',
        description = 'Run the built Qt application',
        builtin = true,
    },
    {
        name = 'debug',
        display_name = 'Debug application',
        description = 'Start a debug session',
        builtin = true,
    },
    {
        name = 'test',
        display_name = 'Run tests',
        description = 'Run the project test target (ctest or xmake)',
        builtin = true,
    },
}

local function project_root()
    return require('qt-assistant.config').get().project_root
end

function M.scripts_directory()
    return project_root() .. '/scripts'
end

local function builtin_by_name(name)
    for _, script in ipairs(BUILTINS) do
        if script.name == name then
            return script
        end
    end
    return nil
end

local function describe_file(path)
    local ok, lines = pcall(vim.fn.readfile, path, '', 8)
    if not ok or type(lines) ~= 'table' then
        return 'Project script'
    end
    for _, line in ipairs(lines) do
        if not line:match('^%s*#!') then
            local comment = line:match('^%s*#%s*(.+)')
                or line:match('^%s*::%s*(.+)')
                or line:match('^%s*%-%-%s*(.+)')
            if comment and comment ~= '' then
                return comment
            end
        end
    end
    return 'Project script'
end

function M.get_available_scripts()
    local scripts = {}
    local overridden = {}
    local user = {}
    local dir = M.scripts_directory()

    if vim.fn.isdirectory(dir) == 1 then
        local files = vim.fn.glob(dir .. '/*', false, true) or {}
        for _, path in ipairs(files) do
            if vim.fn.isdirectory(path) == 0 then
                local base = vim.fn.fnamemodify(path, ':t')
                if base ~= 'README.md' and not base:match('~$') and not base:match('%.md$') then
                    local name = vim.fn.fnamemodify(path, ':t:r')
                    table.insert(user, {
                        name = name,
                        display_name = base,
                        description = describe_file(path),
                        builtin = false,
                        path = path,
                    })
                    overridden[name] = true
                end
            end
        end
    end

    for _, script in ipairs(BUILTINS) do
        if not overridden[script.name] then
            table.insert(scripts, vim.tbl_extend('force', {}, script))
        end
    end

    table.sort(user, function(a, b)
        return a.name < b.name
    end)
    for _, script in ipairs(user) do
        table.insert(scripts, script)
    end
    return scripts
end

function M.show_script_status()
    local lines = {
        'Qt script status',
        'Directory: ' .. M.scripts_directory(),
        '',
    }
    local scripts = M.get_available_scripts()
    if #scripts == 0 then
        table.insert(lines, 'No scripts available.')
    end
    for _, script in ipairs(scripts) do
        local kind = script.builtin and 'built-in' or (script.path or 'file')
        table.insert(lines, string.format('%s — %s (%s)', script.name, script.description, kind))
    end
    require('qt-assistant.ui').show_info_window(lines)
    return lines
end

function M.init_scripts_directory()
    local file_manager = require('qt-assistant.file_manager')
    local dir = M.scripts_directory()
    local ok, err = file_manager.ensure_directory_exists(dir)
    if not ok then
        vim.notify('Failed to create scripts directory: ' .. tostring(err), vim.log.levels.ERROR)
        return false
    end

    local readme = dir .. '/README.md'
    if vim.fn.filereadable(readme) ~= 1 then
        local content = table.concat({
            '# Project scripts',
            '',
            'Files in this directory show up in `:QtScripts`.',
            'A file named build, clean, run, debug, or test overrides the built-in action of the same name.',
            '',
            'Built-ins call the plugin (QtBuild, QtClean, QtRun, QtDebug, and the test runner).',
            '',
        }, '\n')
        file_manager.write_file(readme, content)
    end

    vim.notify('Scripts directory ready: ' .. dir, vim.log.levels.INFO)
    return true
end

local function run_in_terminal(argv, cwd)
    local rendered = table.concat(vim.tbl_map(vim.fn.shellescape, argv), ' ')
    vim.cmd('split')
    if cwd and cwd ~= '' then
        vim.cmd('lcd ' .. vim.fn.fnameescape(cwd))
    end
    vim.cmd('terminal ' .. rendered)
end

local function run_in_background(argv, cwd)
    local job_id = vim.fn.jobstart(argv, {
        cwd = cwd,
        on_exit = function(_, code)
            vim.schedule(function()
                if code == 0 then
                    vim.notify('Script finished', vim.log.levels.INFO)
                else
                    vim.notify('Script failed (exit ' .. tostring(code) .. ')', vim.log.levels.ERROR)
                end
            end)
        end,
    })
    if not job_id or job_id <= 0 then
        vim.notify('Failed to start script', vim.log.levels.ERROR)
        return false
    end
    return true
end

function M.test_argv(build_system, root, project_name)
    local system = require('qt-assistant.system')
    if build_system == 'cmake' then
        local ctest = system.find_executable('ctest') or 'ctest'
        return { ctest, '--test-dir', root .. '/build', '--output-on-failure' }
    elseif build_system == 'xmake' then
        local xmake = system.find_executable('xmake') or 'xmake'
        return { xmake, '-P', root, 'run', '-y', project_name .. '_tests' }
    end
    return nil
end

local function run_builtin(name, opts)
    if name == 'build' then
        require('qt-assistant.build_manager').build_project()
        return true
    elseif name == 'clean' then
        require('qt-assistant.build_manager').clean_project()
        return true
    elseif name == 'run' then
        require('qt-assistant.build_manager').run_project()
        return true
    elseif name == 'debug' then
        require('qt-assistant.debug').debug_application()
        return true
    elseif name == 'test' then
        local build_manager = require('qt-assistant.build_manager')
        local root = project_root()
        local build_system = build_manager.detect_build_system(root)
        local project_name = vim.fn.fnamemodify(root, ':t')
        local argv = M.test_argv(build_system, root, project_name)
        if not argv then
            vim.notify('No test runner for build system: ' .. tostring(build_system), vim.log.levels.WARN)
            return false
        end
        vim.notify('Running tests (' .. tostring(build_system) .. ')...', vim.log.levels.INFO)
        if opts.in_terminal then
            run_in_terminal(argv, root)
            return true
        end
        return run_in_background(argv, root)
    end
    return false
end

local function command_for_script(path)
    local system = require('qt-assistant.system')
    if path:match('%.ps1$') then
        local pwsh = system.find_executable('pwsh') or system.find_executable('powershell') or 'powershell'
        return { pwsh, '-File', path }
    elseif path:match('%.bat$') or path:match('%.cmd$') then
        return { 'cmd', '/c', path }
    elseif path:match('%.lua$') then
        return { 'nvim', '-l', path }
    end
    return { path }
end

local function find_script(name)
    for _, script in ipairs(M.get_available_scripts()) do
        if script.name == name or script.display_name == name then
            return script
        end
    end
    return nil
end

function M.run_script(name, opts)
    opts = opts or {}
    local script = find_script(name)
    if not script then
        vim.notify('Unknown script: ' .. tostring(name), vim.log.levels.ERROR)
        return false
    end
    if script.builtin then
        return run_builtin(script.name, opts)
    end
    local argv = command_for_script(script.path)
    if opts.in_terminal then
        run_in_terminal(argv, project_root())
        return true
    end
    return run_in_background(argv, project_root())
end

function M.edit_script(name)
    local script = find_script(name)
    if script and script.path then
        vim.cmd('edit ' .. vim.fn.fnameescape(script.path))
        return true
    end
    if script or builtin_by_name(name) then
        vim.notify(string.format('"%s" is a built-in action. Add scripts/%s to override it.', name, name), vim.log.levels.INFO)
        return false
    end
    vim.notify('Unknown script: ' .. tostring(name), vim.log.levels.ERROR)
    return false
end

return M
