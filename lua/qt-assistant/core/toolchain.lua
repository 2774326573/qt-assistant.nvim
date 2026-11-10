-- Qt Assistant - Qt 工具链管理 (core)
-- toolchain.lua: 探测本机 Qt 工具链 + 广播 + 宿主选择/持久化。
-- 由主模块 (app 层) 在 setup 时懒加载接线; 不依赖 ui 之外的业务模块。

local M = {}

----------------------------------------------------------------------
--探测
----------------------------------------------------------------------

-- 工具链核心工具 (qmake/uic 必具其1)
local CORE_TOOLS = { 'qmake', 'uic' }
-- 可选工具 (designer 缺失时降级可用)
local OPTIONAL_TOOLS = { 'designer', 'moc', 'rcc', 'windeployqt' }

-- 默认探测根目录 (会被 config.qt_discovery.roots 覆盖)
local DEFAULT_ROOTS = {
    'C:/Qt', 'D:/Qt', 'E:/Qt', 'E:/Dev/Qt', 'C:/Program Files/Qt',
    'C:/install', 'D:/install', 'E:/install',
}
local WALK_DEPTH = 5

M.CORE_TOOLS = CORE_TOOLS
M.OPTIONAL_TOOLS = OPTIONAL_TOOLS

local function exec_name(tool)
    return (vim.fn.has('win32') == 1 and tool .. '.exe') or tool
end

local function has_tool(dir, tool)
    return vim.fn.executable(dir .. '/' .. tool) == 1
end

local function is_kit_bin(dir)
    for _, t in ipairs(CORE_TOOLS) do
        if has_tool(dir, t) then
            return true
        end
    end
    return false
end

--- 在 base 下按限定深度 BFS 找形态为 `bin` 目录 (含 qmake/uic) 的 Qt kit
local function find_kit_bins(dir, depth, cb)
    if depth <= 0 or not vim.fn.isdirectory(dir) then
        return
    end
    for name, typ in vim.fs.dir(dir) do
        if typ == 'directory' then
            local path = dir .. '/' .. name
            if is_kit_bin(path) then
                cb(path)
            else
                find_kit_bins(path, depth - 1, cb)
            end
        end
    end
end

--- 收集某个 bin 目录里可用的工具表
local function tool_map(bin)
    local tools = {}
    for _, t in ipairs(CORE_TOOLS) do
        tools[t] = has_tool(bin, t)
    end
    for _, t in ipairs(OPTIONAL_TOOLS) do
        tools[t] = has_tool(bin, t)
    end
    return tools
end

--- 探测本机 Qt 工具链
---@param roots? string[] 覆盖探测根目录 (默认来自配置 qt_discovery.roots)
---@return table[] { { bin, kit, label, tools } }
function M.discover(roots)
    if not roots then
        local ok, cfgp = pcall(require, 'qt-assistant.core.config')
        if ok then
            local cfgw = cfgp.get()
            local d = cfgw and cfgw.qt_discovery or nil
            if d and d.roots then
                roots = d.roots
            end
        end
    end
    roots = roots or DEFAULT_ROOTS

    local found, seen = {}, {}
    for _, base in ipairs(roots) do
        base = vim.fs.normalize(base)
        find_kit_bins(base, WALK_DEPTH, function(bin)
            if seen[bin] then
                return
            end
            seen[bin] = true
            local kit_name = vim.fs.basename(bin)
            found[#found + 1] = {
                bin = bin,
                kit = kit_name,
                label = kit_name .. '  @  ' .. bin,
                tools = tool_map(bin),
            }
        end)
    end
    table.sort(found, function(a, b)
        return a.bin < b.bin
    end)
    return found
end

--- 当前配置里不可用 (路径无效/不可执行) 的工具名列表
---@return string[]
function M.missing_tools()
    local cfg = require('qt-assistant.core.config').get()
    local missing = {}
    for _, t in ipairs(CORE_TOOLS) do
        local p = cfg.qt_tools and cfg.qt_tools[t .. '_path']
        if type(p) ~= 'string' or vim.fn.executable(p) ~= 1 then
            missing[#missing + 1] = t
        end
    end
    return missing
end

----------------------------------------------------------------------
--宿主选择
----------------------------------------------------------------------

local STORE_DIRNAME = 'qt-assistant'
local STORE_FILENAME = 'selected_kit.json'

local function storage_dir()
    return vim.fn.stdpath('data') .. '/' .. STORE_DIRNAME
end

local function storage_file()
    return storage_dir() .. '/' .. STORE_FILENAME
end

---@return table|nil { bin, kit }
local function load_selection()
    local f = storage_file()
    local ok, content = pcall(function()
        return table.concat(vim.fn.readfile(f), '\n')
    end)
    if not ok then
        return nil
    end
    local ok2, data = pcall(vim.json.decode, content)
    if ok2 and type(data) == 'table' and data.bin and vim.fn.isdirectory(data.bin) == 1 then
        return data
    end
    return nil
end

---@param kit table
local function save_selection(kit)
    local dir = storage_dir()
    if vim.fn.isdirectory(dir) == 0 then
        local ok = pcall(vim.fn.mkdir, dir, 'p')
        if not ok then
            return
        end
    end
    local data = {
        bin = kit.bin,
        kit = kit.kit,
        saved_at = os.date('%Y-%m-%d %H:%M:%S'),
    }
    local f = io.open(storage_file(), 'w')
    if f then
        f:write(vim.json.encode(data))
        f:close()
    end
end

--- 把某个 kit 应用到当前配置 (qt_tools.*)
---@param kit table
function M.apply(kit)
    if not kit or not kit.bin then
        return
    end
    local cfg = require('qt-assistant.core.config')
    for _, t in ipairs(CORE_TOOLS) do
        if has_tool(kit.bin, t) then
            cfg.set_value('qt_tools.' .. t .. '_path', kit.bin .. '/' .. exec_name(t))
        end
    end
    for _, t in ipairs(OPTIONAL_TOOLS) do
        if has_tool(kit.bin, t) then
            cfg.set_value('qt_tools.' .. t .. '_path', kit.bin .. '/' .. exec_name(t))
        end
    end
end

--- 从当前配置反推生效中的 Qt 工具链 (以 qmake_path 所在目录为准)
---@param kits? table[] 可选; 传入探测列表则直接匹配其中的项
---@return table|nil kit
function M.active_kit(kits)
    local cfg = require('qt-assistant.core.config').get()
    local qm = cfg.qt_tools and cfg.qt_tools.qmake_path
    if type(qm) ~= 'string' or vim.fn.executable(qm) ~= 1 then
        return nil
    end
    local bin = vim.fs.dirname(vim.fs.normalize(qm))
    if not kits then
        kits = M.discover()
    end
    for _, k in ipairs(kits) do
        if vim.fs.normalize(k.bin) == bin then
            return k
        end
    end
    -- 配置路径不在探测列表里 (例如 vcpkg/自定义环境) 也给出标识
    return { bin = bin, kit = vim.fs.basename(bin), label = vim.fs.basename(bin) .. '  @  ' .. bin }
end

--- 选择器 (vim.ui.select, LazyVim 下由 snacks 界面接管)
function M.select_kit()
    local kits = M.discover()
    if vim.tbl_isempty(kits) then
        vim.notify('Qt助手: 没有探测到任何 Qt 工具链 (检查 qt_discovery.roots)', vim.log.levels.WARN)
        return
    end
    local lines = {}
    for i, k in ipairs(kits) do
        lines[#lines + 1] = (' %d) %s'):format(i, k.label)
    end
    vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
    vim.ui.select(kits, {
        prompt = 'Qt助手: 选择本机 Qt 工具链 (宿主选择, 自动持久化)',
        format_item = function(k)
            return k.label
        end,
    }, function(kit)
        if kit then
            M.apply(kit)
            save_selection(kit)
            vim.notify('Qt助手: 已选用 ' .. kit.label .. '\n(此后每次启动自动沿用, 项目可随时用 :QtSelectKit 换)', vim.log.levels.INFO)
        end
    end)
end

----------------------------------------------------------------------
--广播与接线
----------------------------------------------------------------------

local function format_kit_list(kits)
    local lines = {}
    for i, k in ipairs(kits) do
        lines[#lines + 1] = (' %d) %s'):format(i, k.label)
    end
    return table.concat(lines, '\n')
end

local function broadcast_notify(kits)
    local missing = M.missing_tools()
    local state = (#missing == 0) and '当前配置的工具链完好'
        or ('当前缺失: ' .. table.concat(missing, ', '))
    local active = M.active_kit(kits)
    local active_txt = active and ('当前生效: ' .. active.label)
        or '当前生效: 未匹配任何探测到的工具链'
    vim.notify(('Qt助手 自动广播: 发现 %d 个 Qt 工具链 (%s)。\n%s\n用 :QtSelectKit 选择, :QtKitList 列详情。')
        :format(#kits, state, active_txt), vim.log.levels.INFO)
end

M._setup_done = false

--- setup: 由主模块调用 (懒加载), 完成命令注册 + 自动广播 + 沿用上次选择
function M.setup()
    -- 防重入: setup 可能被调用多次 (lazy 配置 + 手动 setup), 只生效第一次
    if M._setup_done then
        return
    end
    M._setup_done = true

    local ok, cfg = pcall(require('qt-assistant.core.config').get)
    if not ok then
        M._setup_done = false -- 失败可重试
        return
    end

    local discovery_cfg = cfg.qt_discovery or {}
    if discovery_cfg.enabled == false then
        return
    end

    -- 沿用宿主上次的选择 (仅当当前配置确实缺少可用工具时才覆盖)
    if #M.missing_tools() > 0 then
        local saved = load_selection()
        if saved then
            M.apply({ bin = saved.bin, kit = saved.kit })
            vim.notify('Qt助手: 已自动沿用上次选择的 Qt 工具链 ' .. (saved.kit or '') .. ' (' .. saved.bin .. ')', vim.log.levels.INFO)
        end
    end

    -- 注册命令
    vim.api.nvim_create_user_command('QtSelectKit', function()
        M.select_kit()
    end, { desc = 'Qt助手: 选择本机 Qt 工具链' })
    vim.api.nvim_create_user_command('QtKitList', function()
        local kits = M.discover(discovery_cfg.roots)
        if vim.tbl_isempty(kits) then
            vim.notify('Qt助手: 没有探测到任何 Qt 工具链', vim.log.levels.WARN)
            return
        end
        vim.notify('Qt助手 探测到的 Qt 工具链:\n' .. format_kit_list(kits), vim.log.levels.INFO)
    end, { desc = 'Qt助手: 列出探测到的 Qt 工具链' })

    -- 自动广播 (仅通知, 不打断; 可用 :QtSelectKit 交互选择)
    if discovery_cfg.auto_broadcast ~= false then
        vim.schedule(function()
            local kits = M.discover(discovery_cfg.roots)
            broadcast_notify(kits)
        end)
    end
end

return M
