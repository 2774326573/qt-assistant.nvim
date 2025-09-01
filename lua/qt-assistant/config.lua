-- Qt Assistant Plugin - Configuration Module
-- 配置管理模块

local M = {}

-- Global configuration storage
M._config = nil

-- Initialize configuration with validation
function M.setup(user_config)
    local default_config = {
        project_root = vim.fn.getcwd(),
        directories = {
            source = "src",
            include = "include", 
            ui = "ui",
            resource = "resources"
        },
        auto_update_cmake = true,
        auto_rebuild_on_cmake_change = false,
        qt_tools = {
            designer_path = M._detect_qt_tool("designer"),
            uic_path = M._detect_qt_tool("uic"),
            qmake_path = M._detect_qt_tool("qmake"),
            cmake_path = M._detect_qt_tool("cmake"),
            creator_path = M._detect_qt_tool("qtcreator")
        },
        enable_default_keymaps = true
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