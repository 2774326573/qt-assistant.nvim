-- Qt Assistant 基础配置示例

-- 简单配置（启用默认快捷键）
require('qt-assistant').setup({
    enable_default_keymaps = true  -- 启用默认快捷键
})

-- 自定义快捷键
vim.keymap.set('n', '<F5>', '<cmd>QtBuildProject<cr>', { desc = 'Build Project' })
vim.keymap.set('n', '<F6>', '<cmd>QtRunProject<cr>', { desc = 'Run Project' })
vim.keymap.set('n', '<F7>', '<cmd>QtOpenDesigner<cr>', { desc = 'Open Designer' })

-- 自动命令示例
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'cpp', 'c'},
    callback = function()
        -- 在C++文件中添加特定的快捷键
        vim.keymap.set('n', '<leader>cc', '<cmd>QtCreateClass<cr>', 
                      { buffer = true, desc = 'Create Qt Class' })
    end
})
EOF < /dev/null