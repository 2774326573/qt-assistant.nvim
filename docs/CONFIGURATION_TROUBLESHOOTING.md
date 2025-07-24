# Qt Assistant 配置故障排除指南

## 🔧 循环依赖修复后的配置问题

### 问题描述
在v1.0.0版本中，我们修复了循环依赖问题，但某些用户可能遇到配置错误：

```
Failed to run `config` for qt-assistant.nvim
attempt to call field 'setup' (a nil value)
```

### 解决方案

#### 1. 确认正确的配置方式
请确保使用正确的模块路径：

```lua
-- ✅ 正确的配置方式
require('qt-assistant').setup({
    -- 您的配置选项
})

-- ❌ 错误的配置方式
require('qt-assistant.config').setup({})  -- 这是内部模块
```

#### 2. 检查插件安装
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

#### 3. 检查Neovim版本
确保使用支持的Neovim版本：
- 最低版本：0.8+
- 推荐版本：0.9+

#### 4. 清除缓存
如果仍有问题，请清除Lua模块缓存：

```vim
:lua package.loaded['qt-assistant'] = nil
:lua package.loaded['qt-assistant.config'] = nil
:lua require('qt-assistant').setup()
```

#### 5. 检查错误日志
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
    
    -- 注释生成
    generate_comments = true,
    
    -- Qt项目配置
    qt_project = {
        auto_detect = true,
        build_type = "Debug",
        build_dir = "build",
        parallel_build = true,
        build_jobs = 4
    },
    
    -- UI设计师集成
    designer = {
        designer_path = "designer",
        creator_path = "qtcreator",
        default_editor = "designer",
        auto_sync = true,
        enable_preview = true
    },
    
    -- 调试配置
    debug = {
        enabled = false,
        log_level = "INFO",
        log_file = vim.fn.stdpath('data') .. '/qt-assistant.log'
    }
})
```

### 常见配置错误

#### 错误1：模块路径错误
```lua
-- ❌ 错误
require('qt-assistant.config').setup()

-- ✅ 正确
require('qt-assistant').setup()
```

#### 错误2：语法错误
```lua
-- ❌ 错误（缺少逗号）
require('qt-assistant').setup({
    project_root = vim.fn.getcwd()
    naming_convention = "snake_case"
})

-- ✅ 正确
require('qt-assistant').setup({
    project_root = vim.fn.getcwd(),  -- 注意逗号
    naming_convention = "snake_case"
})
```

#### 错误3：函数调用错误
```lua
-- ❌ 错误（缺少括号）
require('qt-assistant').setup

-- ✅ 正确
require('qt-assistant').setup()
```

### 验证配置

运行以下命令验证配置是否成功：

```vim
:lua print(vim.inspect(require('qt-assistant').get_config()))
```

### 获取帮助

如果问题仍然存在：

1. 检查 [GitHub Issues](https://github.com/2774326573/qt-assistant.nvim/issues)
2. 创建新的Issue并提供：
   - 完整的错误消息
   - Neovim版本（`:version`）
   - 配置代码
   - 操作系统信息

## 📝 配置最佳实践

### 1. 渐进式配置
从基础配置开始，逐步添加选项：

```lua
-- 第一步：基础配置
require('qt-assistant').setup()

-- 第二步：添加必要选项
require('qt-assistant').setup({
    naming_convention = "snake_case"
})

-- 第三步：完整配置
require('qt-assistant').setup({
    -- 完整配置选项...
})
```

### 2. 条件配置
根据项目类型动态配置：

```lua
local config = {
    project_root = vim.fn.getcwd(),
}

-- 检查是否是Qt项目
if vim.fn.filereadable("CMakeLists.txt") == 1 then
    config.auto_update_cmake = true
end

require('qt-assistant').setup(config)
```

### 3. 用户特定配置
为不同用户或环境提供不同配置：

```lua
local user_config = {
    project_root = vim.fn.getcwd(),
    naming_convention = "snake_case",
}

-- Windows用户特定配置
if vim.fn.has("win32") == 1 then
    user_config.designer = {
        designer_path = "C:/Qt/6.5.0/msvc2019_64/bin/designer.exe"
    }
end

require('qt-assistant').setup(user_config)
```

---

**版本**: v1.0.0  
**更新日期**: 2025-07-25  
**适用范围**: 循环依赖修复后的配置问题
