# 完整使用手册

> **简体中文** | [English](USAGE.md)

> 本页是全部命令 / 快捷键 / 工作流的详细参考。概览请看 [README](../README.md)。

## 目录

- [命令总表](#命令总表)
- [工程类型与类类型](#工程类型与类类型)
- [快捷键](#快捷键)
- [调试集成](#调试集成)
- [xmake 支持](#xmake-支持)
- [脚本管理器](#脚本管理器)
- [CMake Presets 与导出](#cmake-presets-与导出)
- [vcpkg 集成](#vcpkg-集成)
- [多模块工程工作流](#多模块工程工作流)
- [跨平台说明](#跨平台说明)
- [故障排查](#故障排查)
- [性能](#性能)

## 命令总表

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `:QtAssistant` | 主界面 | |
| `:QtHelp` | 帮助 | |
| `:QtDoctor` | 构建/工具/vcpkg/调试器诊断 | |
| `:QtNewProject <name> <type> [cxx] [tests\|gtest] [xmake]` | 新建工程 | `:QtNewProject MyApp widget_app 17 gtest xmake` |
| `:QtOpenProject [path]` | 打开工程 | `:QtOpenProject ~/MyProject` |
| `:QtAddModule <name> <type> [tests\|gtest]` | 多模块工程添加模块 | `:QtAddModule core shared_lib gtest` |
| `:QtNewUi <filename>` | 新建 UI 文件 | `:QtNewUi mainwindow` |
| `:QtEditUi [filename]` | 编辑已有 UI | `:QtEditUi mainwindow.ui` |
| `:QtDesigner [file]` | 打开 Qt Designer | `:QtDesigner` |
| `:QtCreateClass <name> <type> [ui]` | 生成 Qt 类（可从 UI） | `:QtCreateClass MainWin main_window main.ui` |
| `:QtBuild` | 构建（CMake/qmake/xmake） | |
| `:QtRun` | 运行 | |
| `:QtClean` | 清理 | |
| `:QtInstall [prefix]` | 安装 | |
| `:QtScripts` | 工程脚本管理器 | |
| `:QtCMakePresets [generator]` | 生成 CMakePresets.json | `:QtCMakePresets Ninja` |
| `:QtBuildPreset [preset]` | 按预设构建 | `:QtBuildPreset debug` |
| `:QtCMakeFormat` / `:QtCMakeBackup` | 格式化 / 备份 CMakeLists.txt | |
| `:QtDebugSetup` / `:QtDebug` / `:QtDebugAttach` / `:QtDebugStatus` | 调试系列 | |
| `:QtSelectKit` | 选择本机 Qt 工具链 | 见 [TOOLCHAIN.md](TOOLCHAIN.md) |
| `:QtKitList` | 列出探测到的工具链 | |
| `:QtTemplatesReload` / `:QtTemplatesOpenCustomDir` | 模板重载 / 打开宿主模板目录 | 见 [TEMPLATES.md](TEMPLATES.md) |

## 工程类型与类类型

**单模块工程**：`widget_app`（Widgets 桌面）、`quick_app`（Quick/QML）、`console_app`（控制台）

**多模块工程**：`multi_project`（根工作区）、`shared_lib`、`static_lib`、`plugin`（模块类型）

**类类型**：`main_window` / `dialog` / `widget` / `model` / `delegate` / `thread` / `utility` / `singleton`

## 快捷键

默认 **minimal** 预设；`keymaps.preset = "full"` 开启扩展键位。

**核心工作流**

| 键 | 功能 |
| --- | --- |
| `<leader>qa` / `<leader>qh` | 主界面 / 帮助 |
| `<leader>qp` / `<leader>qo` | 新建 / 打开工程 |
| `<leader>qu` / `<leader>qe` / `<leader>qd` / `<leader>qf` | 新建 UI / 编辑 UI / Designer / 由 UI 生成类 |
| `<leader>qb` / `<leader>qr` | 构建 / 运行 |
| `<leader>qdb` / `<leader>qda` | 调试 / 附加进程（需 nvim-dap） |

**full 预设附加**：`<leader>qA` 构建+运行、`<leader>qb1/4/7/20` 按标准构建、`<leader>qsc/qss/qsr` 配置查看/标准选择/重配置。

**上下文相关**（打开对应文件时自动生效）：

| 键 | 文件类型 | 功能 |
| --- | --- | --- |
| `<leader>gd` | `.ui` | 当前 UI 唤起 Designer |
| `<leader>gc` | `.ui` | 从当前 UI 生成类 |
| `<leader>gu` | `.h/.cpp` | 反查并打开对应 UI |

**调试键**（`:QtDebugSetup` 或 `debug.keymaps = true` 安装）：`F5/F10/F11/F12`、`<leader>db` 断点。

## 调试集成

依赖 [nvim-dap](https://github.com/mfussenegger/nvim-dap)（LazyVim 的 clangd extra 已内置）。

```vim
:QtDebugSetup    " 一次性初始化与自检
:QtDebug         " 构建 Debug 配置并启动调试
:QtDebugAttach   " 附加到运行中的进程
:QtDebugStatus   " 查看调试配置
```

- 适配器优先级（Windows）：CodeLLDB → `cppvsdbg`(OpenDebugAD7) → LLDB → GDB；Linux：GDB 14+ DAP 默认
- cdb 仅做探测：无法由 nvim-dap 驱动时会用终端打开
- GDB 会话启用 Qt pretty-printing
- 缺 nvim-dap 时命令只提示不崩溃

## xmake 支持

`:QtBuild/QtRun/QtClean/QtInstall` 在工程无 `CMakeLists.txt` 和 `*.pro` 时自动使用 `xmake.lua`；
强制指定：`build_system = "xmake"`。生成 xmake.lua：

```vim
:QtNewProject MyApp widget_app 17 xmake
```

或全局开启 `project = { generate_xmake = true }`。生成的文件使用 xmake Qt 规则
（`qt.widgetapp` / `qt.quickapp` / `qt.console` / `qt.static` / `qt.shared`）。

## 脚本管理器

`:QtScripts` 打开脚本菜单，内置 `build / clean / run / debug / test`。在窗口按 `i` 创建
`<project>/scripts/`；同名脚本覆盖内置；可在终端或后台运行，也可编辑。

## CMake Presets 与导出

- `:QtCMakePresets [generator]` 生成含 `debug/release/relwithdebinfo` 的 `CMakePresets.json`
- `:QtBuildPreset [preset]` 按预设构建
- 构建成功后自动导出到 `export/<project>/bin|lib`；Windows 下若可用 `windeployqt` 会部署 Qt 运行时
- 可通过 `export = { enabled = true, deploy_qt = true, include_tests = true, include_demo = true }` 配置

## vcpkg 集成

```lua
vcpkg = { enabled = true }   -- vcpkg_root / toolchain_file 自动探测, 亦可显式指定
```

探测顺序：`VCPKG_ROOT` → `~/vcpkg`、`~/.vcpkg`、`C:/vcpkg`、`C:/dev/vcpkg`、`C:/Tools/vcpkg`、
`/usr/local/vcpkg`、`/opt/vcpkg`。启用后 CMake 配置自动带上 toolchain；工程模板**不会**仅因
`VCPKG_ROOT` 存在就自动启用，需显式 `vcpkg.enabled = true` 或 `-DQT_ASSISTANT_USE_VCPKG=ON`。
Qt 走 vcpkg 安装时，designer/uic/qmake 会在 `VCPKG_ROOT/installed/*/tools/*` 下回退查找。

## 多模块工程工作流

```vim
:QtNewProject MyProject multi_project
:QtAddModule core shared_lib gtest
:QtAddModule ui shared_lib
:QtAddModule myplugin plugin
:QtAddModule app widget_app
```

生成根 CMakeLists + 各模块目录（src/include/CMakeLists），见 README 结构图。

## 跨平台说明

- **Linux**：系统 Qt 包完整支持（Ubuntu/Arch/RHEL）
- **macOS**：Homebrew / 官方安装器（含 Apple Silicon），部署需 `.app` 包
- **Windows**：官方安装器（MinGW/MSVC）均支持；qmake 构建自动选 `mingw32-make`/`nmake`
  （nmake 不加 `-j`）；clangd `compile_commands` 平台自适应，仅 nmake 时跳过 `bear`

## 故障排查

| 现象 | 处理 |
| --- | --- |
| Designer/uic 找不到 | `:QtDoctor` 看路径；或 `:QtSelectKit` 选对工具链；或显式 `qt_tools` |
| 构建失败 | `:QtHelp` 看系统信息 → 检查 CMakeLists 版本检测 → 确认构建目录可写 |
| 调试没断点符号 | 先构建 Debug（`:QtDebug` 会自动构建），或手动 `cmake -DCMAKE_BUILD_TYPE=Debug` |
| nvim-dap 未安装 | `:QtDebug*` 会提示安装 mfussenegger/nvim-dap |
| 广播说"未匹配" | 工具链路径与探测根不一致 → `:QtSelectKit` 选择或把路径加入 `qt_discovery.roots` |

## 性能

- 启动影响 0ms（cmd/keys 懒加载 + `vim.schedule` 广播）
- 命令响应 <50ms；构建/外部工具调用全部异步
