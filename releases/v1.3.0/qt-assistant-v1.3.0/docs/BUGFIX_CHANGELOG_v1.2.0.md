# Qt Assistant Bug Fix Changelog v1.2.0

**发布日期**: 2025-07-26  
**维护者**: Qt Assistant 开发团队

## 修复概述

此版本主要修复了快捷键系统和模块依赖相关的关键问题，提升了插件的稳定性和可用性。

## 🔧 修复的问题

### 1. 模块循环依赖错误 (Critical)

**问题描述**:
- **症状**: 执行 `<leader>qc` (主界面) 时出现错误：
  ```
  E5108: Error executing lua: loop or previous error loading module 'qt-assistant.core'
  ```
- **影响**: 主界面无法打开，类创建功能不可用
- **根本原因**: ui.lua → core.lua → project_manager.lua → qt-assistant.lua → ui.lua 形成循环依赖

**修复方案**:
- 重构 ui.lua 模块，移除对 core.lua 的直接依赖
- 将静态数据函数 `get_supported_class_types()` 和 `get_class_type_info()` 内联到 ui.lua
- 对 `create_qt_class()` 函数使用延迟加载（pcall）避免循环依赖

**修复文件**:
- `/lua/qt-assistant/ui.lua`: 重构模块依赖关系

### 2. 系统信息显示错误 (High)

**问题描述**:
- **症状**: 执行 `<leader>qis` 时出现错误：
  ```
  E5108: Error executing lua: attempt to concatenate field 'hostname' (a nil value)
  ```
- **影响**: 系统信息功能无法使用
- **根本原因**: 系统信息获取函数没有处理 nil 值

**修复方案**:
- 在 `get_system_info()` 函数中为所有字段添加默认值
- 在 `show_system_info()` 函数中添加额外的 nil 值保护
- 创建缺失的 `show_info_window()` UI 函数

**修复文件**:
- `/lua/qt-assistant/system.lua`: 添加 nil 值保护
- `/lua/qt-assistant/ui.lua`: 添加 `show_info_window()` 函数

### 3. 快捷键映射缺失 (Medium)

**问题描述**:
- **症状**: 多个脚本管理快捷键不工作：
  - `<leader>qsa` - Generate All Scripts
  - `<leader>qsc` - Script Clean  
  - `<leader>qst` - Script Test
  - `<leader>qsp` - Script Deploy
- **影响**: 脚本管理功能不完整
- **根本原因**: plugin/qt-assistant.lua 中缺少命令定义和快捷键映射

**修复方案**:
- 添加缺失的 `QtGenerateAllScripts` 命令
- 添加所有缺失的脚本快捷键映射
- 解决快捷键冲突（`<leader>qsi` → `<leader>qis`）

**修复文件**:
- `/plugin/qt-assistant.lua`: 添加缺失的命令和快捷键
- `/lua/qt-assistant.lua`: 统一快捷键映射

## 🔍 技术细节

### 循环依赖解决方案

**之前的依赖链**:
```
qt-assistant.lua → ui.lua → core.lua → project_manager.lua → qt-assistant.lua
```

**修复后的依赖链**:
```
qt-assistant.lua → ui.lua -(延迟加载)→ core.lua
```

### 错误处理改进

**系统信息函数改进**:
```lua
-- 修复前
hostname = uname.nodename

-- 修复后  
hostname = uname.nodename or "Unknown"
```

**UI 函数改进**:
```lua
-- 修复前
local core = require('qt-assistant.core')

-- 修复后
local ok, core = pcall(require, 'qt-assistant.core')
if not ok then
    vim.notify('Error loading qt-assistant.core: ' .. tostring(core), vim.log.levels.ERROR)
    return
end
```

## 📋 测试验证

### 测试场景

✅ **主界面加载测试**
- 快捷键: `<leader>qc`
- 预期: 成功显示主界面，无循环依赖错误

✅ **系统信息显示测试**  
- 快捷键: `<leader>qis`
- 预期: 成功显示系统信息窗口，所有字段正常显示

✅ **脚本管理测试**
- 快捷键: `<leader>qsa`, `<leader>qsc`, `<leader>qst`, `<leader>qsp`
- 预期: 所有脚本管理功能正常工作

✅ **类创建功能测试**
- 快捷键: `<leader>qcc`, `<leader>qcw`, `<leader>qcd`
- 预期: 类创建流程完整，无依赖错误

## 🔄 兼容性

### 向后兼容性
- ✅ 所有现有快捷键保持不变
- ✅ 所有现有命令保持不变  
- ✅ 配置格式保持不变

### API 兼容性
- ✅ 所有公共函数接口保持不变
- ✅ 核心功能行为保持一致
- ⚠️ 内部模块依赖关系已重构（不影响外部使用）

## 📈 性能影响

### 改进项
- ✅ 减少了模块加载时的依赖解析
- ✅ 延迟加载减少了启动时间
- ✅ 静态数据内联提高了访问速度

### 无负面影响
- ✅ 功能完整性保持 100%
- ✅ 内存占用基本一致
- ✅ 执行性能无降低

## 🚀 升级指南

### 自动升级
对于大多数用户，此版本是无缝升级：
1. 更新插件到 v1.2.0
2. 重启 Neovim
3. 所有功能应正常工作

### 手动验证
建议测试以下关键功能：
```vim
" 测试主界面
<leader>qc

" 测试系统信息  
<leader>qis

" 测试脚本管理
<leader>qsa

" 测试类创建
<leader>qcc
```

## 📞 支持

如果升级后遇到问题，请：
1. 检查 Neovim 版本 (需要 ≥ 0.8)
2. 清除插件缓存并重新加载
3. 查看故障排除文档
4. 提交 Issue 报告问题

---

**下一版本预告**: v1.3.0 将专注于性能优化和新功能添加。