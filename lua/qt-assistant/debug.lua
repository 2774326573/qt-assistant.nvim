-- Qt Assistant - Debug integration
-- Uses nvim-dap when it is installed. Supported DAP adapters:
--   gdb (GDB 14+ --interpreter=dap), lldb-dap / lldb-vscode, codelldb,
--   and cppvsdbg (OpenDebugAD7) on Windows.
-- cdb is detected. It is not a DAP server; when it is the only Windows
-- debugger, :QtDebug launches it in a terminal. If nvim-dap itself is
-- missing, commands stop with an explicit error.

local M = {}

M._registered = false
M._adapter = nil

local ADAPTER_ORDER = {
    linux = { 'gdb', 'codelldb', 'lldb' },
    macos = { 'codelldb', 'lldb', 'gdb' },
    windows = { 'codelldb', 'cppvsdbg', 'lldb', 'gdb' },
}

local ADAPTER_BINARIES = {
    gdb = { 'gdb' },
    lldb = { 'lldb-dap', 'lldb-vscode' },
    codelldb = { 'codelldb' },
    cppvsdbg = { 'OpenDebugAD7', 'OpenDebugAD7.exe' },
    cdb = { 'cdb' },
}

function M.adapter_preference(os_type)
    return ADAPTER_ORDER[os_type] or ADAPTER_ORDER.linux
end

--- Pure toolchain selection. finder(name) -> absolute path or nil.
function M.inspect_toolchain(os_type, finder)
    os_type = os_type or 'linux'
    finder = finder or function()
        return nil
    end

    local found = {}
    local function locate(adapter_id)
        local names = ADAPTER_BINARIES[adapter_id] or { adapter_id }
        for _, name in ipairs(names) do
            local path = finder(name)
            if path and path ~= '' then
                return path, name
            end
        end
        return nil, nil
    end

    for _, id in ipairs({ 'gdb', 'lldb', 'codelldb', 'cppvsdbg', 'cdb' }) do
        local path, bin = locate(id)
        if path then
            found[id] = { path = path, binary = bin }
        end
    end

    local selected, selected_path
    for _, id in ipairs(M.adapter_preference(os_type)) do
        if found[id] then
            selected = id
            selected_path = found[id].path
            break
        end
    end

    return {
        os = os_type,
        found = found,
        selected = selected,
        selected_path = selected_path,
        cdb = found.cdb and found.cdb.path or nil,
        dap_capable = selected ~= nil,
    }
end

local function extra_candidate_paths(name)
    local paths = {}
    local data = vim.fn.stdpath('data')
    local function add(p)
        if p and p ~= '' then
            table.insert(paths, p)
        end
    end

    add(data .. '/mason/bin/' .. name)
    add(vim.fn.expand('~/.local/share/nvim/mason/bin/') .. name)

    if name == 'codelldb' then
        add(data .. '/mason/packages/codelldb/extension/adapter/codelldb')
        add(data .. '/mason/packages/codelldb/extension/adapter/codelldb.exe')
    elseif name == 'OpenDebugAD7' or name == 'OpenDebugAD7.exe' then
        local root = data .. '/mason/packages/cpptools/extension/debugAdapters/bin'
        add(root .. '/OpenDebugAD7')
        add(root .. '/OpenDebugAD7.exe')
    elseif name == 'cdb' then
        local globs = vim.fn.glob('C:/Program Files*/Windows Kits/10/Debuggers/**/cdb.exe', false, true)
        if type(globs) == 'table' then
            for _, p in ipairs(globs) do
                add(p)
            end
        end
    end

    return paths
end

function M.make_finder()
    local system = require('qt-assistant.system')
    return function(name)
        local direct = system.find_executable(name)
        if direct then
            return direct
        end
        for _, path in ipairs(extra_candidate_paths(name)) do
            if vim.fn.executable(path) == 1 or vim.fn.filereadable(path) == 1 then
                return path
            end
        end
        return nil
    end
end

function M.toolchain()
    local system = require('qt-assistant.system')
    return M.inspect_toolchain(system.get_os(), M.make_finder())
end

function M.dap_status()
    local ok, dap_or_err = pcall(require, 'dap')
    if not ok then
        return false, nil, 'nvim-dap is not installed. Add mfussenegger/nvim-dap, then run :QtDebugSetup again.'
    end
    return true, dap_or_err, nil
end

local function project_root()
    return require('qt-assistant.config').get().project_root
end

function M.resolve_program(build_type)
    local build_manager = require('qt-assistant.build_manager')
    return build_manager.find_project_executable(build_type or 'Debug')
end

local function upsert_config(dap, filetype, config)
    local list = dap.configurations[filetype] or {}
    dap.configurations[filetype] = list
    for i, existing in ipairs(list) do
        if existing.name == config.name then
            list[i] = config
            return
        end
    end
    table.insert(list, config)
end

function M.launch_config(adapter_id, program)
    local config = {
        name = 'Qt: Launch',
        type = adapter_id,
        request = 'launch',
        program = program,
        cwd = project_root(),
        stopOnEntry = false,
        args = {},
    }
    if adapter_id == 'gdb' then
        config.setupCommands = {
            {
                text = '-enable-pretty-printing',
                description = 'Enable GDB pretty printing',
                ignoreFailures = true,
            },
        }
    end
    return config
end

function M.attach_config(adapter_id, pid, program)
    local config = {
        name = 'Qt: Attach',
        type = adapter_id,
        request = 'attach',
        pid = pid,
        processId = pid,
        cwd = project_root(),
    }
    if program then
        config.program = program
    end
    if adapter_id == 'gdb' then
        config.setupCommands = {
            {
                text = '-enable-pretty-printing',
                description = 'Enable GDB pretty printing',
                ignoreFailures = true,
            },
        }
    end
    return config
end

function M.register_adapter(dap, adapter_id, path)
    if adapter_id == 'codelldb' then
        dap.adapters.codelldb = {
            type = 'server',
            port = '${port}',
            executable = {
                command = path,
                args = { '--port', '${port}' },
            },
        }
    elseif adapter_id == 'gdb' then
        dap.adapters.gdb = {
            type = 'executable',
            command = path,
            args = { '--interpreter=dap', '--eval-command', 'set print pretty on' },
        }
    elseif adapter_id == 'lldb' then
        dap.adapters.lldb = {
            type = 'executable',
            command = path,
            name = 'lldb',
        }
    elseif adapter_id == 'cppvsdbg' then
        dap.adapters.cppvsdbg = {
            id = 'cppvsdbg',
            type = 'executable',
            command = path,
            options = { detached = false },
        }
    end
end

function M.register_configurations(dap, adapter_id)
    local launch = M.launch_config(adapter_id, function()
        return M.resolve_program('Debug')
    end)
    launch.cwd = function()
        return project_root()
    end
    local attach = M.attach_config(adapter_id, function()
        return vim.fn.input('Process ID: ')
    end)
    for _, ft in ipairs({ 'c', 'cpp' }) do
        upsert_config(dap, ft, launch)
        upsert_config(dap, ft, attach)
    end
end

local function set_if_absent(mode, lhs, rhs, opts)
    local existing = vim.fn.maparg(lhs, mode, false, true)
    if type(existing) == 'table' and existing.lhs and existing.lhs ~= '' then
        return false
    end
    vim.keymap.set(mode, lhs, rhs, opts)
    return true
end

function M.install_keymaps()
    local ok, dap = M.dap_status()
    if not ok then
        return false
    end
    local opts = { silent = true }
    set_if_absent('n', '<F5>', function() dap.continue() end, vim.tbl_extend('force', opts, { desc = 'Debug continue/start' }))
    set_if_absent('n', '<F10>', function() dap.step_over() end, vim.tbl_extend('force', opts, { desc = 'Debug step over' }))
    set_if_absent('n', '<F11>', function() dap.step_into() end, vim.tbl_extend('force', opts, { desc = 'Debug step into' }))
    set_if_absent('n', '<F12>', function() dap.step_out() end, vim.tbl_extend('force', opts, { desc = 'Debug step out' }))
    set_if_absent('n', '<leader>db', function() dap.toggle_breakpoint() end, vim.tbl_extend('force', opts, { desc = 'Toggle breakpoint' }))
    return true
end

function M._register(dap, report)
    if not report.selected then
        return false
    end
    M.register_adapter(dap, report.selected, report.selected_path)
    M.register_configurations(dap, report.selected)
    M._registered = true
    M._adapter = report.selected
    return true
end

function M.init()
    local ok, dap = M.dap_status()
    if not ok then
        return false
    end
    local report = M.toolchain()
    if not report.selected then
        return false
    end
    local reg_ok, err = pcall(M._register, dap, report)
    if not reg_ok then
        vim.notify('Qt debug init failed: ' .. tostring(err), vim.log.levels.WARN)
        return false
    end
    local cfg = require('qt-assistant.config').get()
    if cfg.debug and cfg.debug.keymaps then
        M.install_keymaps()
    end
    return true
end

local function report_lines(report, dap_ok, dap_err)
    local lines = {
        'Qt debug status',
        'nvim-dap: ' .. (dap_ok and 'available' or 'missing'),
    }
    if not dap_ok and dap_err then
        table.insert(lines, dap_err)
    end
    table.insert(lines, 'OS: ' .. tostring(report.os))
    table.insert(lines, 'Selected adapter: ' .. (report.selected or 'none'))
    if report.selected_path then
        table.insert(lines, 'Adapter path: ' .. report.selected_path)
    end
    for _, id in ipairs({ 'gdb', 'lldb', 'codelldb', 'cppvsdbg', 'cdb' }) do
        local info = report.found[id]
        table.insert(lines, string.format('  %s: %s', id, info and info.path or 'not found'))
    end
    if report.os == 'windows' and report.cdb and not report.found.cppvsdbg then
        table.insert(lines, 'cdb is a console debugger. nvim-dap needs CodeLLDB or OpenDebugAD7 to drive a session.')
        table.insert(lines, 'When no DAP adapter is installed, :QtDebug launches cdb in a terminal.')
    end
    if report.found.gdb then
        table.insert(lines, 'GDB is used through its DAP interpreter (GDB 14+).')
    end
    local build_manager = require('qt-assistant.build_manager')
    table.insert(lines, 'Build system: ' .. (build_manager.detect_build_system() or 'none'))
    local exe = M.resolve_program('Debug')
    table.insert(lines, 'Debug executable: ' .. (exe or 'not built yet'))
    return lines
end

function M.show_debug_status()
    local dap_ok, _, dap_err = M.dap_status()
    local report = M.toolchain()
    local lines = report_lines(report, dap_ok, dap_err)
    require('qt-assistant.ui').show_info_window(lines)
    return lines
end

function M.setup_debugging()
    local dap_ok, dap, dap_err = M.dap_status()
    local report = M.toolchain()
    local lines = report_lines(report, dap_ok, dap_err)
    if dap_ok and report.selected then
        local reg_ok, err = pcall(M._register, dap, report)
        if not reg_ok then
            table.insert(lines, 'Failed to register adapter: ' .. tostring(err))
        else
            table.insert(lines, 'Registered nvim-dap adapter "' .. report.selected .. '" and Qt launch/attach configurations.')
            M.install_keymaps()
            table.insert(lines, 'Installed F5/F10/F11/F12 and <leader>db where those keys were free.')
        end
    elseif not dap_ok then
        table.insert(lines, 'Debugging commands will not start a session until nvim-dap is installed.')
    else
        table.insert(lines, 'No DAP debugger found. Install gdb (14+), lldb-dap, or codelldb.')
        if report.cdb then
            table.insert(lines, 'cdb was found and will be used as a terminal fallback by :QtDebug.')
        end
    end
    require('qt-assistant.ui').show_info_window(lines)
    return dap_ok and report.selected ~= nil
end

local function launch_cdb(program, pid)
    local report = M.toolchain()
    if not report.cdb then
        return false
    end
    local cmd
    if pid then
        cmd = { report.cdb, '-p', tostring(pid) }
    else
        cmd = { report.cdb, program }
    end
    local rendered = table.concat(vim.tbl_map(vim.fn.shellescape, cmd), ' ')
    vim.notify('Starting cdb in a terminal. nvim-dap has no native cdb adapter.', vim.log.levels.WARN)
    vim.cmd('split')
    vim.cmd('terminal ' .. rendered)
    return true
end

local function start_session(request, pid)
    local dap_ok, dap, dap_err = M.dap_status()
    if not dap_ok then
        vim.notify(dap_err, vim.log.levels.ERROR)
        return false
    end

    local report = M.toolchain()
    if not report.selected then
        if report.cdb and request == 'launch' then
            local program = M.resolve_program('Debug')
            if not program then
                vim.notify('No executable found for cdb. Build the project first (:QtBuild).', vim.log.levels.ERROR)
                return false
            end
            return launch_cdb(program, nil)
        elseif report.cdb and request == 'attach' and pid then
            return launch_cdb(nil, pid)
        end
        vim.notify('No debugger found. Install gdb, lldb-dap, or codelldb and run :QtDebugSetup.', vim.log.levels.ERROR)
        return false
    end

    M._register(dap, report)

    if request == 'attach' then
        dap.run(M.attach_config(report.selected, pid, M.resolve_program('Debug')))
        return true
    end

    local program = M.resolve_program('Debug')
    if not program then
        vim.notify('Debug executable not found. Building the Debug configuration, then starting the debugger.', vim.log.levels.INFO)
        local build_manager = require('qt-assistant.build_manager')
        build_manager.build_project('Debug', {
            on_success = function()
                local built = M.resolve_program('Debug')
                if not built then
                    vim.notify('Build finished but no executable was found.', vim.log.levels.ERROR)
                    return
                end
                local again = M.toolchain()
                if not again.selected then
                    vim.notify('No DAP debugger available after the build.', vim.log.levels.ERROR)
                    return
                end
                dap.run(M.launch_config(again.selected, built))
            end,
        })
        return true
    end

    dap.run(M.launch_config(report.selected, program))
    return true
end

function M.debug_application()
    return start_session('launch')
end

function M.attach_to_process()
    local dap_ok, _, dap_err = M.dap_status()
    if not dap_ok then
        vim.notify(dap_err, vim.log.levels.ERROR)
        return false
    end
    vim.ui.input({ prompt = 'Qt process ID to attach: ' }, function(input)
        if input == nil or input == '' then
            return
        end
        local pid = tonumber(input)
        if not pid then
            vim.notify('Invalid process ID: ' .. tostring(input), vim.log.levels.ERROR)
            return
        end
        start_session('attach', pid)
    end)
    return true
end

return M
