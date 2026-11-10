<h1 align="center">Qt Assistant for Neovim</h1>

<p align="center">
  <b>在 Neovim 里完成 Qt C++ 开发闭环 —— 工程管理 · UI Designer · 类生成 · 构建 · 调试</b>
</p>

<p align="center">
  <a href="https://github.com/2774326573/qt-assistant.nvim/actions/workflows/tests.yml"><img src="https://img.shields.io/github/actions/workflow/status/2774326573/qt-assistant.nvim/tests.yml?branch=main&label=tests&style=flat-square" alt="tests" /></a>
  <img src="https://img.shields.io/badge/Neovim-0.8%2B-green?style=flat-square" alt="Neovim 0.8+" />
  <img src="https://img.shields.io/badge/Lua-100%25-blue?style=flat-square" alt="Lua" />
  <img src="https://img.shields.io/badge/License-MIT-orange?style=flat-square" alt="MIT" />
  <img src="https://img.shields.io/badge/Qt-5.15%20%7C%206.x-41cd52?style=flat-square" alt="Qt" />
</p>

---

## ✨ 特性速览

| 功能 | 说明 | 入口 |
| --- | --- | --- |
| 🗂 工程管理 | 标准结构创建/打开 Qt 工程，支持多模块工作区 | `:QtNewProject` |
| 🎨 UI Designer | 创建/编辑 `.ui` 并一键唤起 Qt Designer | `:QtDesigner` |
| ⚙️ 类生成 | 基于 `uic` 从 `.ui` 生成配套 C++ 类 | `:QtCreateClass` |
| 🔨 构建系统 | CMake / qmake / xmake 自动探测，CMake Presets | `:QtBuild` |
| 🐞 调试 | nvim-dap 集成，自动定位可执行文件 | `:QtDebug` |
| 🔌 工具链管理 | 自动探测本机 Qt 工具链，宿主自主选择并持久化 | `:QtSelectKit` |
| 📝 模板自定义 | 模板数据目录化 + 宿主覆盖接口 | [docs/TEMPLATES.md](docs/TEMPLATES.md) |

## 📦 安装

> 仓库全名是 `qt-assistant.nvim`（lazy.nvim 自动识别 `.nvim` 后缀）。

[folke/lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "2774326573/qt-assistant.nvim",
    cmd = { "QtAssistant", "QtNewProject", "QtDesigner", "QtBuild", "QtRun" }, -- 按需加载
    config = function()
        require('qt-assistant').setup({
            enable_default_keymaps = true,  -- <leader>q* 快捷键
            build_system = "auto",          -- CMake -> qmake -> xmake 自动探测
        })
    end
}
```

[wbomason/packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use { '2774326573/qt-assistant.nvim', config = function() require('qt-assistant').setup() end }
```

## 🚀 30 秒上手

```vim
:QtNewProject MyApp widget_app    " 创建工程
:QtNewUi mainwindow               " 新建 UI 并唤起 Designer
:QtCreateClass MainWin main_window mainwindow.ui   " 从 .ui 生成类
:QtBuild                          " 构建
:QtRun                            " 运行
```

快捷键（Leader + q）：`qa` 主界面 · `qp/qo` 工程 · `qu/qe/qd` UI · `qb/qr` 构建/运行。

## 📚 文档

| 文档 | 内容 |
| --- | --- |
| [docs/USAGE.md](docs/USAGE.md) | 全部命令、Keymaps、工作流、调试、xmake、vcpkg、CMake Presets、故障排查 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 分层架构与模块地图（app / core / ui / templates） |
| [docs/TOOLCHAIN.md](docs/TOOLCHAIN.md) | Qt 工具链自动探测、广播、宿主选择与持久化 |
| [docs/TEMPLATES.md](docs/TEMPLATES.md) | 模板目录、占位符语法、宿主自定义接口 |
| [docs/NEW_FEATURES.md](docs/NEW_FEATURES.md) | 特性迭代记录 |

## 🔧 最小配置参考

```lua
require('qt-assistant').setup({
    build_system = "auto",                    -- "cmake" | "qmake" | "xmake" | "auto"

    qt_tools = {                              -- 不填则自动探测; 显式路径优先
        -- designer_path = "E:/install/Qt5.12/5.12.12/msvc2017_64/bin/designer.exe",
        -- uic_path = "...",
        -- qmake_path = "...",
    },

    qt_discovery = {                          -- 工具链自动广播 (详见 docs/TOOLCHAIN.md)
        enabled = true,
        auto_broadcast = true,
    },

    templates = {                             -- 模板宿主自定义 (详见 docs/TEMPLATES.md)
        custom_dir = nil,                     -- 宿主模板目录 (覆盖同名内置)
        override = {},                        -- 单模板文件级覆盖
    },

    vcpkg = { enabled = false },              -- vcpkg 支持
})
```

## 🤝 贡献与测试

```bash
nvim --headless -n -i NONE -u tests/minimal_init.lua -c "lua dofile('tests/run.lua')"
```

欢迎 Issue / PR。提交前请跑一遍上面的 headless 测试。

## 📄 License

[MIT](LICENSE) © [2774326573](https://github.com/2774326573)
