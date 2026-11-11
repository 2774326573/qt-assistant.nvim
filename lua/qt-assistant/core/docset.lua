-- Qt Assistant Plugin - Offline Docset Module
-- 离线文档: 查询 Dash/Zeal 格式 docset (SQLite 索引) 并在 nvim 内渲染 HTML 页面
-- 依赖 scripts/docset.py (Python 标准库实现, 无第三方依赖)

local M = {}

-- Resolved paths (cached)
M._python = nil
M._docset = nil
M._script = nil

local function script_path()
    if M._script then
        return M._script
    end
    -- lua/qt-assistant/core/docset.lua -> scripts/docset.py (plugin root)
    local here = debug.getinfo(1, "S").source:sub(2)
    local root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(here))))
    M._script = vim.fs.normalize(root .. "/scripts/docset.py")
    return M._script
end

local function find_python(cfg)
    if M._python then
        return M._python
    end
    -- 同样注意: nil 优先项会让 ipairs 提前终止, 故用 table.insert 构建
    local candidates = {}
    if cfg.python and cfg.python ~= "" then
        table.insert(candidates, cfg.python)
    end
    table.insert(candidates, vim.fn.exepath("python3"))
    table.insert(candidates, vim.fn.exepath("python"))
    table.insert(candidates, "python")
    for _, c in ipairs(candidates) do
        if c and c ~= "" then
            if vim.fn.executable(c) == 1 then
                M._python = vim.fs.normalize(vim.fn.fnamemodify(c, ":p"))
                return M._python
            end
        end
    end
    M._python = "python" -- 最后兜底, 由报错提示用户配置
    return M._python
end

local function find_docset(cfg)
    if M._docset then
        return M._docset
    end
    -- 显式配置的路径拥有最高优先级: 有效则使用, 无效则不回退到其他候选
    -- (否则 bootstrap 无法感知"配置了但缺失"的状态, 导致不下载)
    if cfg.docset_path and cfg.docset_path ~= "" then
        local p = vim.fs.normalize(cfg.docset_path)
        if vim.fn.isdirectory(p) == 1 and vim.fn.filereadable(p .. "/Contents/Resources/docSet.dsidx") == 1 then
            M._docset = p
            return M._docset
        end
        return nil
    end
    -- 未配置: 依次探测默认/常见位置
    local candidates = {
        -- bootstrap 默认安装位置 (任何机器通用)
        vim.fs.normalize(vim.fn.stdpath("data") .. "/qt-docsets/Qt.docset"),
        vim.fs.normalize(vim.fn.stdpath("data") .. "/site/docsets/Qt.docset"),
    }
    for _, c in ipairs(candidates) do
        local p = vim.fs.normalize(c)
        if vim.fn.isdirectory(p) == 1 and vim.fn.filereadable(p .. "/Contents/Resources/docSet.dsidx") == 1 then
            M._docset = p
            return M._docset
        end
    end
    return nil
end

-- ==================== Bootstrap: 首次使用自动装齐 ====================

M._bootstrap_started = false

local function notify_done(ok, msg)
    vim.notify("Qt助手: " .. msg, ok and vim.log.levels.INFO or vim.log.levels.WARN)
end

---下载 docset 并解压到 docset_path (若尚不存在)
---@param cb fun(ok: boolean)
function M.install_docset(cb)
    local cfg = require("qt-assistant.core.config").get()
    local docs = cfg.docs or {}
    if find_docset(docs) then
        cb(true)
        return
    end
    local target = vim.fs.normalize(docs.docset_path
        or (vim.fn.stdpath("data") .. "/qt-docsets/Qt.docset"))
    local parent = vim.fs.dirname(target)
    local archive = parent .. "/Qt.tgz"
    if vim.fn.filereadable(archive) == 1 and vim.fn.filereadable(target .. "/Contents/Resources/docSet.dsidx") ~= 1 then
        -- 已有完整下载包但未解压: 直接复用, 不重新下载
        M._extract_docset(archive, parent, target, docs, cb)
        return
    end
    if vim.fn.executable("curl") ~= 1 then
        notify_done(false, "未找到 curl, 无法自动下载文档集; 请手动下载 " .. tostring(docs.docset_url))
        cb(false)
        return
    end
    vim.fn.mkdir(parent, "p")
    vim.notify("Qt助手: 正在下载 Qt 离线文档集 (~190MB, 一次性) ...", vim.log.levels.INFO)
    vim.system({ "curl", "-fL", "--retry", "3", "--retry-delay", "2", "-o", archive, docs.docset_url },
        { text = true }, function(res)
            vim.schedule(function()
                if res.code ~= 0 or vim.fn.getfsize(archive) < 100 then
                    notify_done(false, "文档集下载失败 (网络?): " .. tostring(res.stderr))
                    os.remove(archive)
                    cb(false)
                    return
                end
                M._extract_docset(archive, parent, target, docs, cb)
            end)
        end)
end

local function extract_docset_sync(archive, parent)
    if vim.fn.executable("tar") ~= 1 then
        return false, "未找到 tar, 无法解压文档集"
    end
    local out = vim.fn.system({ "tar", "-xzf", archive, "-C", parent })
    if vim.v.shell_error ~= 0 then
        return false, "解压失败: " .. tostring(out)
    end
    return true, nil
end

M._extract_docset = function(archive, parent, target, docs, cb)
    vim.notify("Qt助手: 正在解压文档集 ...", vim.log.levels.INFO)
    vim.defer_fn(function()
        local ok, err = extract_docset_sync(archive, parent)
        if not ok then
            notify_done(false, err)
            cb(false)
            return
        end
        if not vim.fn.filereadable(target .. "/Contents/Resources/docSet.dsidx") then
            notify_done(false, "文档集内容校验失败 (docSet.dsidx 缺失)")
            cb(false)
            return
        end
        if not docs.keep_archive then
            pcall(os.remove, archive)
        end
        notify_done(true, "Qt 离线文档集就绪 -> " .. target .. "  :QtDocs 可用")
        cb(true)
    end, 10)
end

---确保 outline.nvim 可加载: 已安装 -> 跳过; lazy 目录已有 -> 追加 rtp; 否则预克隆
---@param cb fun(ok: boolean)
function M.ensure_outline(cb)
    local DBG = os.getenv("QT_ASSISTANT_DEBUG") == "1"
    local logf = nil
    if DBG then
        logf = io.open(os.getenv("TEMP") .. "/qta_dbg.log", "a")
        logf:write("== ensure_outline ==\n")
    end
    local dbg = function(s)
        if logf then logf:write(s .. "\n"); logf:flush() end
    end
    dbg("start")
    if pcall(require, "outline") then
        dbg("outline loadable already")
        if logf then logf:close() end
        cb(true)
        return
    end
    local cfg = require("qt-assistant.core.config").get()
    local docs = cfg.docs or {}
    -- 注意: 不能用 { 可能nil的值, ... } + ipairs —— Lua 的 ipairs 在首个 nil 处终止
    local candidates = {}
    if docs.outline_dir and docs.outline_dir ~= "" then
        table.insert(candidates, docs.outline_dir)
    end
    local clone_dir = vim.fs.normalize(vim.fn.stdpath("data") .. "/lazy/outline.nvim")
    table.insert(candidates, clone_dir)
    local found = nil
    for _, c in ipairs(candidates) do
        local dir = vim.fs.normalize(c)
        dbg(("candidate %s isdir=%s init=%s"):format(dir,
            tostring(vim.fn.isdirectory(dir)), tostring(vim.fn.filereadable(dir .. "/lua/outline/init.lua"))))
        if vim.fn.isdirectory(dir) == 1 and vim.fn.filereadable(dir .. "/lua/outline/init.lua") == 1 then
            found = dir
            break
        end
    end
    if found then
        vim.opt.rtp:append(found)
        local ok_req, req_err = pcall(require, "outline")
        dbg("require after rtp: " .. tostring(ok_req) .. " " .. tostring(req_err))
        if logf then logf:close() end
        if ok_req then
            cb(true)
            return
        end
    end
    dbg("fallthrough to clone")
    if logf then logf:close() end
    if vim.fn.executable("git") ~= 1 then
        notify_done(false, "未找到 git, 跳过 outline.nvim 预克隆 (可选功能)")
        cb(false)
        return
    end
    -- 多源依次尝试: 直连 github 失败则走 gh-proxy 镜像
    local urls = {
        "https://github.com/hedyhli/outline.nvim",
        "https://gh-proxy.com/https://github.com/hedyhli/outline.nvim",
    }
    vim.notify("Qt助手: 正在预克隆 outline.nvim (文档大纲侧边栏) ...", vim.log.levels.INFO)
    local try
    try = function(i)
        if i > #urls then
            notify_done(false, "outline.nvim 克隆失败 (可选功能, 文档渲染不受影响)")
            cb(false)
            return
        end
        vim.system({ "git", "clone", "--depth", "1", urls[i], clone_dir }, { text = true }, function(res)
            vim.schedule(function()
                if res.code == 0 then
                    vim.opt.rtp:append(clone_dir)
                    notify_done(true, "outline.nvim 就绪 (大纲侧边栏)")
                    cb(true)
                else
                    try(i + 1)
                end
            end)
        end)
    end
    try(1)
end

---确保 markdown treesitter 解析器可用 (仅用于语法高亮; outline 大纲为纯文本解析, 不依赖)
local function ensure_markdown_parser()
    if pcall(vim.treesitter.language.add, "markdown") then
        return
    end
    local has_ts = pcall(require, "nvim-treesitter")
    if has_ts then
        vim.notify("Qt助手: 正在安装 markdown 解析器 (:TSInstall markdown) ...", vim.log.levels.INFO)
        pcall(vim.cmd, "silent! TSInstall markdown")
    else
        notify_done(false, "未安装 nvim-treesitter, 跳过 markdown 解析器 (文档大纲不受影响)")
    end
end

---首次 setup 自动装齐: docset 下载 + outline 预克隆 + markdown 解析器检查
---全部异步, 不阻塞启动; 已就绪的项自动跳过; 失败只提示不中断
function M.bootstrap()
    if M._bootstrap_started then
        return
    end
    M._bootstrap_started = true
    local cfg = require("qt-assistant.core.config").get()
    local docs = cfg.docs or {}
    if docs.auto_bootstrap == false then
        return
    end
    -- docset 已就绪时静默; 缺失才提示下载
    M.install_docset(function(ok)
        if not ok and find_docset(docs) then
            -- 其他候选路径命中 (如本机已有), 无需提示
        end
    end)
    M.ensure_outline(function() end)
    vim.schedule(ensure_markdown_parser)
end

local function dsidx_path(docset)
    return docset .. "/Contents/Resources/docSet.dsidx"
end

--- Search the docset index for a term.
-- @param term string  search term (e.g. "QString::arg", "paint")
-- @param cb function(entries)  called with array of {name,type,path} or nil on error
function M.search(term, cb)
    local cfg = require("qt-assistant.core.config").get()
    local docs = cfg.docs or {}
    local docset = find_docset(docs)
    if not docset then
        vim.notify(
            "Qt助手: 未找到离线文档集 (docset)。请在 setup 中设置 docs.docset_path,\n"
                .. "例如 docs = { docset_path = 'E:/Tools/docsets/Qt.docset' }",
            vim.log.levels.WARN)
        cb(nil)
        return
    end
    local python = find_python(docs)
    local limit = tostring(docs.limit or 50)
    local argv = {
        python, script_path(), "search",
        dsidx_path(docset), term, limit,
    }
    vim.system(argv, { text = true }, function(res)
        local entries = nil
        if res.code == 0 and res.stdout and res.stdout ~= "" then
            local ok, decoded = pcall(vim.json.decode, res.stdout)
            if ok and type(decoded) == "table" then
                entries = decoded
            end
        end
        if not entries then
            vim.notify("Qt助手: 文档搜索失败: " .. tostring(res.stderr or res.code), vim.log.levels.ERROR)
        end
        vim.schedule(function()
            cb(entries)
        end)
    end)
end

--- Open a docset page inside a nvim buffer.
function M.open_page(entry)
    local cfg = require("qt-assistant.core.config").get()
    local docs = cfg.docs or {}
    local docset = find_docset(docs)
    if not docset then
        vim.notify("Qt助手: 未找到离线文档集, 请配置 docs.docset_path", vim.log.levels.WARN)
        return
    end
    local python = find_python(docs)
    local argv = { python, script_path(), "render", docset, entry.path }

    vim.system(argv, { text = true }, function(res)
        vim.schedule(function()
            if res.code ~= 0 or not res.stdout or res.stdout == "" then
                vim.notify("Qt助手: 渲染文档失败: " .. tostring(res.stderr or res.code), vim.log.levels.ERROR)
                return
            end
            local lines = vim.split(res.stdout:gsub("\r", ""), "\n")
            while #lines > 1 and lines[#lines] == "" do
                table.remove(lines)
            end
            local buf = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_buf_set_name(buf, "qt-docs://" .. entry.name)
            vim.bo[buf].buftype = "nofile"
            vim.bo[buf].bufhidden = "wipe"
            vim.bo[buf].swapfile = false
            vim.bo[buf].modifiable = true
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].filetype = "markdown"
            vim.bo[buf].modifiable = false

            local win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_get_config(win).relative ~= "" then
                -- already in a floating window (e.g. called from the main UI): open a split below
                vim.cmd("split")
                win = vim.api.nvim_get_current_win()
            else
                -- normal window: vertical split to keep code visible
                vim.cmd("vsplit")
                win = vim.api.nvim_get_current_win()
            end
            vim.api.nvim_win_set_buf(win, buf)
            local width = vim.api.nvim_win_get_width(win)
            if width > 120 then
                vim.api.nvim_win_set_width(win, math.floor(width / 2))
            end
            vim.wo[win].wrap = true
            vim.wo[win].linebreak = true
            vim.wo[win].spell = false
            vim.wo[win].number = false
            vim.wo[win].relativenumber = false
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true, desc = "关闭文档" })

            -- 若装了 outline.nvim: 为文档 buffer 打开标题大纲侧边栏 (markdown provider)
            vim.schedule(function()
                local ok_outline, outline = pcall(require, "outline")
                if not ok_outline then
                    return -- 未安装 outline.nvim, 静默跳过
                end
                -- outline.nvim 懒加载时 config 可能未初始化; 只在未初始化时补一次默认 setup
                local cfg_ok, ocfg = pcall(require, "outline.config")
                if cfg_ok and ocfg.o and next(ocfg.o) == nil then
                    pcall(outline.setup, {})
                end
                pcall(outline.open_outline, { focus_outline = false })
            end)
        end)
    end)
end

--- Interactive: search + pick + open.
function M.show(term)
    term = (term and term ~= "" and term) or vim.fn.expand("<cword>")
    term = vim.fn.trim(tostring(term))
    if term == "" then
        vim.notify("Qt助手: 请提供要查询的符号, 例如 :QtDocs QString::arg", vim.log.levels.WARN)
        return
    end
    M.search(term, function(entries)
        if not entries then
            return
        end
        if #entries == 0 then
            vim.notify("Qt助手: 离线文档中未找到 '" .. term .. "'", vim.log.levels.WARN)
            return
        end
        if #entries == 1 then
            M.open_page(entries[1])
            return
        end
        vim.ui.select(entries, {
            prompt = "Qt 文档: " .. term,
            format_item = function(e)
                return string.format("%-60s [%s]", e.name, e.type)
            end,
        }, function(choice)
            if choice then
                M.open_page(choice)
            end
        end)
    end)
end

--- Completion source for :QtDocs (synchronous, cheap query).
function M.complete(arg_lead)
    if not arg_lead or arg_lead == "" then
        return {}
    end
    local cfg = require("qt-assistant.core.config").get()
    local docs = cfg.docs or {}
    local docset = find_docset(docs)
    if not docset then
        return {}
    end
    local python = find_python(docs)
    local out = vim.fn.system({
        python, script_path(), "search", dsidx_path(docset), arg_lead, "12",
    })
    if vim.v.shell_error ~= 0 or out == "" then
        return {}
    end
    local ok, decoded = pcall(vim.json.decode, out)
    if not ok or type(decoded) ~= "table" then
        return {}
    end
    local names = {}
    for _, e in ipairs(decoded) do
        table.insert(names, e.name)
    end
    return names
end

return M
