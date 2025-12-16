-- Qt Assistant Plugin - Clangd LSP integration module
-- Clangd语言服务器集成模块

local M = {}
local file_manager = require('qt-assistant.file_manager')
local system = require('qt-assistant.system')

-- Get plugin configuration
local function get_config()
    -- Set default config for current working directory
    return {
        project_root = vim.fn.getcwd(),
        directories = {
            source = "src",
            include = "include", 
            ui = "ui",
            resource = "resources"
        }
    }
end

-- Select a make-compatible tool across platforms
local function select_make_tool()
    return system.find_executable('mingw32-make')
        or system.find_executable('nmake')
        or system.find_executable('make')
end

-- Select an available compiler with platform-aware flags
local function select_compiler()
    if system.find_executable('clang++') then
        return 'clang++', 'clang'
    end

    if system.get_os() == 'windows' and system.find_executable('cl') then
        return 'cl', 'msvc'
    end

    if system.find_executable('g++') then
        return 'g++', 'gcc'
    end

    return 'clang++', 'clang'
end

-- Check if clangd is available
function M.is_clangd_available()
    return system.find_executable('clangd') ~= nil
end

-- Check if LSP client is available
function M.is_lsp_available()
    return vim.lsp ~= nil
end

-- Generate compile_commands.json for clangd
function M.generate_compile_commands()
    local project_root = get_config().project_root

    -- If compile_commands already exists somewhere under the project, link it and exit early
    if M.ensure_compile_commands_link(project_root) then
        vim.notify("ℹ️ Found existing compile_commands.json and linked to project root", vim.log.levels.INFO)
        return true
    end
    
    -- Check if this is a Qt C++ project
    local cmake_file = system.join_path(project_root, "CMakeLists.txt")
    local pro_files = M.find_pro_files(project_root)
    
    if not file_manager.file_exists(cmake_file) and #pro_files == 0 then
        vim.notify("❌ No Qt project found (missing CMakeLists.txt or .pro file)", vim.log.levels.ERROR)
        vim.notify("💡 Navigate to a Qt C++ project directory first", vim.log.levels.INFO)
        return false
    end
    
    local build_dir = system.join_path(project_root, "build")
    
    -- Ensure build directory exists
    local success, error_msg = file_manager.ensure_directory_exists(build_dir)
    if not success then
        vim.notify("❌ Failed to create build directory: " .. error_msg, vim.log.levels.ERROR)
        return false
    end
    
    -- Detect build system and generate compile commands
    if file_manager.file_exists(cmake_file) then
        return M.generate_cmake_compile_commands(project_root, build_dir)
    else
        return M.generate_qmake_compile_commands(project_root, build_dir)
    end
end

-- Generate compile commands for CMake projects
function M.generate_cmake_compile_commands(project_root, build_dir)
    local cmake_path = system.find_executable('cmake')
    if not cmake_path then
        vim.notify("❌ CMake not found. Install CMake for clangd integration.", vim.log.levels.ERROR)
        return false
    end
    
    vim.notify("🔧 Generating compile_commands.json with CMake...", vim.log.levels.INFO)
    
    -- Configure CMake with compile commands export
    local configure_cmd = {
        cmake_path,
        "-DCMAKE_BUILD_TYPE=Debug",
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
        "-S", project_root,
        "-B", build_dir
    }
    
    local job_id = vim.fn.jobstart(configure_cmd, {
        cwd = project_root,
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line and line ~= "" then
                        vim.schedule(function()
                            print("CMake: " .. line)
                        end)
                    end
                end
            end
        end,
        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line and line ~= "" then
                        vim.schedule(function()
                            vim.notify("CMake Error: " .. line, vim.log.levels.WARN)
                        end)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                -- Check if compile_commands.json was generated regardless of exit code
                local compile_commands_path = system.join_path(build_dir, "compile_commands.json")
                if file_manager.file_exists(compile_commands_path) then
                    -- Create symlink in project root for clangd
                    M.link_compile_commands(compile_commands_path, project_root)
                    vim.notify("✅ compile_commands.json generated successfully", vim.log.levels.INFO)
                else
                    if exit_code == 0 then
                        vim.notify("⚠️  CMake completed but compile_commands.json not found", vim.log.levels.WARN)
                        vim.notify("💡 Try building the project first: :QtBuild", vim.log.levels.INFO)
                    else
                        vim.notify("❌ CMake configuration failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                    end
                end
            end)
        end
    })
    
    return job_id > 0
end

-- Generate compile commands for qmake projects
function M.generate_qmake_compile_commands(project_root, build_dir)
    local qmake_path = system.find_qt_tool('qmake')
    if not qmake_path then
        vim.notify("❌ qmake not found", vim.log.levels.ERROR)
        return false
    end
    
    vim.notify("🔧 Generating compile commands for qmake project...", vim.log.levels.INFO)
    
    -- Find .pro file
    local pro_files = M.find_pro_files(project_root)
    if #pro_files == 0 then
        vim.notify("❌ No .pro file found", vim.log.levels.ERROR)
        return false
    end
    
    -- Generate Makefile first
    local qmake_cmd = {qmake_path, pro_files[1]}
    
    vim.fn.jobstart(qmake_cmd, {
        cwd = build_dir,
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                vim.schedule(function()
                    -- Generate compile commands from Makefile using bear or alternative
                    M.generate_compile_commands_from_makefile(build_dir, project_root)
                end)
            else
                vim.schedule(function()
                    vim.notify("❌ qmake failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
                end)
            end
        end
    })
    
    return true
end

-- Generate compile commands from Makefile using bear or manual parsing
function M.generate_compile_commands_from_makefile(build_dir, project_root)
    local make_tool = select_make_tool()

    if not make_tool then
        vim.notify("⚠️  No make tool found (mingw32-make/nmake/make). Falling back to manual compile_commands generation.", vim.log.levels.WARN)
        return M.generate_manual_compile_commands(build_dir, project_root)
    end

    if system.find_executable('bear') and not make_tool:lower():find('nmake') then
        return M.generate_with_bear(build_dir, project_root, make_tool)
    end

    if make_tool:lower():find('nmake') then
        vim.notify("ℹ️  nmake detected; bear is skipped. Generating compile_commands manually.", vim.log.levels.INFO)
    end

    -- Try bear first (most accurate)
    return M.generate_manual_compile_commands(build_dir, project_root)
end

-- Generate using bear
function M.generate_with_bear(build_dir, project_root, make_tool)
    local bear_cmd = {'bear', '--', make_tool, '-n'}
    
    vim.fn.jobstart(bear_cmd, {
        cwd = build_dir,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code == 0 then
                    local compile_commands_path = system.join_path(build_dir, "compile_commands.json")
                    if file_manager.file_exists(compile_commands_path) then
                        M.link_compile_commands(compile_commands_path, project_root)
                        vim.notify("✅ compile_commands.json generated with bear", vim.log.levels.INFO)
                    end
                else
                    vim.notify("⚠️  Bear failed, using manual generation", vim.log.levels.WARN)
                    M.generate_manual_compile_commands(build_dir, project_root)
                end
            end)
        end
    })
end

-- Manual compile commands generation for qmake projects
function M.generate_manual_compile_commands(build_dir, project_root)
    local qt_version = M.detect_qt_version()
    local qt_includes = M.get_qt_include_paths(qt_version)
    local source_files = M.find_source_files(project_root)
    
    local compile_commands = {}
    
    for _, source_file in ipairs(source_files) do
        local compile_entry = {
            directory = build_dir,
            command = M.build_compile_command(source_file, qt_includes, project_root),
            file = source_file
        }
        table.insert(compile_commands, compile_entry)
    end
    
    -- Write compile_commands.json
    local compile_commands_path = system.join_path(build_dir, "compile_commands.json")
    local json_content = vim.fn.json_encode(compile_commands)
    
    if file_manager.write_file(compile_commands_path, json_content) then
        M.link_compile_commands(compile_commands_path, project_root)
        vim.notify("✅ Manual compile_commands.json generated", vim.log.levels.INFO)
        return true
    else
        vim.notify("❌ Failed to write compile_commands.json", vim.log.levels.ERROR)
        return false
    end
end

-- Find .pro files
function M.find_pro_files(project_root)
    local pro_files = {}
    local handle = vim.loop.fs_scandir(project_root)
    if handle then
        while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then break end
            if type == "file" and name:match("%.pro$") then
                table.insert(pro_files, system.join_path(project_root, name))
            end
        end
    end
    return pro_files
end

-- Detect Qt version for include paths
function M.detect_qt_version()
    local qmake_path = system.find_qt_tool('qmake')
    if qmake_path then
        local output = {}
        vim.fn.jobstart({qmake_path, '-query', 'QT_VERSION'}, {
            stdout_buffered = true,
            on_stdout = function(_, data)
                if data and data[1] then
                    output = data
                end
            end
        })
        
        if #output > 0 and output[1] then
            if output[1]:match('^6%.') then
                return "6"
            elseif output[1]:match('^5%.') then  
                return "5"
            end
        end
    end
    
    return "6" -- Default to Qt6
end

-- Get Qt include paths
function M.get_qt_include_paths(qt_version)
    local includes = {}
    local qmake_path = system.find_qt_tool('qmake')
    
    if qmake_path then
        -- Get Qt installation prefix
        local output = {}
        vim.fn.jobstart({qmake_path, '-query', 'QT_INSTALL_HEADERS'}, {
            stdout_buffered = true,
            on_stdout = function(_, data)
                if data and data[1] then
                    output = data
                end
            end
        })
        
        if #output > 0 and output[1] then
            local qt_headers = output[1]:gsub('\n', '')
            table.insert(includes, qt_headers)
            
            -- Add common Qt module includes
            local qt_modules = {'QtCore', 'QtWidgets', 'QtGui', 'QtNetwork', 'QtSql'}
            for _, module in ipairs(qt_modules) do
                table.insert(includes, system.join_path(qt_headers, module))
            end
        end
    end
    
    -- Fallback common paths
    local os_type = system.get_os()
    if os_type == 'linux' then
        table.insert(includes, '/usr/include/qt' .. qt_version)
        table.insert(includes, '/usr/include/x86_64-linux-gnu/qt' .. qt_version)
    elseif os_type == 'macos' then
        table.insert(includes, '/opt/homebrew/include/qt' .. qt_version)
        table.insert(includes, '/usr/local/include/qt' .. qt_version)
    else
        -- Windows fallbacks (MinGW/MSVC). Prefer QTDIR if set.
        local qtdir = os.getenv('QTDIR')
        if qtdir and #qtdir > 0 then
            table.insert(includes, system.join_path(qtdir, 'include'))
        end
        table.insert(includes, 'C:/Qt/6.6.0/mingw_64/include')
        table.insert(includes, 'C:/Qt/6.6.0/msvc2022_64/include')
        table.insert(includes, 'C:/Qt/5.15.2/mingw81_64/include')
    end
    
    return includes
end

-- Find source files in project
function M.find_source_files(project_root)
    local source_files = {}
    local extensions = {'.cpp', '.cc', '.cxx', '.c'}
    
    local function scan_directory(dir)
        local handle = vim.loop.fs_scandir(dir)
        if not handle then return end
        
        while true do
            local name, type = vim.loop.fs_scandir_next(handle)
            if not name then break end
            
            local full_path = system.join_path(dir, name)
            
            if type == "file" then
                for _, ext in ipairs(extensions) do
                    if name:match(ext .. "$") then
                        table.insert(source_files, full_path)
                        break
                    end
                end
            elseif type == "directory" and not name:match("^%.") and name ~= "build" then
                scan_directory(full_path)
            end
        end
    end
    
    scan_directory(project_root)
    return source_files
end

-- Build compile command for a source file
function M.build_compile_command(source_file, qt_includes, project_root)
    local compiler, kind = select_compiler()
    local cmd_parts = {compiler}
    local os_type = system.get_os()

    if kind == 'msvc' then
        table.insert(cmd_parts, '/nologo')
        table.insert(cmd_parts, '/std:c++17')
        table.insert(cmd_parts, '/EHsc')
        table.insert(cmd_parts, '/Zc:__cplusplus')
        table.insert(cmd_parts, '/DWIN32')
        table.insert(cmd_parts, '/D_WINDOWS')
    else
        table.insert(cmd_parts, '-std=c++17')
        table.insert(cmd_parts, '-Wall')
        table.insert(cmd_parts, '-Wextra')
        if os_type ~= 'windows' then
            table.insert(cmd_parts, '-fPIC')
        end
    end
    
    local include_flag = kind == 'msvc' and '/I' or '-I'

    -- Add Qt includes
    for _, include_path in ipairs(qt_includes) do
        table.insert(cmd_parts, include_flag .. include_path)
    end
    
    -- Add project includes
    local project_includes = {
        system.join_path(project_root, "include"),
        system.join_path(project_root, "src"),
        project_root
    }
    
    for _, include_path in ipairs(project_includes) do
        if file_manager.directory_exists(include_path) then
            table.insert(cmd_parts, include_flag .. include_path)
        end
    end
    
    -- Add Qt defines
    local qt_version = M.detect_qt_version()
    local def_flag = kind == 'msvc' and '/D' or '-D'
    if qt_version == "6" then
        table.insert(cmd_parts, def_flag .. 'QT_CORE_LIB')
        table.insert(cmd_parts, def_flag .. 'QT_WIDGETS_LIB')
        table.insert(cmd_parts, def_flag .. 'QT_GUI_LIB')
    else
        table.insert(cmd_parts, def_flag .. 'QT_CORE_LIB')
        table.insert(cmd_parts, def_flag .. 'QT_WIDGETS_LIB')
        table.insert(cmd_parts, def_flag .. 'QT_GUI_LIB')
    end
    
    -- Add source file
    if kind == 'msvc' then
        table.insert(cmd_parts, '/c')
        table.insert(cmd_parts, source_file)
    else
        table.insert(cmd_parts, '-c')
        table.insert(cmd_parts, source_file)
    end
    
    return table.concat(cmd_parts, " ")
end

-- Create symlink for compile_commands.json in project root
function M.link_compile_commands(source_path, project_root)
    local target_path = system.join_path(project_root, "compile_commands.json")
    
    -- Remove existing symlink/file
    if file_manager.file_exists(target_path) then
        os.remove(target_path)
    end
    
    local os_type = system.get_os()
    if os_type == 'windows' then
        -- Windows: try symbolic link (requires dev mode or admin); fall back to copy if it fails
        local cmd = { 'cmd', '/c', string.format('mklink "%s" "%s"', target_path, source_path) }
        vim.fn.jobstart(cmd, {
            on_exit = function(_, exit_code)
                vim.schedule(function()
                    if exit_code == 0 then
                        return -- silently succeed
                    end
                    -- fallback to copy to keep clangd usable
                    local content = file_manager.read_file(source_path)
                    if content then
                        file_manager.write_file(target_path, content)
                    end
                end)
            end
        })
    else
        -- Unix: create symlink
        local cmd = {'ln', '-sf', source_path, target_path}
        vim.fn.jobstart(cmd, {
            on_exit = function(_, exit_code)
                vim.schedule(function()
                    if exit_code == 0 then
                        vim.notify("🔗 compile_commands.json linked to project root", vim.log.levels.INFO)
                    end
                end)
            end
        })
    end
end

-- Setup clangd configuration
function M.setup_clangd_config()
    local project_root = get_config().project_root
    local clangd_config_path = system.join_path(project_root, ".clangd")
    
    local qt_version = M.detect_qt_version()
    local qt_includes = M.get_qt_include_paths(qt_version)
    
    -- Generate .clangd configuration
    local clangd_config = {
        "# Qt Assistant generated clangd configuration",
        "CompileFlags:",
        "  Add:",
        "    - -std=c++17",
        "    - -Wall",
        "    - -Wextra",
        "    - -DQT_CORE_LIB",
        "    - -DQT_WIDGETS_LIB", 
        "    - -DQT_GUI_LIB",
    }
    
    -- Add Qt include paths
    for _, include_path in ipairs(qt_includes) do
        if file_manager.directory_exists(include_path) then
            table.insert(clangd_config, "    - -I" .. include_path)
        end
    end
    
    -- Add project include paths
    local project_includes = {"include", "src", "."}
    for _, rel_path in ipairs(project_includes) do
        local full_path = system.join_path(project_root, rel_path)
        if file_manager.directory_exists(full_path) then
            table.insert(clangd_config, "    - -I" .. full_path)
        end
    end
    
    -- Add clangd-specific settings
    table.insert(clangd_config, "")
    table.insert(clangd_config, "Index:")
    table.insert(clangd_config, "  Background: Build")
    table.insert(clangd_config, "")
    table.insert(clangd_config, "Diagnostics:")
    table.insert(clangd_config, "  UnusedIncludes: Strict")
    table.insert(clangd_config, "  MissingIncludes: Strict")
    table.insert(clangd_config, "")
    table.insert(clangd_config, "Completion:")
    table.insert(clangd_config, "  AllScopes: true")
    table.insert(clangd_config, "")
    table.insert(clangd_config, "InlayHints:")
    table.insert(clangd_config, "  Enabled: true")
    table.insert(clangd_config, "  ParameterNames: true")
    table.insert(clangd_config, "  DeducedTypes: true")
    
    -- Write configuration
    local config_content = table.concat(clangd_config, "\n")
    if file_manager.write_file(clangd_config_path, config_content) then
        vim.notify("📝 .clangd configuration created", vim.log.levels.INFO)
        return true
    else
        vim.notify("❌ Failed to create .clangd configuration", vim.log.levels.ERROR)
        return false
    end
end

-- Setup LSP client for Qt projects
function M.setup_qt_lsp()
    if not M.is_lsp_available() then
        vim.notify("❌ LSP not available in this Neovim version", vim.log.levels.ERROR)
        return false
    end
    
    if not M.is_clangd_available() then
        vim.notify("❌ clangd not found. Install clangd for language server support.", vim.log.levels.ERROR)
        M.show_clangd_install_help()
        return false
    end
    
    -- Setup clangd with Qt-specific configuration
    local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
    if lspconfig_ok then
        lspconfig.clangd.setup({
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
            capabilities = M.get_lsp_capabilities(),
            on_attach = M.on_lsp_attach,
        })
        
        vim.notify("🔧 Clangd LSP configured for Qt development", vim.log.levels.INFO)
        return true
    else
        vim.notify("💡 Install nvim-lspconfig for better LSP integration", vim.log.levels.INFO)
        return false
    end
end

-- Get LSP capabilities (with cmp integration if available)
function M.get_lsp_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    
    -- Add cmp capabilities if available
    local cmp_ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    if cmp_ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
    end
    
    return capabilities
end

-- LSP attach callback with Qt-specific keymaps
function M.on_lsp_attach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Buffer-local keymaps
    local map = function(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
    end
    
    -- Essential LSP keymaps for Qt development
    map('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
    map('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
    map('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
    map('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
    map('n', 'K', vim.lsp.buf.hover, { desc = 'Show hover info' })
    map('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature help' })
    map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
    map('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
    map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, { desc = 'Format code' })
    
    -- Qt-specific keymaps
    map('n', '<leader>qls', function() M.restart_lsp() end, { desc = 'Restart Qt LSP' })
    map('n', '<leader>qlr', function() M.reload_compile_commands() end, { desc = 'Reload compile commands' })
    
    vim.notify("🔧 LSP attached with Qt-specific keymaps", vim.log.levels.INFO)
end

-- Restart LSP client
function M.restart_lsp()
    vim.cmd('LspRestart clangd')
    vim.notify("🔄 Clangd LSP restarted", vim.log.levels.INFO)
end

-- Reload compile commands
function M.reload_compile_commands()
    M.generate_compile_commands()
    vim.defer_fn(function()
        M.restart_lsp()
    end, 1000)
end

-- Complete clangd setup for Qt projects
function M.setup_complete_qt_lsp()
    if not M.is_clangd_available() then
        vim.notify("❌ clangd not found. Install clangd first.", vim.log.levels.ERROR)
        M.show_clangd_install_help()
        return false
    end
    
    vim.notify("🚀 Setting up complete Qt + clangd integration...", vim.log.levels.INFO)
    
    -- Step 1: Ensure compile_commands exists or generate it
    vim.schedule(function()
        local compile_success = M.ensure_compile_commands_link(get_config().project_root) or M.generate_compile_commands()
        if compile_success then
            -- Step 2: Setup clangd configuration
            vim.defer_fn(function()
                M.setup_clangd_config()
                
                -- Step 3: Setup LSP
                vim.defer_fn(function()
                    M.setup_qt_lsp()
                    vim.notify("✅ Qt + clangd integration complete!", vim.log.levels.INFO)
                end, 500)
            end, 1000)
        end
    end)
    
    return true
end

-- Show clangd installation help
function M.show_clangd_install_help()
    local os_type = system.get_os()
    local help_lines = {
        "=== Install clangd ===",
        "",
    }
    
    if os_type == 'linux' then
        vim.list_extend(help_lines, {
            "Ubuntu/Debian:",
            "  sudo apt install clangd",
            "",
            "Arch Linux:",
            "  sudo pacman -S clang",
            "",
            "CentOS/RHEL:",
            "  sudo yum install clang-tools-extra",
        })
    elseif os_type == 'macos' then
        vim.list_extend(help_lines, {
            "macOS:",
            "  brew install llvm",
            "  # Add to PATH:",
            "  echo 'export PATH=\"/opt/homebrew/opt/llvm/bin:$PATH\"' >> ~/.zshrc",
            "",
            "Or install Xcode:",
            "  xcode-select --install",
        })
    else
        vim.list_extend(help_lines, {
            "Windows:",
            "  Download LLVM from: https://llvm.org/builds/",
            "  Or install via package manager:",
            "  winget install LLVM.LLVM",
        })
    end
    
    vim.list_extend(help_lines, {
        "",
        "After installation, restart Neovim and run:",
        "  :QtLspSetup",
    })
    
    -- Display help in floating window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
    
    local width = 60
    local height = math.min(#help_lines + 2, 20)
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
        title = " Clangd Installation Help ",
        title_pos = "center"
    })
    
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
end

-- Show LSP status
function M.show_lsp_status()
    local project_root = get_config().project_root
    
    -- Check if this is a Qt project
    local cmake_file = system.join_path(project_root, "CMakeLists.txt")
    local pro_files = M.find_pro_files(project_root)
    local is_qt_project = file_manager.file_exists(cmake_file) or #pro_files > 0
    
    local status = {
        clangd_available = M.is_clangd_available(),
        lsp_available = M.is_lsp_available(),
        is_qt_project = is_qt_project,
        compile_commands_exists = file_manager.file_exists(system.join_path(project_root, "compile_commands.json")),
        clangd_config_exists = file_manager.file_exists(system.join_path(project_root, ".clangd")),
        lsp_clients_active = #vim.lsp.get_active_clients() > 0
    }
    
    local status_lines = {
        "=== Qt Clangd LSP Status ===",
        "",
        "🔧 Tool Status:",
        "  clangd: " .. (status.clangd_available and "✅ Available" or "❌ Not installed"),
        "  LSP: " .. (status.lsp_available and "✅ Available" or "❌ Not available"),
        "",
        "🎯 Project Type:",
        "  Qt Project: " .. (status.is_qt_project and "✅ Detected" or "❌ Not a Qt project"),
        "  Build System: " .. (file_manager.file_exists(cmake_file) and "CMake" or (#pro_files > 0 and "qmake" or "None")),
        "",
        "📁 Project Configuration:",
        "  compile_commands.json: " .. (status.compile_commands_exists and "✅ Found" or "❌ Missing"),
        "  .clangd config: " .. (status.clangd_config_exists and "✅ Found" or "❌ Missing"),
        "",
        "🔌 LSP Client Status:",
        "  Active clients: " .. (status.lsp_clients_active and "✅ " .. #vim.lsp.get_active_clients() or "❌ None"),
    }
    
    -- Add appropriate help messages
    if not status.is_qt_project then
        table.insert(status_lines, "")
        table.insert(status_lines, "💡 Navigate to a Qt C++ project directory")
        table.insert(status_lines, "   (directory with CMakeLists.txt or .pro file)")
    elseif not status.clangd_available then
        table.insert(status_lines, "")
        table.insert(status_lines, "💡 Install clangd: sudo apt install clangd")
    elseif not status.compile_commands_exists then
        table.insert(status_lines, "")
        table.insert(status_lines, "💡 Run :QtLspGenerate to create compile commands")
    else
        table.insert(status_lines, "")
        table.insert(status_lines, "✅ Qt LSP fully configured!")
    end
    
    -- Display in floating window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, status_lines)
    
    local width = 50
    local height = math.min(#status_lines + 2, 15)
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
        title = " Qt LSP Status ",
        title_pos = "center"
    })
    
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
end

-- Auto-setup LSP when entering Qt project
function M.auto_setup_lsp()
    local project_root = get_config().project_root
    local compile_commands_path = system.join_path(project_root, "compile_commands.json")
    
    -- If compile_commands.json exists elsewhere (e.g., build dir), link it; otherwise generate
    if not file_manager.file_exists(compile_commands_path) then
        if M.ensure_compile_commands_link(project_root) then
            return
        end
        if M.is_clangd_available() then
            vim.notify("🔧 Auto-generating compile commands for clangd...", vim.log.levels.INFO)
            M.generate_compile_commands()
        end
    end
end

-- Initialize LSP integration
function M.init()
    -- Auto-setup on Qt project detection
    vim.schedule(function()
        local project_root = get_config().project_root
        local has_cmake = file_manager.file_exists(system.join_path(project_root, "CMakeLists.txt"))
        local has_qmake = #M.find_pro_files(project_root) > 0
        
        if (has_cmake or has_qmake) and M.is_clangd_available() then
            M.auto_setup_lsp()
        end
    end)
end

-- Locate an existing compile_commands.json within the project
function M.find_compile_commands(project_root)
    project_root = project_root or get_config().project_root
    local candidates = {
        system.join_path(project_root, "compile_commands.json"),
        system.join_path(project_root, "build", "compile_commands.json")
    }

    for _, path in ipairs(candidates) do
        if file_manager.file_exists(path) then
            return path
        end
    end

    local build_dir = system.join_path(project_root, "build")
    local matches = {}
    if vim.fn.isdirectory(build_dir) == 1 then
        matches = vim.fs.find("compile_commands.json", {
            path = build_dir,
            limit = 5,
            type = "file",
        }) or {}
    end

    if #matches == 0 then
        -- Fallback: search the whole project (limited results) when build dir name differs
        matches = vim.fs.find("compile_commands.json", {
            path = project_root,
            limit = 5,
            type = "file",
        }) or {}
    end

    if #matches > 0 then
        return system.normalize_path(matches[1])
    end

    return nil
end

-- Ensure compile_commands.json is linked/copied into project root if found elsewhere
function M.ensure_compile_commands_link(project_root)
    project_root = project_root or get_config().project_root
    local source_path = M.find_compile_commands(project_root)
    local target_path = system.join_path(project_root, "compile_commands.json")

    if not source_path then
        return false
    end

    local normalized_source = system.normalize_path(source_path)
    local normalized_target = system.normalize_path(target_path)

    -- If already in place, nothing to do
    if normalized_source == normalized_target and file_manager.file_exists(target_path) then
        return true
    end

    M.link_compile_commands(source_path, project_root)
    return true
end

return M