-- Qt Assistant Plugin - 初始化模块
-- Plugin initialization module

-- 这个文件为了避免循环依赖，暂时不直接返回主模块
-- 如果需要访问主模块，请直接require('qt-assistant')

local M = {}

-- 返回配置管理器，供其他模块使用
M.config = require('qt-assistant.config')

return M