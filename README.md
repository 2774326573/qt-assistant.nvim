# Qt Assistant - Neovim Plugin for Qt Development

[![GitHub release](https://img.shields.io/github/v/release/onewu867/qt-assistant.nvim)](https://github.com/onewu867/qt-assistant.nvim/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/Lua-5.1+-blue.svg)](https://www.lua.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/onewu867/qt-assistant.nvim)

一个专为Qt C++开发设计的Neovim插件，提供快速类创建、智能文件管理、代码模板、项目脚本管理和Qt5/Qt6跨版本支持功能。

## 🚀 核心功能

- **Qt5/Qt6双版本支持** - 自动检测项目Qt版本，智能适配模板和构建配置
- **智能类创建** - 支持主窗口、对话框、数据模型、线程类等多种Qt类模板
- **项目管理** - 跨驱动器全局搜索、智能选择、快速切换Qt项目
- **构建系统** - 支持CMake、qmake、Meson多种构建系统，一键构建运行
- **开发环境** - MSVC/Clangd LSP配置，自动代码格式化，跨平台脚本生成
- **快捷键系统** - 40+快捷键，层次化设计，支持Which-key集成

## 📦 快速安装

<details>
<summary>💻 安装配置</summary>

### 使用 lazy.nvim
```lua
{
    '2774326573/qt-assistant.nvim',
    config = function()
        require('qt-assistant').setup({
            -- 基础配置
            project_root = vim.fn.getcwd(),
            naming_convention = "snake_case",
            auto_update_cmake = true,
            
            -- Qt版本配置
            qt_project = {
                version = "auto",
                qt5_path = "C:/Qt/5.15.2",  -- Windows用户可选
                qt6_path = "C:/Qt/6.5.0",   -- Windows用户可选
            },
            
            -- 自动格式化（默认启用）
            auto_format = {
                enabled = true,
                formatter = "clang_format",
                on_save = true,
            },
        })
        
        -- 设置快捷键
        require('qt-assistant.core').setup_keymaps()
    end
}
```

### 系统要求
- **通用**: Neovim 0.8+, Git, clang-format（推荐）
- **Windows**: Visual Studio Build Tools 2019+ 或 MinGW-w64, Qt5.12+/Qt6.2+
- **Linux**: GCC 7+/Clang 6+, qt6-base-dev, cmake
- **macOS**: Xcode Command Line Tools, Homebrew Qt

</details>

## 🎯 快速开始

<details>
<summary>🚀 基本使用</summary>

### 常用命令
```vim
# 项目管理
:QtSmartSelector      # 智能项目选择器
:QtQuickSwitcher      # 快速项目切换
:QtGlobalSearch       # 全局项目搜索

# 类创建
:QtCreateClass MainWindow main_window
:QtCreateClass LoginDialog dialog
:QtCreateClass UserModel model

# 构建运行
:QtBuild              # 构建项目
:QtRun                # 运行项目
:QtClean              # 清理项目

# 环境设置
:QtSetupClangd        # 设置clangd LSP
:QtSetupMsvc          # 设置MSVC环境（Windows）
:QtFixCompile         # 一键修复编译问题

# 脚本管理
:QtScripts            # 生成项目脚本
:QtScriptGenerator    # 交互式脚本生成器

# 代码格式化
:QtFormatFile         # 格式化当前文件
:QtFormatProject      # 格式化整个项目
```

### 核心快捷键
```
<leader>qtb  # 构建项目
<leader>qtr  # 运行项目
<leader>qtc  # 清理项目

<leader>qpo  # 智能项目选择
<leader>qpw  # 快速项目切换
<leader>qpg  # 全局项目搜索

<leader>qem  # 设置MSVC环境
<leader>qel  # 设置clangd LSP
<leader>qec  # 一键修复编译环境
```

### 支持的类类型
| 类型 | 描述 | 基类 | 生成文件 |
|------|------|------|----------|
| `main_window` | 主窗口类 | QMainWindow | .h, .cpp, .ui |
| `dialog` | 对话框类 | QDialog | .h, .cpp, .ui |
| `widget` | 自定义控件类 | QWidget | .h, .cpp |
| `model` | 数据模型类 | QAbstractItemModel | .h, .cpp |
| `delegate` | 代理类 | QStyledItemDelegate | .h, .cpp |
| `thread` | 线程类 | QThread | .h, .cpp |
| `utility` | 工具类 | QObject | .h, .cpp |
| `singleton` | 单例类 | QObject | .h, .cpp |

</details>

<details>
<summary>🚀 点击展开功能特性</summary>

### Qt版本支持
- **Qt5/Qt6双版本支持**: 自动检测项目Qt版本，支持Qt5和Qt6项目
- **智能版本检测**: 从CMakeLists.txt、.pro文件自动识别Qt版本
- **版本特定模板**: 根据检测的Qt版本选择合适的代码模板

### 核心功能
- **智能类创建**: 主窗口、对话框、数据模型、线程类等
- **项目管理**: 跨驱动器搜索、智能选择、快速切换
- **UI设计师集成**: Qt Designer自动启动和文件同步
- **构建管理**: 支持CMake、qmake、Meson多种构建系统

### 代码质量
- **自动格式化**: clang-format自动格式化C++代码
- **代码模板**: 丰富的内置模板库和自定义支持
- **CMake集成**: 自动更新CMakeLists.txt

### 开发环境
- **Clangd LSP**: 完整的语言服务器配置
- **MSVC环境**: Windows下自动设置编译环境
- **跨平台脚本**: 基于模板的健壮脚本系统

### 键盘映射
- **40+快捷键**: 层次化设计，易于记忆
- **Which-key集成**: 显示快捷键说明
- **自定义支持**: 灵活配置快捷键

</details>

<details>
<summary>🐧 系统要求</summary>

#### 通用要求
- Neovim 0.8+
- Git（用于项目管理）
- clang-format（推荐，用于代码格式化）

#### Windows 系统
- Visual Studio Build Tools 2019+ 或 MinGW-w64
- Qt5.12+ 或 Qt6.2+
- Qt bin目录已添加到PATH

#### Linux 系统
```bash
# Ubuntu/Debian
sudo apt install qt6-base-dev qt6-tools-dev cmake clang-format

# CentOS/RHEL/Fedora
sudo dnf install qt6-qtbase-devel qt6-qttools cmake clang-tools-extra
```

#### macOS 系统
```bash
# Xcode Command Line Tools
xcode-select --install

# Homebrew
brew install qt@6 cmake clang-format
```

</details>

<details>
<summary>🎥 快速开始 - 常用命令</summary>

#### 核心命令
```vim
# 项目管理
:QtSmartSelector    # 智能项目选择器
:QtQuickSwitcher    # 快速项目切换

# 构建运行
:QtBuild           # 构建项目
:QtRun             # 运行项目
:QtClean           # 清理项目

# 类创建
:QtCreateClass MainWindow main_window
:QtCreateClass LoginDialog dialog

# UI设计
:QtOpenDesigner mainwindow.ui
```

#### 环境设置
```vim
:QtSetupClangd     # 设置clangd LSP
:QtSetupMsvc       # 设置MSVC环境
:QtFixCompile      # 一键修复编译问题
:QtScripts         # 生成项目脚本
```

#### 代码格式化
```vim
:QtFormatFile      # 格式化当前文件
:QtFormatProject   # 格式化整个项目
```

</details>

<details>
<summary>⚙️ 配置选项</summary>

```lua
require('qt-assistant').setup({
    -- 项目根目录
    project_root = vim.fn.getcwd(),
    
    -- 目录结构配置
    directories = {
        source = "src",
        include = "include",
        ui = "ui",
        resource = "resource",
        scripts = "scripts"
    },
    
    -- 文件命名规范
    naming_convention = "snake_case", -- "snake_case" 或 "camelCase"
    
    -- 自动更新CMakeLists.txt
    auto_update_cmake = true,
    
    -- Qt项目配置
    qt_project = {
        version = "auto",
        qt5_path = "",
        qt6_path = "",
        auto_detect = true,
        build_type = "Debug",
        build_dir = "build",
        parallel_build = true,
        build_jobs = 4,
    },
    
    -- 代码格式化配置
    auto_format = {
        enabled = true,
        formatter = "clang_format",
        on_save = true,
    },
    
    -- 构建环境配置
    build_environment = {
        vs2017_path = "",
        vs2019_path = "",
        vs2022_path = "",
        prefer_vs_version = "2017",
        mingw_path = "",
        qt_version = "auto"
    },
    
    -- UI设计师配置
    designer = {
        designer_path = "designer",
        creator_path = "qtcreator",
        default_editor = "designer",
        auto_sync = true,
    },
    
    -- 调试配置
    debug = {
        enabled = false,
        log_level = "INFO",
    }
})
```

</details>

<details>
<summary>🎨 交互式界面</summary>

### 主要界面
- `:QtAssistant` - 类创建向导
- `:QtProjectManager` - 项目管理界面
- `:QtDesignerManager` - UI设计师管理
- `:QtBuildStatus` - 构建状态查看

### 交互流程
1. **类创建**: 选择类型 → 输入名称 → 配置选项 → 生成文件
2. **项目管理**: 查看信息 → 选择/创建项目 → 执行操作
3. **UI设计**: 查看UI文件 → 选择编辑器 → 打开编辑

</details>

<details>
<summary>🔧 脚本管理系统</summary>

### 支持的脚本类型
- **build** - 构建脚本（CMake/qmake/Make）
- **run** - 运行脚本（智能查找可执行文件）
- **debug** - 调试脚本（gdb/lldb/VS）
- **clean** - 清理脚本
- **test** - 测试脚本
- **deploy** - 部署脚本

### 快速生成
```vim
:QtGenerateAllScripts  # 一键生成所有脚本
:QtScriptGenerator     # 交互式生成器
```

### 特性
- 自动检测项目信息（名称、Qt版本、构建系统）
- 健壮的错误处理和相对路径导航
- 支持并行编译和智能文件查找
- 模板变量替换（`{{PROJECT_NAME}}`、`{{QT_VERSION}}`）

</details>

<details>
<summary>📚 模板系统</summary>

### 内置模板功能
- 变量替换: `{{CLASS_NAME}}`、`{{FILE_NAME}}`等
- 条件语句: `{{#INCLUDE_UI}}...{{/INCLUDE_UI}}`
- 自动生成基础代码结构

### 自定义模板
可在配置的模板路径下创建自定义模板文件。

</details>

<details>
<summary>🎹 快捷键映射</summary>

### 核心快捷键（必记）
```
<leader>qtb  # 构建项目
<leader>qtr  # 运行项目  
<leader>qtc  # 清理项目
<leader>qtd  # 调试项目
```

### 环境设置
```
<leader>qem  # 设置MSVC环境
<leader>qel  # 设置clangd LSP
<leader>qec  # 一键修复编译环境
```

### 项目管理
```
<leader>qpo  # 智能项目选择
<leader>qpw  # 快速项目切换
<leader>qpg  # 全局项目搜索
```

### 设置方法
```lua
-- 基础设置
require('qt-assistant.core').setup_keymaps()

-- 自定义快捷键
require('qt-assistant.core').setup_keymaps({
    build = "<F5>",
    run = "<F6>",
})
```

### Which-key集成
自动检测并集成Which-key插件，显示快捷键说明。

</details>

<details>
<summary>🐛 故障排除</summary>

### 常见问题快速解决

**1. 配置错误**
```lua
-- 正确配置方式
require('qt-assistant').setup({})
-- 清除缓存
:lua package.loaded['qt-assistant'] = nil
```

**2. Windows MSVC编译错误**
```vim
:QtSetupMsvc      # 设置MSVC环境
:QtFixCompile     # 一键修复编译问题
:QtCheckMsvc      # 检查MSVC状态
```

**3. Clangd LSP问题**
```vim
:QtSetupClangd    # 设置clangd配置
:LspRestart       # 重启语言服务器
:LspInfo          # 检查LSP状态
```

**4. 代码格式化问题**
```vim
:QtFormatterStatus     # 查看格式化工具状态
:QtCreateClangFormat   # 创建.clang-format配置
```

**5. UI设计师无法启动**
```vim
:QtDesignerManager     # 检查设计师状态
# 确保Qt bin目录在PATH中
```

### 调试模式
```lua
require('qt-assistant').setup({
    debug = {
        enabled = true,
        log_level = "DEBUG"
    }
})
```

### 日志查看
```vim
:e ~/.local/share/nvim/qt-assistant.log
```

</details>

<details>
<summary>🤝 贡献</summary>

欢迎提交Issue和Pull Request！

### 开发环境设置
1. Fork这个仓库
2. 克隆到本地
3. 在Neovim配置中添加本地路径
4. 进行修改和测试

### 代码规范
- 使用Lua标准代码风格
- 添加适当的注释
- 保持模块化设计

</details>

## 📄 许可证

MIT License

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者。

---

**注意**: 这个插件专为Qt C++开发设计，支持CMake、qmake等多种构建系统，对Qt5和Qt6项目均可获得最佳体验。对Windows用户的MSVC环境支持特别优化。