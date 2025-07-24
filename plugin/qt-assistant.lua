-- Qt Assistant Plugin Entry Point
-- 这个文件确保插件能被Neovim正确加载

-- 检查Neovim版本
if vim.fn.has('nvim-0.8') ~= 1 then
    vim.notify('Qt Assistant requires Neovim 0.8 or higher', vim.log.levels.ERROR)
    return
end

-- 自动加载插件
require('qt-assistant')