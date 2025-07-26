-- Qt Assistant 配置示例 - packer.nvim

use {
    'onewu867/qt-assistant.nvim',
    ft = {'cpp', 'c', 'cmake'},  -- 只在相关文件类型时加载
    config = function()
        require('qt-assistant').setup({
            -- 基础配置
            project_root = vim.fn.getcwd(),
            naming_convention = "snake_case",  -- 或 "camelCase"
            auto_update_cmake = true,
            generate_comments = true,
            
            -- 目录结构
            directories = {
                source = "src",
                include = "include", 
                ui = "ui",
                resource = "resource",
                scripts = "scripts"
            },
            
            -- Qt项目设置
            qt_project = {
                build_type = "Debug",
                build_dir = "build",
                parallel_build = true,
                build_jobs = vim.loop.cpu_count()  -- 使用CPU核心数
            },
            
            -- UI设计师设置
            designer = {
                default_editor = "designer",
                auto_sync = true,
                enable_preview = true
            },
            
            -- 调试设置
            debug = {
                enabled = false,
                log_level = "INFO"
            }
        })
        
        -- 自定义快捷键映射
        local map = vim.keymap.set
        map('n', '<leader>qc', '<cmd>QtAssistant<cr>', { desc = 'Qt Assistant' })
        map('n', '<leader>qb', '<cmd>QtBuildProject<cr>', { desc = 'Build Project' })
        map('n', '<leader>qr', '<cmd>QtRunProject<cr>', { desc = 'Run Project' })
        map('n', '<leader>qd', '<cmd>QtOpenDesigner<cr>', { desc = 'Open Designer' })
    end
}
EOF < /dev/null