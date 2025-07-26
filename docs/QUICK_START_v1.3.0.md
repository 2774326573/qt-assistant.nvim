# Qt Assistant v1.3.0 快速使用指南

本指南将帮助你快速上手Qt Assistant v1.3.0的新功能，特别是Windows MSVC环境和clangd LSP支持。

## 🚀 快速开始

### 1. 安装配置

```lua
-- lazy.nvim
{
    '2774326573/qt-assistant.nvim',
    config = function()
        require('qt-assistant').setup({
            -- 基本配置
            qt_project = {
                version = "auto",  -- 自动检测Qt版本
            },
            auto_format = {
                enabled = true,    -- 启用自动格式化
            },
        })
        
        -- 启用键盘映射 (新功能)
        require('qt-assistant.core').setup_keymaps()
    end
}
```

### 2. 基础工作流程

**第一次使用项目时：**

```bash
# 1. 生成项目脚本
<leader>qg  # 或 :QtScripts

# 2. 设置clangd (解决LSP问题)
<leader>ql  # 或 :QtSetupClangd

# 3. 设置MSVC环境 (Windows用户)
<leader>qm  # 或 :QtSetupMsvc
```

**日常开发流程：**

```bash
# 构建项目
<leader>qb  # 或 :QtBuild

# 运行项目
<leader>qr  # 或 :QtRun

# 清理项目
<leader>qc  # 或 :QtClean
```

## 🔧 解决Windows编译问题

### 问题：无法打开包括文件 "type_traits"

**症状：**
```
fatal error C1083: 无法打开包括文件: "type_traits": No such file or directory
```

**解决方案：**

1. **使用快捷键** (推荐)：
   ```
   <leader>qm  # 设置MSVC环境
   ```

2. **使用命令**：
   ```vim
   :QtSetupMsvc
   ```

3. **检查状态**：
   ```vim
   :QtCheckMsvc  # 或 <leader>qk
   ```

### 自动化解决方案

v1.3.0版本的构建脚本已经自动集成MSVC环境设置，正常情况下运行 `<leader>qb` 就会自动设置环境。

## 🛠️ 解决Clangd LSP问题

### 问题：Neovim中clangd无法正常工作

**症状：**
- LSP功能不可用
- 代码补全、跳转失效
- `:LspInfo` 显示clangd未连接

**原因：**
Qt Creator生成的 `compile_commands.json` 包含MSVC特有参数，与独立clangd不兼容。

**解决方案：**

1. **使用快捷键** (推荐)：
   ```
   <leader>ql  # 设置clangd配置
   ```

2. **使用命令**：
   ```vim
   :QtSetupClangd
   ```

3. **重启LSP**：
   ```vim
   :LspRestart
   ```

4. **检查状态**：
   ```vim
   :LspInfo
   ```

### 生成的配置

插件会创建 `.clangd` 配置文件：

```yaml
CompileFlags:
  Add:
    - -std=c++14
    - -DQT_WIDGETS_LIB
    - -DQT_GUI_LIB
    - -DQT_CORE_LIB
    - -DQT_SQL_LIB
    - -DQT_XML_LIB
    - -DUNICODE
    - -D_UNICODE
    - -DWIN32
    - -DWIN64
  Remove:
    - --driver-mode=*
    - /Zs
    - /TP
    - -nostdinc
    - -nostdinc++
    - /clang:*
    - -fms-compatibility-version=*
```

## ⌨️ 新的键盘映射系统

### 核心快捷键

| 功能 | 快捷键 | 命令 | 说明 |
|------|---------|------|------|
| 构建 | `<leader>qb` | `:QtBuild` | 编译项目 |
| 运行 | `<leader>qr` | `:QtRun` | 运行可执行文件 |
| 清理 | `<leader>qc` | `:QtClean` | 清理构建文件 |
| 调试 | `<leader>qd` | `:QtDebug` | 调试模式运行 |
| 测试 | `<leader>qt` | `:QtTest` | 运行测试 |

### 环境设置快捷键 (新功能)

| 功能 | 快捷键 | 命令 | 说明 |
|------|---------|------|------|
| MSVC环境 | `<leader>qm` | `:QtSetupMsvc` | 设置MSVC编译环境 |
| Clangd配置 | `<leader>ql` | `:QtSetupClangd` | 配置clangd LSP |
| 检查MSVC | `<leader>qk` | `:QtCheckMsvc` | 检查MSVC状态 |
| 修复.pro文件 | `<leader>qf` | `:QtFixPro` | 修复.pro文件的MSVC路径 |

### 脚本管理快捷键

| 功能 | 快捷键 | 命令 | 说明 |
|------|---------|------|------|
| 生成脚本 | `<leader>qg` | `:QtScripts` | 生成所有脚本 |
| 编辑脚本 | `<leader>qe` | - | 选择编辑脚本 |
| 显示状态 | `<leader>qs` | `:QtStatus` | 显示项目状态 |

## 🛠️ 解决.pro文件路径问题

### 问题：qmake项目编译时找不到头文件

**症状：**
- qmake项目在Windows下编译失败
- 缺少标准库头文件如 `<iostream>`, `<vector>` 等
- MSVC编译器找不到系统包含路径

**解决方案：**

1. **使用快捷键** (推荐)：
   ```
   <leader>qf  # 修复.pro文件
   ```

2. **使用命令**：
   ```vim
   :QtFixPro
   ```

### 自动添加的路径

插件会自动在.pro文件中添加以下Windows MSVC路径：

```pro
# Windows MSVC paths - added by qt-assistant
win32:INCLUDEPATH += $(VC_IncludePath)
win32:INCLUDEPATH += $(WindowsSdkDir)Include\$(WindowsSDKVersion)\ucrt
win32:INCLUDEPATH += $(WindowsSdkDir)Include\$(WindowsSDKVersion)\shared
win32:INCLUDEPATH += $(WindowsSdkDir)Include\$(WindowsSDKVersion)\um
win32:INCLUDEPATH += $(WindowsSdkDir)Include\$(WindowsSDKVersion)\winrt
```

### 智能检测

- 只有在Windows系统下才会添加这些路径
- 如果.pro文件已包含这些路径，不会重复添加
- 支持多个.pro文件的批量处理

## 🎯 自定义键盘映射

如果默认快捷键与你的配置冲突，可以自定义：

```lua
require('qt-assistant.core').setup_keymaps({
    build = "<F5>",              -- 使用F5构建
    run = "<F6>",                -- 使用F6运行
    setup_clangd = "<leader>lc", -- 自定义clangd设置
    setup_msvc = "<leader>mvc",  -- 自定义MSVC设置
    fix_pro = "<leader>fp",      -- 自定义.pro文件修复
})
```

## 📝 Which-key集成

如果你使用[which-key.nvim](https://github.com/folke/which-key.nvim)插件，Qt Assistant会自动集成：

- 按下 `<leader>q` 后会显示所有可用的Qt相关快捷键
- 每个快捷键都有详细的功能说明
- 支持层次化菜单浏览

## 🔍 故障排除

### 1. 快捷键不工作

**检查是否启用了键盘映射：**
```lua
-- 确保在setup后调用
require('qt-assistant.core').setup_keymaps()
```

### 2. MSVC环境设置失败

**检查Visual Studio安装：**
```vim
:QtCheckMsvc
```

**手动设置环境：**
```bash
# 在Windows命令行中
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
```

### 3. Clangd仍然不工作

**检查Neovim工作目录：**
```vim
:pwd
```
确保在项目根目录启动Neovim。

**检查.clangd文件：**
```vim
:e .clangd
```
确保文件存在且内容正确。

## 📚 更多资源

- [完整文档](../README.md)
- [键盘映射完整列表](../README.md#完整快捷键参考)
- [故障排除指南](../README.md#故障排除)
- [配置示例](../README.md#配置选项)

## 🎉 总结

Qt Assistant v1.3.0 专注于提升Windows用户的开发体验：

1. **解决编译问题** - 自动设置MSVC环境
2. **解决LSP问题** - 智能配置clangd
3. **提升效率** - 丰富的键盘快捷键
4. **降低门槛** - 一键式解决方案

现在你可以专注于Qt开发，而不用担心环境配置问题！