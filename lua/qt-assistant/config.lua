-- Qt Assistant Plugin - 简化配置管理模块
-- Simple configuration management module

local M = {}

-- 全局配置存储
M._config = nil

-- 初始化配置
function M.setup(user_config)
    -- 默认配置（延迟创建）
    local default_config = {
        project_root = vim.fn.getcwd(),
        directories = {
            source = "src",
            include = "include", 
            ui = "ui",
            resource = "resource",
            scripts = "scripts"
        },
        naming_convention = "snake_case",
        auto_update_cmake = true,
        generate_comments = true,
        template_path = vim.fn.stdpath('config') .. '/qt-templates',
        qt_project = {
            auto_detect = true,
            build_type = "Debug",
            build_dir = "build",
            parallel_build = true,
            build_jobs = 4
        },
        designer = {
            designer_path = "designer",
            creator_path = "qtcreator",
            default_editor = "designer",
            custom_editor = { command = "", args = {"--file", "{file}"} },
            auto_sync = true,
            enable_preview = true
        },
        debug = {
            enabled = false,
            log_level = "INFO",
            log_file = vim.fn.stdpath('data') .. '/qt-assistant.log'
        },
        enable_default_keymaps = true,
        file_handling = {
            auto_create_backup = false,
            disable_write_confirm = true,  -- 禁用写入确认对话框
            preserve_file_permissions = true
        }
    }
    
    M._config = vim.tbl_deep_extend('force', default_config, user_config or {})
    return M._config
end

-- 获取配置
function M.get()
    if not M._config then
        return M.setup({})
    end
    return M._config
end

-- 获取配置项
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

-- 设置配置项
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

-- 检查配置是否已初始化
function M.is_initialized()
    return M._config ~= nil
end

return M