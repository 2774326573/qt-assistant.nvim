-- Qt Assistant Plugin - Template management module
-- 模板管理模块
--
-- 模板数据已拆分到仓库根目录 templates/*.tmpl (纯文本, {{VAR}} 占位符,
-- {{#VAR}}...{{/VAR}} 与 {{^VAR}}...{{/VAR}} 条件块)。
--
-- 宿主自定义接口 (解析顺序, 高→低):
--   1. M.register_template(name, content)  运行时注册 (本会话内最高)
--   2. config.templates.override           单模板文件路径覆盖 { [name] = '路径' }
--   3. config.templates.custom_dir         宿主模板目录, 其内 <name>.tmpl 覆盖内置
--   4. 内置 templates/ 目录
--
-- 相关命令: :QtTemplatesReload  :QtTemplatesOpenCustomDir

local M = {}

local here = debug.getinfo(1, 'S').source:sub(2):gsub('[/\\][^/\\]+$', '')
-- 此文件位于 lua/qt-assistant/core/ → 仓库根 templates/ 需向上 3 级
local BUILTIN_DIR = here .. '/../../../templates'

-- Template configurations
local template_configs = {
    main_window = {
        has_header = true,
        has_source = true,
        has_ui = true,
        base_class = "QMainWindow"
    },
    dialog = {
        has_header = true,
        has_source = true,
        has_ui = true,
        base_class = "QDialog"
    },
    widget = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QWidget"
    },
    model = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QAbstractItemModel"
    },
    delegate = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QStyledItemDelegate"
    },
    thread = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QThread"
    },
    utility = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QObject"
    },
    singleton = {
        has_header = true,
        has_source = true,
        has_ui = false,
        base_class = "QObject"
    }
}

-- Built-in templates (从 templates/ 目录加载)
local builtin_templates = {}

-- 宿主运行时注册 (register_template), 优先级最高
local runtime_templates = {}

local function read_file(path)
    if type(path) ~= 'string' or vim.fn.filereadable(path) ~= 1 then
        return nil
    end
    local lines = vim.fn.readfile(path)
    -- readfile 按行返回; 还原为带换行的原始文本 (尾部补一个 \n 与原内嵌字符串形态一致)
    return table.concat(lines, '\n') .. '\n'
end

--- 从磁盘加载内置模板 (templates/*.tmpl)
function M.load_builtin_templates()
    builtin_templates = {}
    if vim.fn.isdirectory(BUILTIN_DIR) ~= 1 then
        vim.notify('Qt助手: 内置模板目录缺失: ' .. BUILTIN_DIR, vim.log.levels.WARN)
        return
    end
    for name, typ in vim.fs.dir(BUILTIN_DIR) do
        if typ == 'file' and name:match('%.tmpl$') then
            local content = read_file(BUILTIN_DIR .. '/' .. name)
            if content then
                builtin_templates[name:sub(1, -6)] = content
            end
        end
    end
end

-- Initialize templates
function M.init()
    M.load_builtin_templates()
end

--- 宿主运行时注册/覆盖模板 (本会话内最高优先级)
---@param name string 模板名 (如 main_window_header)
---@param content string 模板内容 (占位符同内置)
function M.register_template(name, content)
    if type(name) ~= 'string' or type(content) ~= 'string' or content == '' then
        return false, 'register_template: 需要模板名与非空内容'
    end
    runtime_templates[name] = content
    return true
end

--- 解析链: runtime → override 文件 → custom_dir → builtin
---@param name string
---@return string|nil content
local function resolve(name)
    local runtime = runtime_templates[name]
    if runtime then
        return runtime
    end

    local tc = nil
    local cfgok, cfgp = pcall(require, 'qt-assistant.core.config')
    if cfgok then
        tc = cfgp.get().templates
    end

    if tc then
        local override = tc.override and tc.override[name]
        if override then
            local content = read_file(override)
            if content then
                return content
            end
        end
        if type(tc.custom_dir) == 'string' and tc.custom_dir ~= '' then
            local content = read_file(tc.custom_dir .. '/' .. name .. '.tmpl')
            if content then
                return content
            end
        end
    end

    return builtin_templates[name]
end

-- Get template configuration
function M.get_template_config(class_type)
    return template_configs[class_type]
end

-- Render template with conditional blocks
function M.render_template(template_name, variables)
    local template = resolve(template_name)
    if not template then
        return nil, "Template not found: " .. template_name
    end

    local rendered = template
    variables = variables or {}

    -- Process conditional blocks {{#VAR}}...{{/VAR}}
    rendered = rendered:gsub("{{#([^}]+)}}(.-){{/[^}]+}}", function(var_name, content)
        if variables[var_name] then
            return content
        else
            return ""
        end
    end)

    -- Process negative conditional blocks {{^VAR}}...{{/VAR}}
    rendered = rendered:gsub("{{%^([^}]+)}}(.-){{/[^}]+}}", function(var_name, content)
        if not variables[var_name] then
            return content
        else
            return ""
        end
    end)

    -- Process regular variable substitutions
    for key, value in pairs(variables) do
        local pattern = "{{" .. key .. "}}"
        rendered = rendered:gsub(pattern, tostring(value))
    end

    return rendered
end

-- Render template string with variables (simple version)
function M.render_template_string(template_string, variables)
    if not template_string or not variables then
        return template_string
    end

    local rendered = template_string

    -- Process regular variable substitutions
    for key, value in pairs(variables) do
        local pattern = "{{" .. key .. "}}"
        rendered = rendered:gsub(pattern, tostring(value))
    end

    return rendered
end

-- Initialize on module load
M.load_builtin_templates()

return M
