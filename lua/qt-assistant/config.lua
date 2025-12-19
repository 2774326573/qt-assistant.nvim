-- Qt Assistant Plugin - Configuration Module
-- 配置管理模块

local M = {}

-- Global configuration storage
M._config = nil

-- Initialize configuration with validation
function M.setup(user_config)
    local default_config = {
        project_root = vim.fn.getcwd(),
        cmake_presets = {
            -- Default generator used by :QtCMakePresets when writing CMakePresets.json.
            -- Common values:
            --   - "Ninja"
            --   - "Ninja Multi-Config"
            --   - "Unix Makefiles"
            --   - "MinGW Makefiles"
            --   - "NMake Makefiles"
            --   - "Visual Studio 17 2022"
            generator = "Ninja"
        },
        export = {
            -- When enabled, :QtBuild will export build outputs into export/<project>/...
            enabled = true,
            -- Root directory name under project_root.
            dir = "export",
            -- Windows: run windeployqt for produced executables to copy required Qt DLLs/plugins.
            deploy_qt = true,
            -- Also deploy compiler runtime (MSVC/MinGW runtime) when using windeployqt.
            deploy_compiler_runtime = true,
            -- Deploy the test executable if present (CMake only).
            include_tests = true,
            -- Deploy demo executable if present.
            include_demo = true
        },
        directories = {
            source = "src",
            include = "include", 
            ui = "ui",
            resource = "resources"
        },
        auto_update_cmake = true,
        qt_tools = {
            designer_path = M._detect_qt_tool("designer"),
            uic_path = M._detect_qt_tool("uic"),
            qmake_path = M._detect_qt_tool("qmake"),
            cmake_path = M._detect_qt_tool("cmake"),
            creator_path = M._detect_qt_tool("qtcreator")
        },
        vcpkg = {
            enabled = false,
            vcpkg_root = M._detect_vcpkg_root(),
            toolchain_file = nil -- 自动从 vcpkg_root 推断
        },
        -- Third-party libraries configuration
        third_party = {
            enabled = false,
            -- Root directory for third-party libraries (relative to project root)
            root_dir = "third_party",
            -- Library configurations
            libraries = {
                -- Example:
                -- boost = {
                --     path = "third_party/boost",
                --     include_dir = "include",
                --     lib_dir = "lib",
                --     version = "1.80.0"
                -- }
            },
            -- Auto-generate CMake find_package calls
            auto_cmake = true
        },
        -- Documentation configuration
        documentation = {
            enabled = true,
            -- Documentation output directory
            output_dir = "docs",
            -- Default documentation template type
            default_template = "project_doc",
            -- Auto-generate API documentation
            auto_generate_api = false
        },
        enable_default_keymaps = true,
        keymaps = {
            -- "minimal": only the documented essentials
            -- "full": includes extra convenience keymaps (legacy)
            preset = "minimal"
        }
    }
    
    M._config = vim.tbl_deep_extend('force', default_config, user_config or {})
    
    -- Validate configuration
    M._validate_config(M._config)
    
    return M._config
end

-- Get configuration
function M.get()
    if not M._config then
        return M.setup({})
    end
    return M._config
end

-- Get configuration value
function M.get_value(key, default)
    local config = M.get()
    local keys = vim.split(key, '%.')
    local value = config
    
    for _, k in ipairs(keys) do
        if type(value) == 'table' and value[k] ~= nil then
            value = value[k]
        else
            return default
        end
    end
    
    return value
end

-- Set configuration value
function M.set_value(key, value)
    local config = M.get()
    local keys = vim.split(key, '%.')
    local current = config
    
    for i = 1, #keys - 1 do
        local k = keys[i]
        if type(current[k]) ~= 'table' then
            current[k] = {}
        end
        current = current[k]
    end
    
    current[keys[#keys]] = value
end

-- Detect vcpkg root directory
function M._detect_vcpkg_root()
    -- Check VCPKG_ROOT environment variable
    local vcpkg_root = vim.fn.getenv('VCPKG_ROOT')
    if vcpkg_root ~= vim.NIL and vcpkg_root ~= '' and vim.fn.isdirectory(vcpkg_root) == 1 then
        return vcpkg_root
    end
    
    -- Check common installation paths
    local common_paths = {
        vim.fn.expand('~/vcpkg'),
        vim.fn.expand('~/.vcpkg'),
        -- Windows
        'C:/vcpkg',
        'C:/dev/vcpkg',
        'C:/Tools/vcpkg',
        -- Linux/macOS
        '/usr/local/vcpkg',
        '/opt/vcpkg'
    }
    
    for _, path in ipairs(common_paths) do
        if vim.fn.isdirectory(path) == 1 then
            -- Verify it's a valid vcpkg installation
            local vcpkg_exe = path .. (vim.fn.has('win32') == 1 and '/vcpkg.exe' or '/vcpkg')
            if vim.fn.filereadable(vcpkg_exe) == 1 then
                return path
            end
        end
    end
    
    return nil
end

-- Get vcpkg toolchain file path
function M.get_vcpkg_toolchain_file()
    local config = M.get()
    if not config.vcpkg or not config.vcpkg.enabled then
        return nil
    end
    
    -- Use explicitly configured toolchain file if provided
    if config.vcpkg.toolchain_file and vim.fn.filereadable(config.vcpkg.toolchain_file) == 1 then
        return config.vcpkg.toolchain_file
    end
    
    -- Infer from vcpkg_root
    if config.vcpkg.vcpkg_root and vim.fn.isdirectory(config.vcpkg.vcpkg_root) == 1 then
        local toolchain = config.vcpkg.vcpkg_root .. '/scripts/buildsystems/vcpkg.cmake'
        if vim.fn.filereadable(toolchain) == 1 then
            return toolchain
        end
    end
    
    return nil
end

-- Detect Qt tool paths
function M._detect_qt_tool(tool_name)
    -- Check common installation paths
    local common_paths = {
        "/usr/bin/" .. tool_name,
        "/usr/local/bin/" .. tool_name,
        "/opt/Qt/Tools/QtCreator/bin/" .. tool_name,
        "/opt/qt/bin/" .. tool_name
    }
    
    -- First try system PATH
    if vim.fn.executable(tool_name) == 1 then
        return tool_name
    end
    
    -- Check common paths
    for _, path in ipairs(common_paths) do
        if vim.fn.executable(path) == 1 then
            return path
        end
    end
    
    -- Fall back to tool name (let system handle it)
    return tool_name
end

-- Validate configuration
function M._validate_config(config)
    if not config then
        vim.notify("Qt Assistant: Invalid configuration", vim.log.levels.ERROR)
        return false
    end
    
    -- Validate project root
    if config.project_root and not vim.fn.isdirectory(config.project_root) then
        vim.notify("Qt Assistant: Project root directory does not exist: " .. config.project_root, vim.log.levels.WARN)
    end
    
    -- Validate directories configuration
    if type(config.directories) ~= "table" then
        vim.notify("Qt Assistant: Invalid directories configuration", vim.log.levels.WARN)
        config.directories = {
            source = "src",
            include = "include",
            ui = "ui", 
            resource = "resources"
        }
    end
    
    return true
end

-- Update project root
function M.update_project_root(new_root)
    if vim.fn.isdirectory(new_root) then
        M.set_value('project_root', new_root)
        return true
    else
        vim.notify("Qt Assistant: Directory does not exist: " .. new_root, vim.log.levels.ERROR)
        return false
    end
end

return M