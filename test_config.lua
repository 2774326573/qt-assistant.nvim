-- 简单的测试配置
-- 只需要基本的setup调用
require('qt-assistant').setup({
    project_root = vim.fn.getcwd(),
    debug = {
        enabled = true,
        log_level = "INFO"
    }
})

print("Qt Assistant test configuration loaded\!")
EOF < /dev/null