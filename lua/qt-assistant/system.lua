-- Qt Assistant Plugin - System utilities module
-- 系统工具模块

local M = {}

-- Detect operating system
function M.get_os()
    if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
        return 'windows'
    elseif vim.fn.has('macunix') == 1 then
        return 'macos'
    else
        return 'linux'
    end
end

-- Join file paths (cross-platform)
function M.join_path(...)
    local parts = {...}
    local separator = M.get_os() == 'windows' and '\\' or '/'
    return table.concat(parts, separator)
end

-- Normalize path separators to the current OS
function M.normalize_path(path)
    if not path or path == '' then
        return path
    end
    local sep = M.get_os() == 'windows' and '\\' or '/'
    -- Replace both / and \ with the OS separator, collapse duplicates
    local normalized = path:gsub('[\\/]+', sep)
    -- On Windows, keep drive letter upper-case for consistency
    if M.get_os() == 'windows' then
        normalized = normalized:gsub('^([a-z]):', function(drive)
            return drive:upper() .. ':'
        end)
    end
    return normalized
end

-- Find executable in PATH
function M.find_executable(name)
    if M.get_os() == 'windows' and not name:match('%.exe$') then
        name = name .. '.exe'
    end
    
    local result = vim.fn.exepath(name)
    return result ~= "" and result or nil
end

-- Find Qt tool (designer, uic, qmake, etc.)
function M.find_qt_tool(tool_name)
    -- If caller passed an explicit path, honor it
    if tool_name and (tostring(tool_name):find('[/\\]') ~= nil) and vim.fn.executable(tool_name) == 1 then
        return tool_name
    end

    -- First try direct executable search (returns a full path when available)
    local exe_path = M.find_executable(tool_name)
    if exe_path then
        return exe_path
    end
    
    -- Try common Qt installation paths
    local qt_paths = M.get_common_qt_paths()
    
    for _, qt_path in ipairs(qt_paths) do
        local tool_path = M.join_path(qt_path, 'bin', tool_name)
        if M.get_os() == 'windows' and not tool_path:match('%.exe$') then
            tool_path = tool_path .. '.exe'
        end
        
        if vim.fn.executable(tool_path) == 1 then
            return tool_path
        end
    end

    -- Finally, try vcpkg-installed tools (Qt installed via vcpkg)
    local vcpkg_tool = M.find_vcpkg_tool(tool_name)
    if vcpkg_tool then
        return vcpkg_tool
    end
    
    return nil
end

local function scandir_dirs(path)
    local dirs = {}
    local handle = vim.loop.fs_scandir(path)
    if not handle then
        return dirs
    end

    while true do
        local name, t = vim.loop.fs_scandir_next(handle)
        if not name then break end
        if t == 'directory' then
            table.insert(dirs, name)
        end
    end

    return dirs
end

local function get_vcpkg_candidate_roots()
    local roots = {}

    local env = vim.fn.getenv('VCPKG_ROOT')
    if env ~= vim.NIL and env ~= '' then
        table.insert(roots, env)
    end

    -- Also honor plugin configuration (useful when Neovim doesn't inherit env vars)
    local ok_cfg, cfg_mod = pcall(require, 'qt-assistant.config')
    if ok_cfg and cfg_mod then
        local cfg = cfg_mod.get()
        if cfg and cfg.vcpkg and cfg.vcpkg.vcpkg_root and cfg.vcpkg.vcpkg_root ~= '' then
            table.insert(roots, cfg.vcpkg.vcpkg_root)
        end
    end

    table.insert(roots, vim.fn.expand('~/vcpkg'))
    table.insert(roots, vim.fn.expand('~/.vcpkg'))

    if M.get_os() == 'windows' then
        table.insert(roots, 'C:/vcpkg')
        table.insert(roots, 'C:/dev/vcpkg')
        table.insert(roots, 'C:/Tools/vcpkg')
    else
        table.insert(roots, '/usr/local/vcpkg')
        table.insert(roots, '/opt/vcpkg')
    end

    -- Deduplicate + filter existing dirs
    local seen = {}
    local out = {}
    for _, r in ipairs(roots) do
        if r and r ~= '' then
            local norm = r:gsub('\\', '/')
            if not seen[norm] and vim.fn.isdirectory(r) == 1 then
                seen[norm] = true
                table.insert(out, r)
            end
        end
    end
    return out
end

-- Try to find a tool installed by vcpkg under installed/<triplet>/tools/*
function M.find_vcpkg_tool(tool_name)
    local exe = tool_name
    if M.get_os() == 'windows' and not exe:match('%.exe$') then
        exe = exe .. '.exe'
    end

    for _, root in ipairs(get_vcpkg_candidate_roots()) do
        local installed_dir = root:gsub('\\', '/') .. '/installed'
        if vim.fn.isdirectory(installed_dir) == 1 then
            local triplets = scandir_dirs(installed_dir)
            for _, triplet in ipairs(triplets) do
                -- Skip internal/metadata directories commonly present
                if triplet ~= 'vcpkg' and triplet ~= 'packages' then
                    local tools_dir = installed_dir .. '/' .. triplet .. '/tools'
                    if vim.fn.isdirectory(tools_dir) == 1 then
                        -- Fast paths for common Qt ports
                        local common_ports = {
                            'qt6', 'qt5', 'qtbase', 'qt',
                            'qt6-base', 'qt5-base',
                            'qt6-tools', 'qt5-tools'
                        }

                        for _, port in ipairs(common_ports) do
                            local p1 = tools_dir .. '/' .. port .. '/bin/' .. exe
                            if vim.fn.executable(p1) == 1 then
                                return p1
                            end
                            local p2 = tools_dir .. '/' .. port .. '/' .. exe
                            if vim.fn.executable(p2) == 1 then
                                return p2
                            end
                        end

                        -- Generic scan one level: tools/<port>/(bin/)?<exe>
                        for _, portdir in ipairs(scandir_dirs(tools_dir)) do
                            local p1 = tools_dir .. '/' .. portdir .. '/bin/' .. exe
                            if vim.fn.executable(p1) == 1 then
                                return p1
                            end
                            local p2 = tools_dir .. '/' .. portdir .. '/' .. exe
                            if vim.fn.executable(p2) == 1 then
                                return p2
                            end
                        end
                    end
                end
            end
        end
    end

    return nil
end

-- Get common Qt installation paths (enhanced cross-platform)
function M.get_common_qt_paths()
    local os_type = M.get_os()
    local paths = {}
    
    if os_type == 'windows' then
        -- Windows Qt paths
        local drives = {'C:', 'D:', 'E:'}
        local versions = {'6.6.0', '6.5.2', '6.4.2', '5.15.2'}
        local compilers = {'mingw_64', 'msvc2022_64', 'msvc2019_64'}
        
        for _, drive in ipairs(drives) do
            for _, version in ipairs(versions) do
                for _, compiler in ipairs(compilers) do
                    table.insert(paths, drive .. '\\Qt\\' .. version .. '\\' .. compiler)
                end
            end
        end
    elseif os_type == 'macos' then
        -- macOS Qt paths (Homebrew, official installer, manual)
        local homebrew_paths = {
            '/opt/homebrew/Cellar/qt@6',  -- Apple Silicon Homebrew
            '/opt/homebrew/Cellar/qt@5',
            '/usr/local/Cellar/qt@6',     -- Intel Homebrew  
            '/usr/local/Cellar/qt@5',
            '/opt/homebrew/opt/qt@6',
            '/opt/homebrew/opt/qt@5',
            '/usr/local/opt/qt@6',
            '/usr/local/opt/qt@5'
        }
        
        -- Check Homebrew installations
        for _, path in ipairs(homebrew_paths) do
            if vim.fn.isdirectory(path) == 1 then
                -- Find actual version subdirectories
                local handle = vim.loop.fs_scandir(path)
                if handle then
                    while true do
                        local name, type = vim.loop.fs_scandir_next(handle)
                        if not name then break end
                        if type == "directory" and name:match("^%d+%.%d+") then
                            table.insert(paths, path .. '/' .. name)
                        end
                    end
                end
            end
        end
        
        -- Official Qt installer paths
        table.insert(paths, vim.fn.expand('~/Qt/6.6.0/macos'))
        table.insert(paths, vim.fn.expand('~/Qt/6.5.2/macos'))
        table.insert(paths, vim.fn.expand('~/Qt/5.15.2/clang_64'))
        table.insert(paths, '/usr/local/Qt')
        table.insert(paths, '/opt/Qt')
    else
        -- Linux Qt paths (package manager and manual installations)
        local linux_paths = {
            -- System package manager paths
            '/usr/lib/x86_64-linux-gnu/qt6',  -- Ubuntu/Debian Qt6
            '/usr/lib/x86_64-linux-gnu/qt5',  -- Ubuntu/Debian Qt5
            '/usr/lib64/qt6',                 -- CentOS/RHEL Qt6
            '/usr/lib64/qt5',                 -- CentOS/RHEL Qt5
            '/usr/lib/qt6',                   -- Generic Qt6
            '/usr/lib/qt5',                   -- Generic Qt5
            '/usr/share/qt6',                 -- Alternative Qt6
            '/usr/share/qt5',                 -- Alternative Qt5
            
            -- Manual installation paths
            '/opt/Qt/6.6.0/gcc_64',
            '/opt/Qt/6.5.2/gcc_64', 
            '/opt/Qt/5.15.2/gcc_64',
            '/usr/local/Qt6',
            '/usr/local/Qt5',
            '/usr/local/qt6',
            '/usr/local/qt5',
            
            -- User installation
            vim.fn.expand('~/Qt/6.6.0/gcc_64'),
            vim.fn.expand('~/Qt/6.5.2/gcc_64'),
            vim.fn.expand('~/Qt/5.15.2/gcc_64'),
            vim.fn.expand('~/Qt'),
            
            -- Snap packages
            '/snap/qt-creator-community/current/Qt',
            '/var/lib/snapd/snap/qt-creator-community/current/Qt'
        }
        
        for _, path in ipairs(linux_paths) do
            table.insert(paths, path)
        end
    end
    
    return paths
end

-- Check if command exists
function M.command_exists(command)
    return M.find_executable(command) ~= nil
end

-- Get system information
function M.get_system_info()
    local info = {
        os = M.get_os(),
        qt_designer = M.find_qt_tool('designer') and 'Available' or 'Not found',
        uic = M.find_qt_tool('uic') and 'Available' or 'Not found',
        cmake = M.find_executable('cmake') and 'Available' or 'Not found',
        qmake = M.find_qt_tool('qmake') and 'Available' or 'Not found'
    }
    
    return info
end

return M