-- Qt Assistant Plugin - 配置管理模块
-- Configuration management module

local M = {}

-- 全局配置存储
M._config = nil

-- 获取默认配置的函数（延迟评估）
local function get_default_config()
    return {
        -- 项目根目录
        project_root = vim.fn.getcwd(),
    
    -- 默认目录结构
    directories = {
        source = "src",
        include = "include", 
        ui = "ui",
        resource = "resource",
        scripts = "scripts"
    },
    
    -- 文件命名规范 snake_case 或 camelCase
    naming_convention = "snake_case",
    
    -- 自动更新CMakeLists.txt
    auto_update_cmake = true,
    
    -- 生成注释
    generate_comments = true,
    
    -- 模板路径
    template_path = vim.fn.stdpath('config') .. '/qt-templates',
    
    -- Qt项目配置
    qt_project = {
        -- 自动检测项目类型
        auto_detect = true,
        
        -- 构建配置
        build_type = "Debug", -- Debug, Release, RelWithDebInfo, MinSizeRel
        
        -- 构建目录
        build_dir = "build",
        
        -- 并行构建
        parallel_build = true,
        
        -- 构建线程数
        build_jobs = 4
    },
    
    -- UI设计师配置
    designer = {
        -- Qt Designer路径
        designer_path = "designer",
        
        -- Qt Creator路径
        creator_path = "qtcreator",
        
        -- 默认UI编辑器
        default_editor = "designer", -- designer, creator, custom
        
        -- 自定义UI编辑器
        custom_editor = {
            command = "",
            args = {"--file", "{file}"}
        },
        
        -- 自动同步UI文件
        auto_sync = true,
        
        -- UI文件预览
        enable_preview = true
    },
    
    -- 调试配置
    debug = {
        -- 启用调试模式
        enabled = false,
        
        -- 调试日志级别
        log_level = "INFO", -- DEBUG, INFO, WARN, ERROR
        
        -- 调试输出文件
        log_file = vim.fn.stdpath('data') .. '/qt-assistant.log'
    },
    
        -- 快捷键配置
        enable_default_keymaps = false
    }
end

-- 初始化配置
function M.setup(user_config)
    local default_config = get_default_config()
    M._config = vim.tbl_deep_extend('force', default_config, user_config or {})
    return M._config
end

-- 获取配置
function M.get()
    if not M._config then
        -- 如果配置还未初始化，使用默认配置
        local default_config = get_default_config()
        M._config = vim.deepcopy(default_config)
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