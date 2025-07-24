-- Qt Assistant 配置示例 - lazy.nvim

return {
    'onewu867/qt-assistant.nvim',
    ft = {'cpp', 'c', 'cmake'},  -- 只在相关文件类型时加载
    cmd = {
        'QtAssistant',
        'QtCreateClass',
        'QtCreateUI',
        'QtCreateModel',
        'QtOpenProject',
        'QtBuildProject',
        'QtRunProject',
        'QtCleanProject',
        'QtInitScripts',
        'QtScript',
        'QtOpenDesigner',
        'QtProjectManager',
        'QtDesignerManager',
        'QtBuildStatus',
        'QtSystemInfo'
    },
    keys = {
        { '<leader>qc', '<cmd>QtAssistant<cr>', desc = 'Qt Assistant' },
        { '<leader>qh', '<cmd>help qt-assistant<cr>', desc = 'Qt Help' },
        { '<leader>qpo', '<cmd>QtOpenProject<cr>', desc = 'Open Project' },
        { '<leader>qpm', '<cmd>QtProjectManager<cr>', desc = 'Project Manager' },
        { '<leader>qb', '<cmd>QtBuildProject<cr>', desc = 'Build Project' },
        { '<leader>qr', '<cmd>QtRunProject<cr>', desc = 'Run Project' },
        { '<leader>qcl', '<cmd>QtCleanProject<cr>', desc = 'Clean Project' },
        { '<leader>qbs', '<cmd>QtBuildStatus<cr>', desc = 'Build Status' },
        { '<leader>qud', '<cmd>QtOpenDesigner<cr>', desc = 'Open Designer' },
        { '<leader>quc', '<cmd>QtOpenDesignerCurrent<cr>', desc = 'Designer Current' },
        { '<leader>qum', '<cmd>QtDesignerManager<cr>', desc = 'Designer Manager' },
        { '<leader>qsb', '<cmd>QtScript build<cr>', desc = 'Script Build' },
        { '<leader>qsr', '<cmd>QtScript run<cr>', desc = 'Script Run' },
        { '<leader>qsd', '<cmd>QtScript debug<cr>', desc = 'Script Debug' },
        { '<leader>qsi', '<cmd>QtSystemInfo<cr>', desc = 'System Info' },
    },
    config = function()
        require('qt-assistant').setup({
            -- 项目根目录（默认为当前工作目录）
            project_root = vim.fn.getcwd(),
            
            -- 目录结构配置
            directories = {
                source = "src",           -- 源文件目录
                include = "include",      -- 头文件目录  
                ui = "ui",               -- UI文件目录
                resource = "resource",    -- 资源文件目录
                scripts = "scripts"       -- 脚本目录
            },
            
            -- 文件命名规范
            naming_convention = "snake_case", -- "snake_case" 或 "camelCase"
            
            -- 自动更新CMakeLists.txt
            auto_update_cmake = true,
            
            -- 生成注释
            generate_comments = true,
            
            -- Qt项目配置
            qt_project = {
                auto_detect = true,       -- 自动检测项目类型
                build_type = "Debug",     -- 默认构建类型
                build_dir = "build",      -- 构建目录
                parallel_build = true,    -- 并行构建
                build_jobs = 4            -- 构建线程数
            },
            
            -- UI设计师配置
            designer = {
                designer_path = "designer",     -- Qt Designer路径
                creator_path = "qtcreator",     -- Qt Creator路径
                default_editor = "designer",    -- 默认编辑器
                auto_sync = true,               -- 自动同步UI文件
                enable_preview = true,          -- 启用预览功能
                -- 自定义编辑器配置
                custom_editor = {
                    command = "",               -- 自定义编辑器命令
                    args = {"{file}"}          -- 命令参数
                }
            },
            
            -- 调试配置
            debug = {
                enabled = false,                -- 启用调试模式
                log_level = "INFO",            -- 日志级别
                log_file = vim.fn.stdpath('data') .. '/qt-assistant.log'
            }
        })
    end
}
EOF < /dev/null