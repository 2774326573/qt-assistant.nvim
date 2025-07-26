# Qt Assistant 配置故障排除指南

**最后更新**: 2025-07-26 (v1.2.0)  
**适用版本**: v1.0.0 - v1.2.0

## 🆕 v1.2.0 修复问题

### 1. 模块循环依赖已修复
- **状态**: ✅ 已完全修复
- **影响**: 主界面 (`<leader>qc`) 和类创建功能正常工作
- **无需额外配置**: 升级到 v1.2.0 即可自动修复

### 2. 系统信息显示已修复  
- **状态**: ✅ 已完全修复
- **影响**: 系统信息 (`<leader>qis`) 正常显示
- **无需额外配置**: 升级到 v1.2.0 即可自动修复

### 3. 快捷键映射已补全
- **状态**: ✅ 已完全修复
- **影响**: 所有脚本管理快捷键正常工作
- **无需额外配置**: 升级到 v1.2.0 即可自动使用

---

## 🔧 v1.0.0 循环依赖修复后的配置问题

### 问题描述
在v1.0.0版本中，我们修复了循环依赖问题，但某些用户可能遇到配置错误：

```
Failed to run `config` for qt-assistant.nvim
attempt to call field 'setup' (a nil value)
```

### 根本原因
这个问题是由于 `lua/qt-assistant/init.lua` 文件与主模块 `lua/qt-assistant.lua` 冲突造成的。当执行 `require('qt-assistant')` 时，Lua模块系统会优先加载 `qt-assistant/init.lua` 而不是 `qt-assistant.lua`，而 `init.lua` 没有导出 `setup` 函数。

### 解决方案

#### 1. 删除冲突的init.lua文件（已修复）
如果您在使用最新版本，这个问题已经被修复。冲突的 `init.lua` 文件已被移除。

#### 2. 清除lazy.nvim缓存
如果仍然遇到问题，请清除插件缓存：

```bash
# 清除lazy.nvim缓存
rm -rf ~/.local/share/nvim/lazy/qt-assistant.nvim

# 清除Lua编译缓存
rm -rf ~/.cache/nvim/luac
rm -rf ~/.local/state/nvim/lazy/cache
```

#### 3. 确认正确的配置方式
请确保使用正确的模块路径：

```lua
-- ✅ 正确的配置方式
require('qt-assistant').setup({
    -- 您的配置选项
})

-- ❌ 错误的配置方式
require('qt-assistant.config').setup({})  -- 这是内部模块
```

#### 4. 检查插件安装
确保插件已正确安装：

**lazy.nvim:**
```lua
{
    '2774326573/qt-assistant.nvim',
    config = function()
        require('qt-assistant').setup({
            -- 配置选项
        })
    end
}
```

**packer.nvim:**
```lua
use {
    '2774326573/qt-assistant.nvim',
    config = function()
        require('qt-assistant').setup()
    end
}
```

#### 5. 检查Neovim版本
确保使用支持的Neovim版本：
- 最低版本：0.8+
- 推荐版本：0.9+

#### 6. 清除缓存
如果仍有问题，请清除Lua模块缓存：

```vim
:lua package.loaded['qt-assistant'] = nil
:lua package.loaded['qt-assistant.config'] = nil
:lua require('qt-assistant').setup()
```

#### 7. 检查错误日志
启用详细错误信息：

```lua
require('qt-assistant').setup({
    debug = {
        enabled = true,
        log_level = "DEBUG"
    }
})
```

### 配置示例

#### 基础配置
```lua
require('qt-assistant').setup({
    project_root = vim.fn.getcwd(),
    naming_convention = "snake_case",
    auto_update_cmake = true,
})
```

#### 完整配置
```lua
require('qt-assistant').setup({
    -- 项目根目录
    project_root = vim.fn.getcwd(),
    
    -- 目录结构
    directories = {
        source = "src",
        include = "include",
        ui = "ui",
        resource = "resource",
        scripts = "scripts"
    },
    
    -- 命名规范
    naming_convention = "snake_case", -- 或 "camelCase"
    
    -- CMake集成
    auto_update_cmake = true,
    
    -- 快捷键
    enable_default_keymaps = true,
})
```

---

## 🔍 v1.2.0 快速诊断

### 插件状态检查

运行以下命令检查插件状态：

```vim
" 1. 检查插件是否加载
:lua print("Plugin loaded:", vim.g.loaded_qt_assistant or "NO")

" 2. 测试主界面（应该无循环依赖错误）
<leader>qc

" 3. 测试系统信息（应该正常显示）  
<leader>qis

" 4. 测试脚本功能
<leader>qsa

" 5. 列出所有可用命令
:command Qt<Tab>
```

### 常见错误及解决方案

#### 1. "loop or previous error loading module"
- **状态**: ✅ v1.2.0 已修复
- **临时解决**: 重启 Neovim

#### 2. "attempt to concatenate field 'hostname'"  
- **状态**: ✅ v1.2.0 已修复
- **临时解决**: 避免使用 `<leader>qis`

#### 3. "快捷键无响应"
- **状态**: ✅ v1.2.0 已修复
- **检查**: 确认 `enable_default_keymaps = true`

### 版本验证

检查您的版本：
```vim
:lua print(require('qt-assistant')._VERSION or "Unknown")
```

如果返回 "Unknown"，说明您使用的是旧版本，建议升级到 v1.2.0。

---

## 📞 获取支持

如果问题仍然存在：

1. **查看日志**: `:messages` 查看错误信息
2. **重新加载**: 重启 Neovim 并重新测试
3. **检查依赖**: 确保 Neovim ≥ 0.8.0
4. **清除缓存**: 删除插件缓存文件
5. **报告问题**: 提交详细的错误报告

---

**文档版本**: v1.2.0 (2025-07-26)
