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
    -- First try direct executable search
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