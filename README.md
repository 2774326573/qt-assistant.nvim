# Qt Assistant - Neovim Plugin for Qt Development

[![GitHub release](https://img.shields.io/github/v/release/onewu867/qt-assistant.nvim)](https://github.com/onewu867/qt-assistant.nvim/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/Lua-5.1+-blue.svg)](https://www.lua.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/onewu867/qt-assistant.nvim)

## 目录

- [功能特性](#功能特性)
- [安装](#安装)
- [使用方法](#使用方法)
- [支持的类类型](#支持的类类型)
- [配置选项](#配置选项)
- [项目结构](#项目结构)
- [交互式界面](#交互式界面)
- [脚本管理系统](#脚本管理系统)
- [模板系统](#模板系统)
- [快捷键映射](#快捷键映射)
- [完整快捷键参考](#完整快捷键参考)
- [故障排除](#故障排除)
- [贡献](#贡献)
- [许可证](#许可证)
- [致谢](#致谢)
- [版本更新说明](#版本更新说明)

一个专为Qt C++开发设计的Neovim插件，提供快速类创建、智能文件管理、代码模板、项目脚本管理和Qt5/Qt6跨版本支持功能。

## 🆕 v1.3.0 更新 (2025-07-26)

**重大功能更新**：

- ✅ **Windows MSVC环境修复**: 解决了Windows下编译缺少标准库头文件的问题
- ✅ **Clangd LSP支持**: 新增完整的clangd语言服务器配置支持
- ✅ **键盘映射系统**: 全新的键盘快捷键系统，支持自定义和Which-key集成
- ✅ **MSVC自动环境设置**: 构建脚本自动设置MSVC编译环境
- ✅ **增强的Windows脚本**: 改进Windows批处理脚本的路径处理和错误处理
- ✅ **.pro文件修复**: 自动添加Windows MSVC编译所需的系统路径

**新增功能**：

- 🔧 **setup-clangd.bat**: 自动生成适合Neovim的clangd配置文件
- 🛠️ **fix-pro.bat**: 智能修复.pro文件的Windows MSVC路径问题
- ⌨️ **丰富的快捷键**: 40+个快捷键覆盖所有功能模块
- 🎯 **智能命令**: 新增20+个Vim命令，如`:QtSetupClangd`、`:QtSetupMsvc`、`:QtFixPro`等
- 📝 **Which-key集成**: 支持Which-key插件显示快捷键说明

**推荐升级**: 此版本大幅提升Windows用户体验，强烈建议所有用户升级。

📚 **详细信息**: 查看 [修复日志](docs/BUGFIX_CHANGELOG_v1.3.0.md) 和 [快捷键参考](#完整快捷键参考)

## 🚀 功能特性

### Qt版本支持

- **Qt5/Qt6双版本支持**: 自动检测项目Qt版本，支持Qt5和Qt6项目
- **智能版本检测**: 从CMakeLists.txt、.pro文件自动识别Qt版本
- **Windows路径检测**: Windows系统自动检测Qt5/Qt6安装路径
- **版本特定模板**: 根据检测的Qt版本选择合适的代码模板
- **构建系统适配**: 自动适配不同Qt版本的构建参数和依赖

### 类创建功能

- **UI界面类**: 主窗口、对话框、自定义控件
- **数据模型类**: 继承自QAbstractItemModel的数据模型
- **代理类**: QStyledItemDelegate代理类
- **线程类**: QThread线程类
- **工具类**: 静态方法类、单例模式类

### 项目管理功能

- **智能项目搜索**: 跨驱动器全局搜索Qt项目，支持智能选择和快速切换
- **项目检测**: 自动识别CMake、qmake、Qbs、Meson等构建系统
- **项目模板**: Widget应用、Quick应用、控制台应用、库项目
- **项目结构分析**: 智能识别源码、头文件、UI文件目录
- **快速项目切换**: 支持最近项目列表和一键切换功能

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

### 代码格式化

- **多格式化工具支持**: clang-format（推荐）、astyle
- **自动格式化**: 默认启用，保存时自动格式化C++文件
- **智能检测**: 自动检测可用的格式化工具
- **项目级配置**: 支持创建.clang-format配置文件
- **批量格式化**: 支持格式化整个项目或指定目录

### 项目脚本管理

- **基于项目模板的脚本系统**: 从实际项目脚本提取最佳实践
- **跨平台脚本生成**: 根据系统自动生成对应格式的脚本
  - Linux/macOS: `build.sh`, `clean.sh`, `run.sh`, `debug.sh`, `test.sh`, `deploy.sh`
  - Windows: `build.bat`, `clean.bat`, `run.bat`, `debug.bat`, `test.bat`, `deploy.bat`, `setup-msvc.bat`, `setup-clangd.bat`
- **智能脚本内容**: 脚本内容根据系统差异和Qt版本自动适配
- **项目信息自动检测**: 自动检测项目名称、Qt版本、构建系统
- **健壮的错误处理**: 失败时立即退出，避免连锁错误
- **交互式脚本生成器**: 支持选择性生成和一键生成所有脚本
- **MSVC环境集成**: Windows脚本自动设置MSVC编译环境
- **Clangd LSP支持**: 自动生成适合Neovim的clangd配置

### 开发环境集成

- **Clangd语言服务器**: 完整的clangd配置支持，解决Qt Creator兼容性问题
- **MSVC编译环境**: 自动检测和设置Visual Studio编译环境
- **智能路径处理**: 解决Windows下中文路径和编译器路径问题
- **LSP配置优化**: 自动生成`.clangd`配置文件，过滤不兼容的编译器标志
- **编译数据库**: 支持生成标准的compile_commands.json文件

### 键盘映射系统

- **40+快捷键**: 覆盖所有功能模块的完整快捷键系统
- **层次化设计**: 采用助记符设计，易于记忆和使用
- **自定义支持**: 支持用户自定义快捷键映射
- **Which-key集成**: 与Which-key插件无缝集成，显示快捷键说明
- **智能命令**: 20+个Vim命令，提供完整的命令行接口

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
            -- Qt版本配置（Windows用户）
            qt_project = {
                version = "auto",  -- "auto", "Qt5", "Qt6"
                qt5_path = "C:/Qt/5.15.2",  -- Windows Qt5安装路径（可选）
                qt6_path = "C:/Qt/6.5.0",   -- Windows Qt6安装路径（可选）
            },
            -- 代码格式化配置（默认启用）
            auto_format = {
                enabled = true,              -- 启用自动格式化
                formatter = "clang_format",  -- 首选格式化工具
                on_save = true,              -- 保存时自动格式化
            },
        })
        
        -- 设置键盘映射（可选）
        require('qt-assistant.core').setup_keymaps()
    end
}
```

### 使用 packer.nvim

```lua
use {
    '2774326573/qt-assistant.nvim',
    config = function()
        require('qt-assistant').setup({
            -- Windows用户建议配置Qt路径以获得更好的检测效果
            qt_project = {
                version = "auto",
                qt5_path = "C:/Qt/5.15.2",  -- 根据实际安装路径调整
                qt6_path = "C:/Qt/6.5.0",   -- 根据实际安装路径调整
            },
            -- 自动格式化默认启用，如需关闭可设置为false
            auto_format = {
                enabled = true,
                formatter = "clang_format",
            },
        })
    end
}
```

### 系统要求

#### 通用要求

- Neovim 0.8+
- Git（用于项目管理和全局搜索）
- **clang-format**（推荐，用于自动代码格式化）

#### Windows 系统额外要求

- **构建工具**: Visual Studio Build Tools 2019+ 或 MinGW-w64
- **Qt安装**: Qt5.12+ 或 Qt6.2+，推荐使用Qt在线安装器
- **PATH配置**: 确保Qt bin目录已添加到系统PATH中

  ```batch
  # 示例PATH配置
  C:\Qt\5.15.2\msvc2019_64\bin
  C:\Qt\6.5.0\msvc2019_64\bin
  ```

- **代码格式化工具**（推荐安装，插件默认启用自动格式化）:

  ```batch
  # 使用 winget（推荐）
  winget install LLVM.LLVM

  # 或者从官网下载安装
  # https://releases.llvm.org/download.html
  ```

#### Linux 系统额外要求

- **构建工具**: GCC 7+ 或 Clang 6+
- **Qt安装**:

  ```bash
  # Ubuntu/Debian
  sudo apt install qt5-default qtcreator qt5-qmake cmake
  # 或者 Qt6
  sudo apt install qt6-base-dev qt6-tools-dev cmake

  # CentOS/RHEL/Fedora
  sudo dnf install qt5-qtbase-devel qt5-qttools cmake
  # 或者 Qt6
  sudo dnf install qt6-qtbase-devel qt6-qttools cmake
  ```

- **代码格式化工具**（推荐安装，插件默认启用自动格式化）:

  ```bash
  # Ubuntu/Debian
  sudo apt install clang-format

  # CentOS/RHEL/Fedora
  sudo dnf install clang-tools-extra
  ```

#### macOS 系统额外要求

- **Xcode Command Line Tools**: `xcode-select --install`
- **Qt安装**:

  ```bash
  # 使用 Homebrew
  brew install qt@5 cmake
  # 或者 Qt6
  brew install qt@6 cmake
  ```

- **代码格式化工具**（推荐安装，插件默认启用自动格式化）:

  ```bash
  # 使用 Homebrew
  brew install clang-format
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
:QtSmartSelector    # 智能项目选择器（自动打开）
:QtChooseProject    # 项目手动选择
:QtQuickSwitcher    # 快速项目切换器（最近项目）
:QtGlobalSearch     # 全局搜索所有驱动器中的Qt项目
:QtSearchProjects   # 本地搜索Qt项目
:QtRecentProjects   # 显示最近项目
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
:QtBuild               # 构建项目
:QtRun                 # 运行项目
:QtClean               # 清理项目
:QtDebug               # 调试项目
:QtTest                # 运行测试

# 环境设置（新增）
:QtSetupClangd         # 设置clangd语言服务器
:QtSetupMsvc           # 设置MSVC编译环境
:QtCheckMsvc           # 检查MSVC状态
:QtFixPro              # 修复.pro文件的Windows MSVC路径

# 脚本管理
:QtScripts             # 生成所有脚本
:QtStatus              # 显示项目状态
:QtScriptGenerator     # 交互式脚本生成器
:QtDetectBuildSystem   # 检测项目构建系统
```

#### 代码格式化

```vim
:QtFormatFile         # 格式化当前文件
:QtFormatProject      # 格式化整个项目
:QtFormatterStatus    # 查看格式化工具状态
:QtCreateClangFormat  # 创建.clang-format配置文件

# 指定格式化工具（可选）
:QtFormatFile clang_format
:QtFormatProject astyle
```

#### Qt版本和系统信息

```vim
:QtSystemInfo         # 系统信息
:QtVersionInfo        # Qt版本信息
:QtDetectVersion      # 检测Qt版本
```

#### 交互式界面

```vim
:QtAssistant
:QtProjectManager
:QtDesignerManager
:QtBuildStatus
```

### 支持的类类型

| 类型          | 描述         | 基类                | 生成文件      |
| ------------- | ------------ | ------------------- | ------------- |
| `main_window` | 主窗口类     | QMainWindow         | .h, .cpp, .ui |
| `dialog`      | 对话框类     | QDialog             | .h, .cpp, .ui |
| `widget`      | 自定义控件类 | QWidget             | .h, .cpp      |
| `model`       | 数据模型类   | QAbstractItemModel  | .h, .cpp      |
| `delegate`    | 代理类       | QStyledItemDelegate | .h, .cpp      |
| `thread`      | 线程类       | QThread             | .h, .cpp      |
| `utility`     | 工具类       | QObject             | .h, .cpp      |
| `singleton`   | 单例类       | QObject             | .h, .cpp      |

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
        version = "auto",              -- "auto", "Qt5", "Qt6"
        qt5_path = "",                 -- Windows Qt5 安装路径
        qt6_path = "",                 -- Windows Qt6 安装路径
        auto_detect = true,
        build_type = "Debug",
        build_dir = "build",
        parallel_build = true,
        build_jobs = 4,
        cmake_minimum_version = "3.5", -- Qt5兼容
        cxx_standard = "14"             -- Qt5兼容，根据检测版本自动更新
    },

    -- 代码格式化配置
    auto_format = {
        enabled = true,              -- 启用自动格式化（默认）
        formatter = "clang_format",  -- 首选格式化工具
        on_save = true,              -- 保存时自动格式化
    },

    -- 全局搜索配置
    global_search = {
        enabled = true,                    -- 启用全局搜索
        max_depth = 3,                     -- 最大搜索深度
        include_system_paths = true,       -- 包含系统路径
        custom_search_paths = {},          -- 自定义搜索路径
        exclude_patterns = {               -- 排除模式
            "node_modules", ".git", ".vscode",
            "build", "target", "dist", "out"
        }
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
│   ├── build.sh     # 构建脚本
│   ├── clean.sh     # 清理脚本
│   ├── run.sh       # 运行脚本
│   ├── debug.sh     # 调试脚本
│   ├── test.sh      # 测试脚本
│   └── deploy.sh    # 部署脚本
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

## 🔧 脚本管理系统

### 基于项目模板的脚本生成

插件现在基于实际项目脚本作为模板，提供更实用和健壮的脚本生成功能。

#### 支持的脚本类型

- **build** - 构建脚本（支持CMake、qmake、Make）
- **run** - 运行脚本（智能查找可执行文件）
- **debug** - 调试脚本（gdb/lldb/Visual Studio）
- **clean** - 清理脚本（删除构建文件）
- **test** - 测试脚本（ctest、自定义测试）
- **deploy** - 部署脚本（windeployqt、自定义部署）

#### 快速脚本生成

```vim
# 一键生成所有脚本
:QtGenerateAllScripts

# 交互式脚本生成器
:QtScriptGenerator

# 生成单个脚本
:lua require('qt-assistant').generate_single_script('build')
```

#### 脚本特性

- **项目信息自动检测**: 自动识别项目名称、Qt版本
- **构建系统检测**: 支持CMake、qmake、Makefile
- **健壮的错误处理**: 使用 `|| exit 1` 模式，失败时立即退出
- **相对路径导航**: 使用 `cd "$(dirname "$0")/.."` 确保正确的工作目录
- **智能可执行文件查找**: 支持多种可执行文件位置模式
- **并行编译支持**: 自动使用系统最大核心数进行编译

#### 模板变量替换

脚本模板支持以下变量：

- `{{PROJECT_NAME}}` - 项目名称（从CMakeLists.txt或目录名检测）
- `{{QT_VERSION}}` - Qt版本号（5或6）

#### 脚本管理命令

```vim
# 初始化脚本目录
:lua require('qt-assistant.scripts').init_scripts_directory()

# 查看可用脚本
:lua require('qt-assistant').list_scripts()

# 编辑脚本
:lua require('qt-assistant').edit_script('build')

# 检测构建系统
:QtDetectBuildSystem
```

## 📚 模板系统

插件包含丰富的内置模板，支持：

- 变量替换: `{{CLASS_NAME}}`, `{{FILE_NAME}}`等
- 条件语句: `{{#INCLUDE_UI}}...{{/INCLUDE_UI}}`
- 自动生成基础代码结构

### 自定义模板

可以在配置的模板路径下创建自定义模板文件。

## 🎹 快捷键映射

插件提供了丰富的快捷键映射系统，支持自定义和Which-key集成：

### 快速开始

**核心快捷键 (必记)**:

- `<leader>qb` - 构建项目 (`:QtBuild`)
- `<leader>qr` - 运行项目 (`:QtRun`)
- `<leader>qc` - 清理项目 (`:QtClean`)
- `<leader>qd` - 调试项目 (`:QtDebug`)
- `<leader>qt` - 运行测试 (`:QtTest`)

**环境设置 (新功能)**:

- `<leader>qm` - 设置MSVC环境 (`:QtSetupMsvc`)
- `<leader>ql` - 设置clangd LSP (`:QtSetupClangd`)
- `<leader>qk` - 检查MSVC状态 (`:QtCheckMsvc`)
- `<leader>qf` - 修复.pro文件 (`:QtFixPro`)

**脚本管理**:

- `<leader>qg` - 生成所有脚本 (`:QtScripts`)
- `<leader>qe` - 编辑脚本
- `<leader>qs` - 显示状态 (`:QtStatus`)

**UI设计师**:

- `<leader>qu` - 打开Qt Designer (`:QtDesigner`)

**项目管理**:

- `<leader>qi` - 初始化项目
- `<leader>qo` - 选择项目

### 键盘映射设置

**基础设置（自动启用所有默认快捷键）**:

```lua
require('qt-assistant.core').setup_keymaps()
```

**自定义快捷键**:

```lua
require('qt-assistant.core').setup_keymaps({
    build = "<F5>",     -- 自定义构建快捷键
    run = "<F6>",       -- 自定义运行快捷键
    setup_clangd = "<leader>lc",  -- 自定义clangd设置
})
```

**Which-key集成**:

如果你使用Which-key插件，键盘映射会自动显示说明。插件会自动检测并集成Which-key。

### 默认快捷键完整列表

| 快捷键 | 功能 | 命令 | 描述 |
|--------|------|------|------|
| `<leader>qb` | 构建项目 | `:QtBuild` | 构建当前Qt项目 |
| `<leader>qr` | 运行项目 | `:QtRun` | 运行编译后的可执行文件 |
| `<leader>qc` | 清理项目 | `:QtClean` | 清理构建文件 |
| `<leader>qd` | 调试项目 | `:QtDebug` | 使用调试器运行项目 |
| `<leader>qt` | 运行测试 | `:QtTest` | 执行项目测试 |
| `<leader>qp` | 部署项目 | `:QtDeploy` | 部署项目文件 |
| `<leader>qm` | 设置MSVC | `:QtSetupMsvc` | 设置MSVC编译环境 |
| `<leader>ql` | 设置Clangd | `:QtSetupClangd` | 配置clangd语言服务器 |
| `<leader>qk` | 检查MSVC | `:QtCheckMsvc` | 检查MSVC环境状态 |
| `<leader>qg` | 生成脚本 | `:QtScripts` | 生成所有项目脚本 |
| `<leader>qe` | 编辑脚本 | - | 选择并编辑脚本文件 |
| `<leader>qs` | 显示状态 | `:QtStatus` | 显示项目和脚本状态 |
| `<leader>qu` | Qt Designer | `:QtDesigner` | 打开当前UI文件 |
| `<leader>qi` | 初始化项目 | - | 初始化新的Qt项目 |
| `<leader>qo` | 选择项目 | - | 项目选择器 |

**注意**: 
- `<leader>` 默认是 `\` 键，可通过 `let mapleader = ","` 自定义
- 所有快捷键都有对应的命令形式
- 支持在终端中运行，提供实时输出

## 📋 完整快捷键参考

### 基础操作

| 快捷键       | 功能                | 对应命令             |
| ------------ | ------------------- | -------------------- |
| `<leader>qC` | Qt Assistant 主界面 | `:QtAssistant`       |
| `<leader>qh` | 显示帮助信息        | `:help qt-assistant` |

### 项目管理快捷键

#### 核心操作

| 快捷键        | 功能                | 对应命令            | 推荐度 |
| ------------- | ------------------- | ------------------- | ------ |
| `<leader>qpo` | 智能打开项目 (自动) | `:QtSmartSelector`  | ⭐⭐⭐ |
| `<leader>qpm` | 项目管理器          | `:QtProjectManager` | ⭐⭐   |

#### 项目选择/切换

| 快捷键        | 功能            | 对应命令            | 推荐度   |
| ------------- | --------------- | ------------------- | -------- |
| `<leader>qpc` | 选择项目 (手动) | `:QtChooseProject`  | ⭐⭐     |
| `<leader>qpw` | 快速项目切换器  | `:QtQuickSwitcher`  | ⚡⭐⭐⭐ |
| `<leader>qpr` | 最近项目        | `:QtRecentProjects` | ⭐⭐     |

#### 项目搜索

| 快捷键        | 功能               | 对应命令            | 推荐度   |
| ------------- | ------------------ | ------------------- | -------- |
| `<leader>qps` | 搜索Qt项目 (本地)  | `:QtSearchProjects` | ⭐⭐     |
| `<leader>qpg` | 全局搜索所有驱动器 | `:QtGlobalSearch`   | 🌍⭐⭐⭐ |

### 构建管理快捷键

| 快捷键        | 功能     | 对应命令          | 描述           |
| ------------- | -------- | ----------------- | -------------- |
| `<leader>qb`  | 构建项目 | `:QtBuildProject` | 执行项目构建   |
| `<leader>qr`  | 运行项目 | `:QtRunProject`   | 运行可执行文件 |
| `<leader>qcl` | 清理项目 | `:QtCleanProject` | 清理构建文件   |
| `<leader>qbs` | 构建状态 | `:QtBuildStatus`  | 查看构建状态   |

### 脚本管理快捷键

#### 脚本执行

| 快捷键        | 功能     | 对应命令           | 描述         |
| ------------- | -------- | ------------------ | ------------ |
| `<leader>qsb` | 脚本构建 | `:QtScript build`  | 执行构建脚本 |
| `<leader>qsr` | 脚本运行 | `:QtScript run`    | 执行运行脚本 |
| `<leader>qsd` | 脚本调试 | `:QtScript debug`  | 执行调试脚本 |
| `<leader>qsc` | 脚本清理 | `:QtScript clean`  | 执行清理脚本 |
| `<leader>qst` | 脚本测试 | `:QtScript test`   | 执行测试脚本 |
| `<leader>qsp` | 脚本部署 | `:QtScript deploy` | 执行部署脚本 |

#### 脚本管理

| 快捷键        | 功能         | 对应命令                | 描述             |
| ------------- | ------------ | ----------------------- | ---------------- |
| `<leader>qsg` | 脚本生成器   | `:QtScriptGenerator`    | 交互式脚本生成器 |
| `<leader>qsa` | 生成所有脚本 | `:QtGenerateAllScripts` | 一键生成所有脚本 |

### UI设计师快捷键

| 快捷键        | 功能             | 对应命令                 | 描述                   |
| ------------- | ---------------- | ------------------------ | ---------------------- |
| `<leader>qud` | 打开Designer     | `:QtOpenDesigner`        | 打开Qt Designer        |
| `<leader>quc` | Designer当前文件 | `:QtOpenDesignerCurrent` | 为当前文件打开Designer |
| `<leader>qum` | Designer管理器   | `:QtDesignerManager`     | UI设计师管理界面       |

### 代码格式化快捷键

| 快捷键        | 功能                 | 对应命令               | 描述                               |
| ------------- | -------------------- | ---------------------- | ---------------------------------- |
| `<leader>qff` | 格式化当前文件       | `:QtFormatFile`        | 使用配置的格式化工具格式化当前文件 |
| `<leader>qfp` | 格式化项目           | `:QtFormatProject`     | 格式化整个项目的所有C++文件        |
| `<leader>qfs` | 格式化工具状态       | `:QtFormatterStatus`   | 查看可用的格式化工具状态           |
| `<leader>qfc` | 创建clang-format配置 | `:QtCreateClangFormat` | 创建.clang-format配置文件          |

### 系统和版本信息快捷键

| 快捷键        | 功能       | 对应命令           | 描述             |
| ------------- | ---------- | ------------------ | ---------------- |
| `<leader>qsi` | 系统信息   | `:QtSystemInfo`    | 显示系统环境信息 |
| `<leader>qvi` | Qt版本信息 | `:QtVersionInfo`   | 显示Qt版本信息   |
| `<leader>qvd` | 检测Qt版本 | `:QtDetectVersion` | 重新检测Qt版本   |

### 记忆技巧

快捷键采用层次化助记符设计：

**第一层 - 功能分类:**

- `q` = **Qt** (所有快捷键都以q开头)

**第二层 - 功能模块:**

- `p` = **Project** (项目管理)
- `s` = **Script** (脚本管理)
- `u` = **UI** (UI设计师)
- `b` = **Build** (构建相关)
- `r` = **Run** (运行相关)
- `f` = **Format** (代码格式化)
- `v` = **Version** (版本相关)
- `c` = **Clean/Core** (清理/核心功能)

**第三层 - 具体操作:**

- `o` = **Open** (打开)
- `m` = **Manager** (管理器)
- `c` = **Choose** (选择)
- `w` = **sWitch** (切换)
- `r` = **Recent** (最近)
- `s` = **Search** (搜索)
- `g` = **Global** (全局)
- `b` = **Build** (构建)
- `d` = **Debug/Designer** (调试/设计师)
- `t` = **Test** (测试)
- `p` = **dePloy** (部署)
- `f` = **File** (文件)
- `a` = **All** (全部)
- `i` = **Info** (信息)
- `c` = **Config** (配置)

### 使用建议

**日常开发流程:**

1. `<leader>qpo` - 智能打开项目
2. `<leader>qsa` - 生成项目脚本（首次）
3. `<leader>qfc` - 创建.clang-format配置（首次）
4. `<leader>qsb` - 构建项目
5. `<leader>qsr` - 运行项目
6. `<leader>qff` - 格式化当前文件（编辑后）
7. `<leader>qsd` - 调试问题（如需）

**项目切换流程:**

1. `<leader>qpw` - 快速切换（最近项目）
2. `<leader>qpg` - 全局搜索（新项目）
3. `<leader>qpc` - 手动选择（精确控制）

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

8. **Qt版本问题**
   - 使用 `:QtVersionInfo` 查看Qt版本检测结果
   - 使用 `:QtDetectVersion` 重新检测Qt版本
   - Windows用户检查Qt5/Qt6安装路径配置
   - 确保CMakeLists.txt中Qt版本声明正确

9. **代码格式化问题**
   - 使用 `:QtFormatterStatus` 查看格式化工具状态
   - 确保已安装clang-format或astyle格式化工具
   - 如需禁用自动格式化，设置 `auto_format.enabled = false`
   - 使用 `:QtCreateClangFormat` 创建项目特定的格式化配置
   - 检查文件类型是否支持格式化（.cpp, .h, .hpp等）

10. **Windows MSVC编译错误**
    - 错误："无法打开包括文件: type_traits"
    - 解决方案：运行 `:QtSetupMsvc` 或使用快捷键 `<leader>qm`
    - 确保Visual Studio Build Tools已正确安装
    - 检查VCINSTALLDIR环境变量是否设置
    - 使用 `:QtCheckMsvc` 检查MSVC环境状态

11. **Clangd LSP问题**
    - Qt Creator生成的compile_commands.json与Neovim clangd不兼容
    - 解决方案：运行 `:QtSetupClangd` 或使用快捷键 `<leader>ql`
    - 插件会自动生成适合Neovim的.clangd配置文件
    - 在Neovim中运行 `:LspRestart` 重启语言服务器
    - 使用 `:LspInfo` 检查clangd状态

12. **键盘映射冲突**
    - 如果快捷键冲突，可以自定义映射：
    ```lua
    require('qt-assistant.core').setup_keymaps({
        build = "<F5>",  -- 使用F5代替<leader>qb
        run = "<F6>",    -- 使用F6代替<leader>qr
    })
    ```
    - 或者完全禁用快捷键，只使用命令形式

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

### 代码格式化配置示例

**完全启用自动格式化（默认）:**

```lua
require('qt-assistant').setup({
    auto_format = {
        enabled = true,              -- 启用自动格式化
        formatter = "clang_format",  -- 使用clang-format
        on_save = true,              -- 保存时自动格式化
    },
})
```

**禁用自动格式化，仅手动格式化:**

```lua
require('qt-assistant').setup({
    auto_format = {
        enabled = false,  -- 禁用自动格式化
    },
})
```

**使用astyle代替clang-format:**

```lua
require('qt-assistant').setup({
    auto_format = {
        enabled = true,
        formatter = "astyle",  -- 使用astyle格式化工具
        on_save = true,
    },
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

## 🆕 版本更新说明

### v1.3.0 主要更新 (当前版本)

- 🔧 **Windows MSVC环境修复**: 解决Windows下编译缺少标准库头文件问题
- 🛠️ **Clangd LSP完整支持**: 新增clangd语言服务器配置，解决Qt Creator兼容性问题
- ⌨️ **键盘映射系统**: 全新的40+快捷键系统，支持自定义和Which-key集成
- 📜 **增强的Windows脚本**: 改进批处理脚本，自动设置MSVC环境
- 🎯 **智能命令扩展**: 新增20+个Vim命令，如`:QtSetupClangd`、`:QtSetupMsvc`等
- 🔄 **自动环境配置**: 构建脚本自动调用环境设置，无需手动配置

### v2.0.0 主要更新

- ✨ **Qt5/Qt6双版本支持**: 全面支持Qt5和Qt6项目开发
- 🔄 **智能版本检测**: 自动识别项目Qt版本并适配相应模板
- 🖥️ **Windows增强支持**: 自动检测Windows系统Qt安装路径
- 📜 **脚本系统重构**: 基于实际项目模板的健壮脚本生成
- 🎯 **模板变量系统**: 支持项目名称和Qt版本自动替换
- 🎨 **代码自动格式化**: 默认启用clang-format自动格式化，保存时自动格式化C++代码
- ⚡ **性能优化**: 改进项目检测和脚本生成速度
- 🔧 **错误处理增强**: 更完善的错误处理和用户反馈

### 即将发布 (v1.4.0)

- 🎮 **模板引擎增强**: 支持更多自定义模板变量
- 🔄 **项目模板系统**: 内置多种Qt项目模板
- 📊 **构建状态监控**: 实时构建状态和进度显示
- 🌐 **多语言界面**: 支持中英文界面切换

**注意**: 这个插件专为Qt C++开发设计，支持CMake、qmake等多种构建系统，对Qt5和Qt6项目均可获得最佳体验。对Windows用户的MSVC环境支持特别优化。
