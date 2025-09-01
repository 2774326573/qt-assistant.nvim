-- Qt Assistant Plugin - Configuration Module
-- 配置管理模块

local M = {}

-- Global configuration storage
M._config = nil

-- Initialize configuration
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
        auto_rebuild_on_cmake_change = false,  -- 当cmakelists.txt发生变化之后应该自动构建cmake
        qt_tools = {
            designer_path = "designer",
            uic_path = "uic",
            qmake_path = "qmake",
            cmake_path = "cmake"
        },
        designer = {
            designer_path = "designer",
            creator_path = "qtcreator",
            default_editor = "designer"
        },
        enable_default_keymaps = true
    }
    
    M._config = vim.tbl_deep_extend('force', default_config, user_config or {})
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

return M