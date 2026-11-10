# Neovim Qt 助手

一个简化的Neovim Qt开发插件，提供必要的Qt项目管理和UI设计工具，无需离开编辑器。

## 功能特性

### 核心Qt开发工作流

- **项目管理**: 创建和打开具有标准结构的Qt项目
- **UI设计器集成**: 创建、编辑UI文件并无缝启动Qt Designer
- **类生成**: 从UI文件生成C++类，并正确集成uic
- **构建系统**: 支持 CMake、qmake 和 xmake（检测 `xmake.lua`）
- **构建工具选择**: qmake 构建会自动选择 `mingw32-make` / `nmake` / `make`（在 nmake 下不会携带 `-j`）
- **调试**: 完整的nvim-dap集成，用于Qt应用程序调试
- **跨平台**: 支持Linux、macOS和Windows

### PRD合规性

本插件实现了产品需求文档中的所有核心要求：

- ✅ **F1.1**: 创建新Qt项目 (`:QtNewProject`)
- ✅ **F2.1**: 启动Qt Designer (`:QtDesigner`)
- ✅ **F2.2**: 创建新UI文件 (`:QtNewUi`)
- ✅ **F2.3**: 编辑现有UI文件 (`:QtEditUi`)
- ✅ **F3.1**: 从UI文件生成C++类 (`:QtCreateClass`)
- ✅ **F3.2**: 自动更新CMakeLists.txt
- ✅ **F4.3**: UI文件的命令补全
- ✅ **增强功能**: nvim-dap调试集成

## 安装

### 使用 lazy.nvim

```lua
{
    "2774326573/neovim-qt-assistant",
    config = function()
        require('qt-assistant').setup({
            -- 可选配置
            auto_update_cmake = true,
            enable_default_keymaps = true,
            -- vcpkg 支持 (可选)
            vcpkg = {
                enabled = false,           -- 启用 vcpkg 支持
                vcpkg_root = nil,          -- vcpkg 根目录 (自动检测)
                toolchain_file = nil       -- vcpkg 工具链文件路径 (自动推断)
            }
        })
    end
}
```

### 使用 packer.nvim

```lua
use {
    '2774326573/neovim-qt-assistant',
    config = function()
        require('qt-assistant').setup()
    end
}
```

### vcpkg 集成

插件支持与 [vcpkg](https://github.com/microsoft/vcpkg) 包管理器集成，用于管理 C++ 依赖。

#### 启用 vcpkg

```lua
require('qt-assistant').setup({
    vcpkg = {
        enabled = true,                               -- 启用 vcpkg
        vcpkg_root = "C:/vcpkg",                     -- 可选：指定 vcpkg 根目录
        toolchain_file = "C:/vcpkg/scripts/buildsystems/vcpkg.cmake"  -- 可选：指定工具链文件
    }
})
```

**自动检测：** 插件会自动检测 vcpkg 安装位置，检查以下位置：
- 环境变量 `VCPKG_ROOT`
- `~/vcpkg`, `~/.vcpkg`
- `C:/vcpkg`, `C:/dev/vcpkg`, `C:/Tools/vcpkg` (Windows)
- `/usr/local/vcpkg`, `/opt/vcpkg` (Linux/macOS)

**使用方法：**
1. 启用 vcpkg 后，CMake 配置将自动包含 vcpkg 工具链文件
2. 在项目中使用 `vcpkg.json` 或通过 `vcpkg install` 安装依赖
3. CMake 将自动找到 vcpkg 安装的包

**通过 vcpkg 查找 Qt 工具：** 如果你的 Qt 是通过 vcpkg 安装的，当系统 PATH/常见 Qt 安装目录找不到时，插件也会尝试在 `VCPKG_ROOT/installed/*/tools/*` 下定位 Qt 工具（例如 `designer` / `uic` / `qmake`）。

**CMake 模板行为：** vcpkg 作为“备用选项”，新建项目的模板不会因为设置了 `VCPKG_ROOT` 就自动启用 vcpkg。需要显式开启：要么在插件配置里设置 `vcpkg.enabled = true`，要么在 CMake 配置时传入 `-DQT_ASSISTANT_USE_VCPKG=ON`。

```bash
# 安装依赖示例
vcpkg install qt5-base qt5-tools
```

## 依赖项
| `:QtCreateClass <name> <type>` | 创建Qt类 | `:QtCreateClass MyWidget widget` |
| `:QtCreateClass <name> <type> <ui>` | 从UI创建类 | `:QtCreateClass MainWin main_window main.ui` |
| `:QtBuild` | 构建项目（CMake / qmake / xmake） | `:QtBuild` |
| `:QtRun` | 运行项目 | `:QtRun` |
| `:QtClean` | 清理构建 | `:QtClean` |
| `:QtInstall [prefix]` | 安装（CMake 或 xmake） | `:QtInstall` |
| `:QtScripts` | 打开脚本管理器 | `:QtScripts` |
| `:QtDebugSetup` | 设置调试环境 | `:QtDebugSetup` |
| `:QtDebug` | 调试Qt应用程序 | `:QtDebug` |
| `:QtDebugAttach` | 附加到运行进程 | `:QtDebugAttach` |
| `:QtDebugStatus` | 显示调试配置 | `:QtDebugStatus` |

#### 2. 安装调试适配器

**Linux:**

```bash
# GDB（通常预装）
sudo apt install gdb                    # Ubuntu/Debian
sudo pacman -S gdb                      # Arch

# CodeLLDB（推荐）
# 通过Mason安装或从GitHub releases下载
```

**macOS:**

```bash
# LLDB（随Xcode提供）
xcode-select --install

# CodeLLDB（推荐）
brew install lldb
```

#### 3. 开始调试

```vim
:QtDebugSetup               " 一次性设置和验证
:QtDebug                    " 开始调试当前项目
:QtDebugAttach              " 附加到运行的Qt进程
:QtDebugStatus              " 检查调试配置
```

```vim
:QtNewProject MyApp widget_app
" 可选：生成 Qt Test 测试模板
:QtNewProject MyApp widget_app 17 tests
" 可选：生成 GoogleTest(gtest) 测试模板（适合 vcpkg 安装的 gtest）
:QtNewProject MyApp widget_app 17 gtest

" 多模块工程：添加模块（可选生成测试模板）
:QtAddModule core shared_lib
:QtAddModule core shared_lib tests
:QtAddModule core shared_lib gtest
```

### CMakePresets.json（生成器切换）

生成默认的 `CMakePresets.json`：

```vim
:QtCMakePresets
```

生成时指定生成器（generator）：

```vim
:QtCMakePresets Ninja
:QtCMakePresets "Visual Studio 17 2022"
:QtCMakePresets "MinGW Makefiles"
```

也可以在插件配置里设置默认生成器：

```lua
require('qt-assistant').setup({
    cmake_presets = {
        generator = "Ninja"
    }
})
```

注意：同一个构建目录只能使用一种生成器。切换生成器后，如果之前已经生成过 `build/<presetName>`，请删除旧目录或修改 presets 的 `binaryDir` 指向新目录。

2. **创建UI文件:**

   ```vim
   :QtNewUi mainwindow
   ```

   这会创建`ui/mainwindow.ui`并打开Qt Designer

3. **在Qt Designer中设计界面**

4. **从UI生成C++类:**

   ```vim
   :QtCreateClass MainWindow main_window mainwindow.ui
   ```

   这会运行uic并创建正确集成的C++文件

5. **构建和运行:**

   ```vim
   :QtBuild
   :QtRun
   ```

### 构建产物导出（export 目录）

默认情况下，插件会在构建成功后把可执行文件（以及 tests/demo 若存在）导出到：

- `export/<项目名>/bin/`
- `export/<项目名>/lib/`（若工程产出库）

Windows 下如果能找到 `windeployqt`，导出后还会自动把 Qt 运行时依赖 DLL/插件拷贝到 `export/<项目名>/bin/`。

macOS 下如果能找到 `macdeployqt`，且导出结果包含 `.app`（例如 `export/<项目名>/bin/<项目名>.app`），插件会尝试对该 `.app` 执行 `macdeployqt`。

Linux 下默认依赖系统安装的 Qt 运行时；如果安装了 `linuxdeployqt`，插件会尝试调用它做打包式部署。

可在配置中关闭/调整：

```lua
require('qt-assistant').setup({
    export = {
        enabled = true,
        deploy_qt = true,
        include_tests = true,
        include_demo = true,
    }
})
```

6. **调试（可选）:**

   ```vim
   :QtDebug                    " 开始调试会话
   " 或使用键映射：<leader>qdb用于调试，<F5>继续
   ```

## 跨平台支持

- **Linux**: 完全支持系统Qt包
- **macOS**: 完全支持Homebrew Qt或官方Qt安装程序
- **Windows**: 完全支持官方Qt安装程序（MinGW或MSVC）
    - qmake: 需要 `mingw32-make`（MinGW）或 `nmake`（MSVC）。clangd 的 compile_commands 会使用平台化参数；仅有 nmake 时会跳过 bear。

插件会自动检测所有平台上的Qt工具位置。

## 项目结构

生成的项目遵循Qt最佳实践：

```text
MyProject/
├── CMakeLists.txt       # 构建配置
├── src/                 # 源文件(.cpp)
│   ├── main.cpp
│   └── mainwindow.cpp
├── include/             # 头文件(.h)
│   ├── mainwindow.h
│   └── ui_mainwindow.h  # 由uic生成
├── ui/                  # UI文件(.ui)
│   └── mainwindow.ui
└── build/               # 构建输出
```

## 非功能需求合规性

### ✅ NF1: 性能

- **延迟加载**: 插件模块仅在首次使用命令时加载
- **异步操作**: 所有构建和工具操作异步运行
- **非阻塞**: 文件生成和外部工具调用不阻塞编辑器
- **快速启动**: 对Neovim启动时间零影响

### ✅ NF2: Qt版本兼容性

- **Qt 5.15+**: 完全支持，自动使用C++11标准
- **Qt 6.x**: 完全支持，使用C++17标准
- **自动检测**: 自动Qt版本检测和配置
- **CMake优先**: 优先使用CMake，支持qmake
- **版本感知模板**: Qt5/Qt6不同模板

### ✅ NF3: 平台支持

- **Linux**: 完全支持（Ubuntu、Debian、Arch、CentOS、RHEL）
- **macOS**: 完全支持（Homebrew、官方安装程序、Intel和Apple Silicon）
- **Windows**: 基本支持（未来增强目标）
- **跨平台路径**: 所有平台自动路径检测

### ✅ NF4: 错误处理

- **清晰的错误消息**: 描述性错误消息和有用提示
- **安装指导**: 错误中的平台特定安装说明
- **验证**: 所有命令和文件操作的输入验证
- **优雅降级**: 工具缺失时的回退选项
- **权限检查**: 文件操作前的写权限验证

### ✅ NF5: 快速开发键映射

- **11个核心键映射**: 基本Qt开发工作流
- **上下文感知**: 文件类型特定键映射（UI/C++文件）
- **快速构建和运行**: 一个命令构建和执行
- **智能UI集成**: 自动UI到类生成

## 故障排除

### 🔧 找不到Qt Designer

```bash
# 检查designer是否已安装
which designer

# Linux: 安装Qt工具
sudo apt install qt6-tools-dev qtcreator  # Ubuntu/Debian
sudo pacman -S qt6-tools                   # Arch

# macOS: 使用Homebrew安装
brew install qt@6
echo 'export PATH="/opt/homebrew/opt/qt@6/bin:$PATH"' >> ~/.zshrc
```

### 🔧 找不到uic

```bash
# 检查uic是否可用
which uic

# 通常与Qt开发包一起安装
# 与上面Qt Designer相同的安装命令
```

### 🔧 构建失败

1. **检查Qt安装**: 运行`:QtHelp`并验证系统信息
2. **验证CMakeLists.txt**: 确保正确的Qt版本检测
3. **检查权限**: 确保对构建目录有写访问权限
4. **依赖项**: 为项目类型安装所需的Qt组件

### 🔧 性能问题

- 插件使用延迟加载 - 无启动影响
- 所有操作都是异步的 - 编辑器保持响应
- 大型项目：构建操作在后台运行

### 🔧 调试问题

#### 找不到nvim-dap

```bash
# 使用插件管理器安装nvim-dap
# Lazy.nvim
{'mfussenegger/nvim-dap'}

# 检查安装
:lua print(vim.fn.stdpath('data') .. '/lazy/nvim-dap')
```

#### 找不到调试器

```bash
# Linux - 安装GDB
sudo apt install gdb build-essential     # Ubuntu/Debian
sudo pacman -S gdb base-devel            # Arch

# macOS - 安装Xcode工具
xcode-select --install

# 检查调试器
which gdb           # Linux
which lldb          # macOS
```

#### 没有调试符号

```bash
# 项目会自动以调试模式构建，但您可以强制：
cd build && cmake -DCMAKE_BUILD_TYPE=Debug .. && make

# 或对于qmake项目：
cd build && qmake CONFIG+=debug .. && make debug
```

### 🔧 平台特定问题

#### Linux

- 安装开发包：`*-dev`或`*-devel`
- 检查Qt版本：`qmake --version`或`cmake --find-package Qt6`

#### macOS特定注意事项

- 使用Homebrew进行简易安装和PATH管理
- 支持Intel（`/usr/local`）和Apple Silicon（`/opt/homebrew`）
- 官方Qt安装程序也可使用

## 性能基准

- **启动影响**: 0ms（延迟加载）
- **命令响应**: <50ms（大多数命令）

### 在 Neovim 中强制使用 LF 行尾

将以下内容添加到你的 `init.lua`，保存 CMake 相关文件时自动写为 LF，避免 CRLF 报警：

```lua
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "CMakeLists.txt", "*.cmake" },
    callback = function()
        vim.opt_local.fileformat = "unix"
        vim.opt_local.fileformats = { "unix" }
    end,
})
```
| ---- | ---- | ---- | ---- |
| **项目管理** | ✅ 核心 | Qt工具 | `:QtNewProject`, `:QtOpenProject`, `:QtAddModule` |
| **UI设计器** | ✅ 核心 | Qt Designer | `:QtNewUi`, `:QtEditUi`, `:QtDesigner` |
| **类生成** | ✅ 核心 | uic工具 | `:QtCreateClass` |
| **构建系统** | ✅ 核心 | CMake、qmake、xmake | `:QtBuild`, `:QtRun`, `:QtClean` |
| **调试** | ✅ 增强 | nvim-dap + 调试器 | `:QtDebug`, `:QtDebugAttach` |
| **快速键映射** | ✅ 核心 | 无 | `<leader>q*` 快捷键 |

默认使用 **minimal** 快捷键预设（更精简，和文档示例一致）。如果你需要更多/历史快捷键（例如快速新建、指定 C++ 标准构建等），可在配置中开启：

```lua
require('qt-assistant').setup({
    keymaps = { preset = "full" }
})
```

说明：很多人的 `<leader>qq` 会映射为“退出/关闭”，所以本插件不会默认占用它；`full` 预设里提供快速构建运行：`<leader>qA`。
| **跨平台** | ✅ 核心 | 平台Qt | Linux, macOS, Windows |

## 许可证

MIT许可证 - 详见LICENSE文件。
