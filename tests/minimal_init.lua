-- Headless init for the qt-assistant test suite.
-- Usage:
--   nvim --headless -n -i NONE -u tests/minimal_init.lua -c "lua dofile('tests/run.lua')"

vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.swapfile = false
vim.opt.hidden = true
vim.opt.more = false
vim.opt.shortmess:append('filnxtToOFA')
vim.opt.cmdheight = 4
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

if vim.o.columns < 100 then
    vim.o.columns = 120
end
if vim.o.lines < 40 then
    vim.o.lines = 48
end
