# Qt Assistant - Neovim Plugin for Qt Development

[![GitHub release](https://img.shields.io/github/v/release/onewu867/qt-assistant.nvim)](https://github.com/onewu867/qt-assistant.nvim/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Neovim](https://img.shields.io/badge/Neovim-0.8+-green.svg)](https://neovim.io/)
[![Lua](https://img.shields.io/badge/Lua-5.1+-blue.svg)](https://www.lua.org/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/onewu867/qt-assistant.nvim)

一个专为Qt C++开发设计的Neovim插件，提供快速类创建、智能文件管理、代码模板、项目脚本管理和Qt5/Qt6跨版本支持功能。

## 🆕 v1.2.0 更新 (2025-07-26)

**重要修复**：
- ✅ **循环依赖修复**: 完全解决了主界面 (`<leader>qc`) 和类创建功能的循环依赖错误
- ✅ **系统信息修复**: 修复了系统信息显示 (`<leader>qis`) 的 nil 值错误
- ✅ **快捷键补全**: 添加了所有缺失的脚本管理快捷键 (`<leader>qsa/qsc/qst/qsp`)

**推荐升级**: 此版本修复了关键稳定性问题，强烈建议所有用户升级。

📚 **详细信息**: 查看 [修复日志](docs/BUGFIX_CHANGELOG_v1.2.0.md) 和 [故障排除指南](docs/CONFIGURATION_TROUBLESHOOTING.md)

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
  - Windows: `build.bat`, `clean.bat`, `run.bat`, `debug.bat`, `test.bat`, `deploy.bat`
- **智能脚本内容**: 脚本内容根据系统差异和Qt版本自动适配
- **项目信息自动检测**: 自动检测项目名称、Qt版本、构建系统
- **健壮的错误处理**: 失败时立即退出，避免连锁错误
- **交互式脚本生成器**: 支持选择性生成和一键生成所有脚本

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
:QtScript build
:QtScript clean  
:QtScript run
:QtScript debug
:QtScript test
:QtScript deploy

# 脚本管理
:QtScriptGenerator      # 交互式脚本生成器
:QtGenerateAllScripts   # 快速生成所有脚本
:QtDetectBuildSystem    # 检测项目构建系统
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

插件提供了丰富的快捷键映射，使用 `:QtKeymaps` 查看完整列表：

### 基础操作
- `<leader>qc` - 打开Qt Assistant
- `<leader>qh` - 显示帮助

### 项目管理

**核心操作:**
- `<leader>qpo` - 智能打开项目 (⭐ 自动)
- `<leader>qpm` - 项目管理器

**项目切换:**
- `<leader>qpc` - 选择项目 (手动)
- `<leader>qpw` - 快速项目切换器 (⚡ 快速)
- `<leader>qpr` - 最近项目

**项目搜索:**
- `<leader>qps` - 搜索Qt项目 (本地)
- `<leader>qpg` - 全局搜索所有驱动器 (🌍 完整)

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
- `<leader>qsc` - 脚本清理
- `<leader>qst` - 脚本测试  
- `<leader>qsp` - 脚本部署
- `<leader>qsg` - 脚本生成器
- `<leader>qsa` - 生成所有脚本

### 系统和版本信息
- `<leader>qsi` - 系统信息
- `<leader>qvi` - Qt版本信息
- `<leader>qvd` - 检测Qt版本

**注意**: `<leader>` 通常是 `\` 键，可以通过 `let mapleader = ","` 来自定义。

## 📋 完整快捷键参考

### 基础操作
| 快捷键 | 功能 | 对应命令 |
|--------|------|----------|
| `<leader>qC` | Qt Assistant 主界面 | `:QtAssistant` |
| `<leader>qh` | 显示帮助信息 | `:help qt-assistant` |

### 项目管理快捷键

#### 核心操作
| 快捷键 | 功能 | 对应命令 | 推荐度 |
|--------|------|----------|--------|
| `<leader>qpo` | 智能打开项目 (自动) | `:QtSmartSelector` | ⭐⭐⭐ |
| `<leader>qpm` | 项目管理器 | `:QtProjectManager` | ⭐⭐ |

#### 项目选择/切换
| 快捷键 | 功能 | 对应命令 | 推荐度 |
|--------|------|----------|--------|
| `<leader>qpc` | 选择项目 (手动) | `:QtChooseProject` | ⭐⭐ |
| `<leader>qpw` | 快速项目切换器 | `:QtQuickSwitcher` | ⚡⭐⭐⭐ |
| `<leader>qpr` | 最近项目 | `:QtRecentProjects` | ⭐⭐ |

#### 项目搜索
| 快捷键 | 功能 | 对应命令 | 推荐度 |
|--------|------|----------|--------|
| `<leader>qps` | 搜索Qt项目 (本地) | `:QtSearchProjects` | ⭐⭐ |
| `<leader>qpg` | 全局搜索所有驱动器 | `:QtGlobalSearch` | 🌍⭐⭐⭐ |

### 构建管理快捷键
| 快捷键 | 功能 | 对应命令 | 描述 |
|--------|------|----------|------|
| `<leader>qb` | 构建项目 | `:QtBuildProject` | 执行项目构建 |
| `<leader>qr` | 运行项目 | `:QtRunProject` | 运行可执行文件 |
| `<leader>qcl` | 清理项目 | `:QtCleanProject` | 清理构建文件 |
| `<leader>qbs` | 构建状态 | `:QtBuildStatus` | 查看构建状态 |

### 脚本管理快捷键

#### 脚本执行
| 快捷键 | 功能 | 对应命令 | 描述 |
|--------|------|----------|------|
| `<leader>qsb` | 脚本构建 | `:QtScript build` | 执行构建脚本 |
| `<leader>qsr` | 脚本运行 | `:QtScript run` | 执行运行脚本 |
| `<leader>qsd` | 脚本调试 | `:QtScript debug` | 执行调试脚本 |
| `<leader>qsc` | 脚本清理 | `:QtScript clean` | 执行清理脚本 |
| `<leader>qst` | 脚本测试 | `:QtScript test` | 执行测试脚本 |
| `<leader>qsp` | 脚本部署 | `:QtScript deploy` | 执行部署脚本 |

#### 脚本管理
| 快捷键 | 功能 | 对应命令 | 描述 |
|--------|------|----------|------|
| `<leader>qsg` | 脚本生成器 | `:QtScriptGenerator` | 交互式脚本生成器 |
| `<leader>qsa` | 生成所有脚本 | `:QtGenerateAllScripts` | 一键生成所有脚本 |

### UI设计师快捷键
| 快捷键 | 功能 | 对应命令 | 描述 |
|--------|------|----------|------|
| `<leader>qud` | 打开Designer | `:QtOpenDesigner` | 打开Qt Designer |
| `<leader>quc` | Designer当前文件 | `:QtOpenDesignerCurrent` | 为当前文件打开Designer |
| `<leader>qum` | Designer管理器 | `:QtDesignerManager` | UI设计师管理界面 |

### 代码格式化快捷键
| 快捷键 | 功能 | 对应命令 | 描述 |
|--------|------|----------|------|
| `<leader>qff` | 格式化当前文件 | `:QtFormatFile` | 使用配置的格式化工具格式化当前文件 |
| `<leader>qfp` | 格式化项目 | `:QtFormatProject` | 格式化整个项目的所有C++文件 |
| `<leader>qfs` | 格式化工具状态 | `:QtFormatterStatus` | 查看可用的格式化工具状态 |
| `<leader>qfc` | 创建clang-format配置 | `:QtCreateClangFormat` | 创建.clang-format配置文件 |

### 系统和版本信息快捷键
| 快捷键 | 功能 | 对应命令 | 描述 |
|--------|------|----------|------|
| `<leader>qsi` | 系统信息 | `:QtSystemInfo` | 显示系统环境信息 |
| `<leader>qvi` | Qt版本信息 | `:QtVersionInfo` | 显示Qt版本信息 |
| `<leader>qvd` | 检测Qt版本 | `:QtDetectVersion` | 重新检测Qt版本 |

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

### v2.0.0 主要更新
- ✨ **Qt5/Qt6双版本支持**: 全面支持Qt5和Qt6项目开发
- 🔄 **智能版本检测**: 自动识别项目Qt版本并适配相应模板
- 🖥️ **Windows增强支持**: 自动检测Windows系统Qt安装路径
- 📜 **脚本系统重构**: 基于实际项目模板的健壮脚本生成
- 🎯 **模板变量系统**: 支持项目名称和Qt版本自动替换
- 🎨 **代码自动格式化**: 默认启用clang-format自动格式化，保存时自动格式化C++代码
- ⚡ **性能优化**: 改进项目检测和脚本生成速度
- 🔧 **错误处理增强**: 更完善的错误处理和用户反馈

**注意**: 这个插件专为Qt C++开发设计，支持CMake、qmake等多种构建系统，对Qt5和Qt6项目均可获得最佳体验。
