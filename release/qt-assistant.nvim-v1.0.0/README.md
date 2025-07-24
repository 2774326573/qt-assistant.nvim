# Qt Assistant - Neovim Plugin for Qt Development

[![GitHub release](https://img.shields.io/github/v/release/onewu867/qt-assistant.nvim)](https://github.com/onewu867/qt-assistant.nvim/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/Lua-5.1+-blue.svg)](https://www.lua.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/onewu867/qt-assistant.nvim)

一个专为Qt C++开发设计的Neovim插件，提供快速类创建、智能文件管理、代码模板和项目脚本管理功能。

## 🚀 功能特性

### 类创建功能
- **UI界面类**: 主窗口、对话框、自定义控件
- **数据模型类**: 继承自QAbstractItemModel的数据模型
- **代理类**: QStyledItemDelegate代理类
- **线程类**: QThread线程类  
- **工具类**: 静态方法类、单例模式类

### 项目管理功能
- **项目检测**: 自动识别CMake、qmake、Meson等构建系统
- **项目模板**: Widget应用、Quick应用、控制台应用、库项目
- **项目结构分析**: 智能识别源码、头文件、UI文件目录
- **项目快速切换**: 支持多项目开发环境

### UI设计师集成
- **Qt Designer集成**: 自动启动Qt Designer编辑UI文件
- **UI文件管理**: 智能检测和预览UI文件结构
- **文件同步**: UI文件与源码文件的智能同步
- **多编辑器支持**: 支持Qt Designer、Qt Creator和自定义编辑器

### 构建管理系统
- **多构建系统**: 支持CMake、qmake、Meson构建系统
- **智能构建**: 自动检测构建配置，支持并行构建
- **一键运行**: 构建完成后自动查找并运行可执行文件
- **构建状态**: 实时显示构建状态和错误信息

### 智能文件管理
- 根据类类型自动选择目标目录
- 支持自定义目录结构
- 智能文件命名规范（驼峰/下划线）
- 自动生成头文件保护宏

### 代码模板系统
- 丰富的内置模板库
- 项目模板支持（Widget、Quick、Console、Library）
- 变量替换和条件语句支持
- 自动生成基础代码结构

### CMake集成
- 自动更新CMakeLists.txt
- 智能添加源文件和头文件
- UI文件自动处理

### 项目脚本管理
- **跨平台脚本**: 根据系统自动生成对应格式的脚本
  - Linux/macOS: `build.sh`, `clean.sh`, `run.sh`, `debug.sh`, `test.sh`
  - Windows: `build.bat`, `clean.bat`, `run.bat`, `debug.bat`, `test.bat`
- **智能脚本内容**: 脚本内容根据系统差异自动适配

## 🌍 多系统支持

Qt Assistant 支持跨平台使用，提供对以下操作系统的完整支持：

### 支持的系统
- **Windows** - 支持 Windows 10 及更高版本
- **macOS** - 支持 macOS 10.15 及更高版本  
- **Linux** - 支持大多数主流发行版

### 系统特性
- **智能路径处理**: 自动适配不同系统的路径分隔符 (`\` vs `/`)
- **跨平台脚本**: 根据系统自动生成对应的脚本文件 (`.bat` vs `.sh`)
- **Qt工具检测**: 智能查找各系统中的Qt Designer、Qt Creator等工具
- **构建系统适配**: 自动适配不同系统的构建命令和可执行文件格式

### 系统信息查看
使用 `:QtSystemInfo` 命令查看当前系统信息：
```vim
:QtSystemInfo
```

## 📦 安装

### 使用 lazy.nvim

```lua
{
    '2774326573/qt-assistant.nvim',
    config = function()
        require('qt-assistant').setup({
            -- 配置选项
            project_root = vim.fn.getcwd(),
            naming_convention = "snake_case", -- 或 "camelCase"
            auto_update_cmake = true,
            generate_comments = true,
        })
    end
}
```

### 使用 packer.nvim

```lua
use {
    '2774326573/qt-assistant.nvim',
    config = function()
        require('qt-assistant').setup()
    end
}
```

## 🎯 使用方法

### 命令行界面

#### 创建Qt类
```vim
:QtCreateClass MainWindow main_window
:QtCreateClass LoginDialog dialog  
:QtCreateClass CustomButton widget
:QtCreateClass UserModel model
```

#### 创建UI文件
```vim
:QtCreateUI MainWindow main_window
:QtCreateUI LoginDialog dialog
```

#### 创建数据模型
```vim
:QtCreateModel UserModel
:QtCreateModel ProductModel
```

#### 项目管理
```vim
:QtOpenProject /path/to/project
:QtNewProject MyApp widget_app
:QtBuildProject Debug
:QtRunProject
:QtCleanProject
```

#### UI设计师
```vim
:QtOpenDesigner mainwindow.ui
:QtOpenDesignerCurrent
:QtPreviewUI
:QtSyncUI
```

#### 运行项目脚本
```vim
:QtScript build
:QtScript clean
:QtScript run
:QtScript debug
```

#### 系统信息
```vim
:QtSystemInfo
```

#### 交互式界面
```vim
:QtAssistant
:QtProjectManager
:QtDesignerManager
:QtBuildStatus
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

## ⚙️ 配置选项

```lua
require('qt-assistant').setup({
    -- 项目根目录
    project_root = vim.fn.getcwd(),
    
    -- 目录结构配置
    directories = {
        source = "src",           -- 源文件目录
        include = "include",      -- 头文件目录
        ui = "ui",               -- UI文件目录
        resource = "resource",    -- 资源文件目录
        scripts = "scripts"       -- 脚本目录
    },
    
    -- 文件命名规范
    naming_convention = "snake_case", -- "snake_case" 或 "camelCase"
    
    -- 自动更新CMakeLists.txt
    auto_update_cmake = true,
    
    -- 生成注释
    generate_comments = true,
    
    -- 模板路径（可选）
    template_path = vim.fn.stdpath('config') .. '/qt-templates',
    
    -- Qt项目配置
    qt_project = {
        auto_detect = true,
        build_type = "Debug",
        build_dir = "build", 
        parallel_build = true,
        build_jobs = 4
    },
    
    -- UI设计师配置
    designer = {
        designer_path = "designer",
        creator_path = "qtcreator", 
        default_editor = "designer",
        auto_sync = true,
        enable_preview = true,
        -- 自定义编辑器配置
        custom_editor = {
            command = "",           -- 自定义编辑器命令
            args = {"{file}"}       -- 命令参数，{file}会被替换为UI文件路径
        }
    },
    
    -- 调试配置
    debug = {
        enabled = false,
        log_level = "INFO",
        log_file = vim.fn.stdpath('data') .. '/qt-assistant.log'
    }
})
```

## 📁 项目结构

插件会根据类类型自动组织文件结构：

```
project/
├── src/
│   ├── ui/          # UI相关源文件
│   ├── core/        # 核心业务逻辑
│   └── utils/       # 工具类
├── include/
│   ├── ui/          # UI相关头文件
│   ├── core/        # 核心头文件
│   └── utils/       # 工具类头文件
├── ui/              # Qt Designer UI文件
├── scripts/         # 项目脚本
│   ├── build.sh
│   ├── clean.sh
│   ├── run.sh
│   ├── debug.sh
│   └── test.sh
└── CMakeLists.txt
```

## 🎨 交互式界面

使用插件提供的多种交互式界面：

### 类创建界面
`:QtAssistant` - 打开类创建向导：
1. 选择类类型
2. 输入类名  
3. 配置选项（生成UI文件、添加到CMake等）
4. 创建类并可选择打开生成的文件

### 项目管理界面  
`:QtProjectManager` - 打开项目管理界面：
1. 查看当前项目信息
2. 打开或创建新项目
3. 管理项目模板
4. 执行构建和运行操作

### UI设计师界面
`:QtDesignerManager` - 打开UI设计师管理界面：
1. 查看项目中所有UI文件
2. 检查可用的UI编辑器状态
3. 快速打开UI文件进行编辑
4. 预览和同步UI文件

### 构建状态界面
`:QtBuildStatus` - 查看构建状态：
1. 显示当前构建系统信息
2. 查看构建目录和可执行文件状态
3. 执行构建、运行、清理操作

## 🔧 脚本管理

### 初始化脚本
```vim
:lua require('qt-assistant.scripts').init_scripts_directory()
```

### 查看脚本状态
```vim
:lua require('qt-assistant.scripts').show_script_status()
```

### 编辑脚本
```vim
:lua require('qt-assistant.scripts').edit_script('build')
```

## 📚 模板系统

插件包含丰富的内置模板，支持：

- 变量替换: `{{CLASS_NAME}}`, `{{FILE_NAME}}`等
- 条件语句: `{{#INCLUDE_UI}}...{{/INCLUDE_UI}}`
- 自动生成基础代码结构

### 自定义模板

可以在配置的模板路径下创建自定义模板文件。

## 🎹 快捷键映射

插件提供了丰富的快捷键映射，使用 `:QtKeymaps` 查看完整列表：

### 基础操作
- `<leader>qc` - 打开Qt Assistant
- `<leader>qh` - 显示帮助

### 项目管理
- `<leader>qpo` - 打开项目
- `<leader>qpm` - 项目管理器
- `<leader>qpt` - 列出项目模板

### 构建管理
- `<leader>qb` - 构建项目
- `<leader>qr` - 运行项目
- `<leader>qcl` - 清理项目
- `<leader>qbs` - 构建状态

### UI设计师
- `<leader>qud` - 打开Qt Designer
- `<leader>quc` - 打开当前文件的Designer
- `<leader>qup` - 预览UI文件
- `<leader>qum` - UI设计师管理器

### 脚本管理
- `<leader>qsb` - 脚本构建
- `<leader>qsr` - 脚本运行
- `<leader>qsd` - 脚本调试
- `<leader>qsm` - 脚本管理器

### 组合操作
- `<leader>qbr` - 构建并运行
- `<leader>qcb` - 清理并构建

**注意**: `<leader>` 通常是 `\` 键，可以通过 `let mapleader = ","` 来自定义。

## 🐛 故障排除

### 常见问题

1. **配置函数不存在错误** (v1.0.0新增)
   ```
   Failed to run `config` for qt-assistant.nvim
   attempt to call field 'setup' (a nil value)
   ```
   - 确保使用正确的配置方式：`require('qt-assistant').setup({})`
   - 检查插件是否正确安装和加载
   - 清除Lua模块缓存：`:lua package.loaded['qt-assistant'] = nil`
   - 查看详细故障排除：[配置故障排除指南](docs/CONFIGURATION_TROUBLESHOOTING.md)

2. **CMakeLists.txt未更新**
   - 确保 `auto_update_cmake = true`
   - 检查CMakeLists.txt文件权限

3. **脚本无法执行**
   - 运行 `:QtInitScripts` 创建默认脚本
   - 检查脚本文件执行权限

4. **UI设计师无法启动**
   - 检查Qt Designer是否已安装
   - 配置正确的 `designer_path`
   - 使用 `:QtDesignerManager` 检查编辑器状态
   - Windows用户确保Qt bin目录在PATH中

5. **项目检测失败**
   - 确保项目包含CMakeLists.txt或.pro文件
   - 使用 `:QtOpenProject` 手动指定项目路径

6. **构建失败**
   - 检查构建依赖是否安装
   - 使用 `:QtBuildStatus` 查看详细状态
   - 启用调试日志查看错误信息
   - Windows用户确保已安装MSVC或MinGW编译器

7. **跨平台问题**
   - 使用 `:QtSystemInfo` 查看系统检测结果
   - 检查路径分隔符是否正确适配
   - 确认脚本文件格式正确（Unix使用.sh，Windows使用.bat）

### 调试信息

启用插件调试模式：
```lua
require('qt-assistant').setup({
    debug = {
        enabled = true,
        log_level = "DEBUG"
    }
})
```

查看日志文件：
```vim
:e ~/.local/share/nvim/qt-assistant.log
```

## 🤝 贡献

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

## 📄 许可证

MIT License

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者。

---

**注意**: 这个插件专为Qt C++开发设计，确保你的项目使用CMake构建系统以获得最佳体验。
