-- Qt Assistant Plugin - 键盘映射模块
-- Keyboard mapping module

local M = {}

-- 获取插件配置
local function get_config()
    return require('qt-assistant.config').get()
end

-- 默认键盘映射配置
local default_keymaps = {
    -- Qt项目操作
    build = "<leader>qtb",           -- 构建项目
    run = "<leader>qtr",             -- 运行项目
    clean = "<leader>qtc",           -- 清理项目
    debug = "<leader>qtd",           -- 调试项目
    test = "<leader>qtt",            -- 运行测试
    deploy = "<leader>qtp",          -- 部署项目
    
    -- 环境设置
    setup_msvc = "<leader>qem",      -- 设置MSVC环境
    setup_clangd = "<leader>qel",    -- 设置clangd
    check_msvc = "<leader>qek",      -- 检查MSVC状态
    fix_pro = "<leader>qef",         -- 修复.pro文件
    
    -- 脚本管理
    generate_scripts = "<leader>qsg", -- 生成脚本
    edit_scripts = "<leader>qse",     -- 编辑脚本
    show_status = "<leader>qss",      -- 显示状态
    
    -- Qt Designer
    open_designer = "<leader>qdu",    -- 打开Qt Designer
    
    -- 项目管理
    init_project = "<leader>qpi",     -- 初始化项目
    select_project = "<leader>qpo",   -- 选择项目
}

-- 设置键盘映射
function M.setup_keymaps(user_keymaps)
    user_keymaps = user_keymaps or {}
    
    -- 合并用户配置和默认配置
    local keymaps = vim.tbl_deep_extend("force", default_keymaps, user_keymaps)
    
    -- Qt项目构建相关
    vim.keymap.set('n', keymaps.build, function()
        require('qt-assistant.scripts').run_script('build', {in_terminal = true})
    end, {desc = "Qt: Build project"})
    
    vim.keymap.set('n', keymaps.run, function()
        require('qt-assistant.scripts').run_script('run', {in_terminal = true})
    end, {desc = "Qt: Run project"})
    
    vim.keymap.set('n', keymaps.clean, function()
        require('qt-assistant.scripts').run_script('clean', {in_terminal = true})
    end, {desc = "Qt: Clean project"})
    
    vim.keymap.set('n', keymaps.debug, function()
        require('qt-assistant.scripts').run_script('debug', {in_terminal = true})
    end, {desc = "Qt: Debug project"})
    
    vim.keymap.set('n', keymaps.test, function()
        require('qt-assistant.scripts').run_script('test', {in_terminal = true})
    end, {desc = "Qt: Run tests"})
    
    vim.keymap.set('n', keymaps.deploy, function()
        require('qt-assistant.scripts').run_script('deploy', {in_terminal = true})
    end, {desc = "Qt: Deploy project"})
    
    -- 环境设置相关
    vim.keymap.set('n', keymaps.setup_msvc, function()
        require('qt-assistant.scripts').generate_single_script('setup_msvc')
        vim.cmd('terminal scripts\\setup-msvc.bat')
    end, {desc = "Qt: Setup MSVC environment"})
    
    vim.keymap.set('n', keymaps.setup_clangd, function()
        require('qt-assistant.scripts').generate_single_script('setup_clangd')
        vim.cmd('terminal scripts\\setup-clangd.bat')
    end, {desc = "Qt: Setup clangd for Neovim"})
    
    vim.keymap.set('n', keymaps.check_msvc, function()
        require('qt-assistant.scripts').generate_single_script('check_msvc')
        vim.cmd('terminal scripts\\check-msvc.bat')
    end, {desc = "Qt: Check MSVC status"})
    
    vim.keymap.set('n', keymaps.fix_pro, function()
        require('qt-assistant.scripts').generate_single_script('fix_pro')
        vim.cmd('terminal scripts\\fix-pro.bat')
    end, {desc = "Qt: Fix .pro file MSVC paths"})
    
    -- 脚本管理相关
    vim.keymap.set('n', keymaps.generate_scripts, function()
        require('qt-assistant.scripts').quick_generate_scripts()
    end, {desc = "Qt: Generate all scripts"})
    
    vim.keymap.set('n', keymaps.edit_scripts, function()
        M.show_script_selector()
    end, {desc = "Qt: Edit scripts"})
    
    vim.keymap.set('n', keymaps.show_status, function()
        require('qt-assistant.scripts').show_script_status()
    end, {desc = "Qt: Show script status"})
    
    -- Qt Designer
    vim.keymap.set('n', keymaps.open_designer, function()
        require('qt-assistant.designer').open_current_ui_file()
    end, {desc = "Qt: Open current .ui file in Designer"})
    
    -- 项目管理
    vim.keymap.set('n', keymaps.init_project, function()
        require('qt-assistant.project_manager').init_project()
    end, {desc = "Qt: Initialize Qt project"})
    
    vim.keymap.set('n', keymaps.select_project, function()
        M.show_project_selector()
    end, {desc = "Qt: Select Qt project"})
    
    -- 快速访问命令
    vim.api.nvim_create_user_command('QtBuild', function()
        require('qt-assistant.scripts').run_script('build', {in_terminal = true})
    end, {desc = "Build Qt project"})
    
    vim.api.nvim_create_user_command('QtRun', function()
        require('qt-assistant.scripts').run_script('run', {in_terminal = true})
    end, {desc = "Run Qt project"})
    
    vim.api.nvim_create_user_command('QtClean', function()
        require('qt-assistant.scripts').run_script('clean', {in_terminal = true})
    end, {desc = "Clean Qt project"})
    
    vim.api.nvim_create_user_command('QtDebug', function()
        require('qt-assistant.scripts').run_script('debug', {in_terminal = true})
    end, {desc = "Debug Qt project"})
    
    vim.api.nvim_create_user_command('QtTest', function()
        require('qt-assistant.scripts').run_script('test', {in_terminal = true})
    end, {desc = "Run Qt tests"})
    
    vim.api.nvim_create_user_command('QtSetupClangd', function()
        require('qt-assistant.scripts').generate_single_script('setup_clangd')
        vim.cmd('terminal scripts\\setup-clangd.bat')
    end, {desc = "Setup clangd for Qt project"})
    
    vim.api.nvim_create_user_command('QtSetupMsvc', function()
        require('qt-assistant.scripts').generate_single_script('setup_msvc')
        vim.cmd('terminal scripts\\setup-msvc.bat')
    end, {desc = "Setup MSVC environment"})
    
    vim.api.nvim_create_user_command('QtFixPro', function()
        require('qt-assistant.scripts').generate_single_script('fix_pro')
        vim.cmd('terminal scripts\\fix-pro.bat')
    end, {desc = "Fix .pro file MSVC paths"})
    
    vim.api.nvim_create_user_command('QtScripts', function()
        require('qt-assistant.scripts').quick_generate_scripts()
    end, {desc = "Generate all Qt scripts"})
    
    vim.api.nvim_create_user_command('QtStatus', function()
        require('qt-assistant.scripts').show_script_status()
    end, {desc = "Show Qt project status"})
    
    vim.api.nvim_create_user_command('QtDesigner', function()
        require('qt-assistant.designer').open_current_ui_file()
    end, {desc = "Open current .ui file in Qt Designer"})
    
    -- 设置 which-key 集成
    M.setup_which_key()
end

-- 显示脚本选择器
function M.show_script_selector()
    local scripts = require('qt-assistant.scripts').list_scripts()
    
    if #scripts == 0 then
        vim.notify("No scripts found. Run :QtScripts to generate them.", vim.log.levels.WARN)
        return
    end
    
    vim.ui.select(scripts, {
        prompt = "Select script to edit:",
        format_item = function(item)
            return item
        end,
    }, function(choice)
        if choice then
            local scripts_dir = require('qt-assistant.scripts').get_scripts_directory()
            local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
            local script_ext = is_windows and ".bat" or ".sh"
            local script_path = scripts_dir .. "/" .. choice .. script_ext
            vim.cmd("edit " .. vim.fn.fnameescape(script_path))
        end
    end)
end

-- 显示项目选择器
function M.show_project_selector()
    -- 这里可以集成项目管理功能
    local projects = {"Current Project"} -- 可以从配置文件读取项目列表
    
    vim.ui.select(projects, {
        prompt = "Select Qt project:",
        format_item = function(item)
            return item
        end,
    }, function(choice)
        if choice then
            vim.notify("Selected project: " .. choice, vim.log.levels.INFO)
        end
    end)
end

-- 创建Which-key集成
function M.setup_which_key()
    local ok, wk = pcall(require, "which-key")
    if not ok then
        -- 如果没有which-key，创建简单的中间键映射来显示菜单
        M.setup_fallback_menus()
        return
    end
    
    wk.register({
        q = {
            name = "Qt Assistant",
            t = {
                name = "Tasks",
                b = { function() require('qt-assistant.scripts').run_script('build', {in_terminal = true}) end, "Build Project" },
                r = { function() require('qt-assistant.scripts').run_script('run', {in_terminal = true}) end, "Run Project" },
                c = { function() require('qt-assistant.scripts').run_script('clean', {in_terminal = true}) end, "Clean Project" },
                d = { function() require('qt-assistant.scripts').run_script('debug', {in_terminal = true}) end, "Debug Project" },
                t = { function() require('qt-assistant.scripts').run_script('test', {in_terminal = true}) end, "Run Tests" },
                p = { function() require('qt-assistant.scripts').run_script('deploy', {in_terminal = true}) end, "Deploy Project" },
            },
            e = {
                name = "Environment",
                m = { function() 
                    require('qt-assistant.scripts').generate_single_script('setup_msvc')
                    vim.cmd('terminal scripts\\\\setup-msvc.bat')
                end, "Setup MSVC" },
                l = { function()
                    require('qt-assistant.scripts').generate_single_script('setup_clangd')
                    vim.cmd('terminal scripts\\\\setup-clangd.bat')
                end, "Setup Clangd" },
                k = { function()
                    require('qt-assistant.scripts').generate_single_script('check_msvc')
                    vim.cmd('terminal scripts\\\\check-msvc.bat')
                end, "Check MSVC" },
                f = { function()
                    require('qt-assistant.scripts').generate_single_script('fix_pro')
                    vim.cmd('terminal scripts\\\\fix-pro.bat')
                end, "Fix .pro File" },
            },
            s = {
                name = "Scripts",
                g = { function() require('qt-assistant.scripts').quick_generate_scripts() end, "Generate Scripts" },
                e = { function() M.show_script_selector() end, "Edit Scripts" },
                s = { function() require('qt-assistant.scripts').show_script_status() end, "Show Status" },
            },
            d = {
                name = "Designer",
                u = { function() require('qt-assistant.designer').open_current_ui_file() end, "Qt Designer" },
            },
            p = {
                name = "Project",
                i = { function() require('qt-assistant.project_manager').init_project() end, "Init Project" },
                o = { function() M.show_project_selector() end, "Select Project" },
            },
        }
    }, { prefix = "<leader>" })
end

-- 为没有which-key的用户提供备用菜单
function M.setup_fallback_menus()
    -- 获取当前的 leader 键，如果是空格键需要特殊处理
    local leader = vim.g.mapleader or "\\"
    local leader_key = leader == " " and "<Space>" or "<leader>"
    
    -- 创建中间键的映射来显示菜单
    vim.keymap.set('n', leader_key .. 'qt', function()
        local menu_items = {
            "Qt Tasks:",
            "b - Build Project",
            "r - Run Project", 
            "c - Clean Project",
            "d - Debug Project",
            "t - Run Tests",
            "p - Deploy Project"
        }
        vim.notify(table.concat(menu_items, "\n"), vim.log.levels.INFO, {title = "Qt Assistant - Tasks"})
    end, {desc = "Qt: Task menu"})
    
    vim.keymap.set('n', leader_key .. 'qe', function()
        local menu_items = {
            "Qt Environment:",
            "m - Setup MSVC",
            "l - Setup Clangd",
            "k - Check MSVC",
            "f - Fix .pro File"
        }
        vim.notify(table.concat(menu_items, "\n"), vim.log.levels.INFO, {title = "Qt Assistant - Environment"})
    end, {desc = "Qt: Environment menu"})
    
    vim.keymap.set('n', leader_key .. 'qs', function()
        local menu_items = {
            "Qt Scripts:",
            "g - Generate Scripts",
            "e - Edit Scripts",
            "s - Show Status"
        }
        vim.notify(table.concat(menu_items, "\n"), vim.log.levels.INFO, {title = "Qt Assistant - Scripts"})
    end, {desc = "Qt: Scripts menu"})
    
    vim.keymap.set('n', leader_key .. 'qd', function()
        local menu_items = {
            "Qt Designer:",
            "u - Open Qt Designer"
        }
        vim.notify(table.concat(menu_items, "\n"), vim.log.levels.INFO, {title = "Qt Assistant - Designer"})
    end, {desc = "Qt: Designer menu"})
    
    vim.keymap.set('n', leader_key .. 'qp', function()
        local menu_items = {
            "Qt Project:",
            "i - Init Project",
            "o - Select Project"
        }
        vim.notify(table.concat(menu_items, "\n"), vim.log.levels.INFO, {title = "Qt Assistant - Project"})
    end, {desc = "Qt: Project menu"})
    
    -- 调试信息
    vim.notify("Qt Assistant: 备用菜单已设置 (leader=" .. leader .. ")", vim.log.levels.INFO)
end

-- 获取默认键盘映射
function M.get_default_keymaps()
    return default_keymaps
end

return M