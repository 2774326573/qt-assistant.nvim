<h1 align="center">Qt Assistant for Neovim</h1>

<p align="center">
  <b>Complete Qt C++ development loop inside Neovim — project management · UI Designer · class generation · build · debug</b>
</p>

<p align="center">
  **English** | [简体中文](README.zh-CN.md)
</p>

<p align="center">
  <a href="https://github.com/2774326573/qt-assistant.nvim/actions/workflows/tests.yml"><img src="https://img.shields.io/github/actions/workflow/status/2774326573/qt-assistant.nvim/tests.yml?branch=main&label=tests&style=flat-square" alt="tests" /></a>
  <img src="https://img.shields.io/badge/Neovim-0.8%2B-green?style=flat-square" alt="Neovim 0.8+" />
  <img src="https://img.shields.io/badge/Lua-100%25-blue?style=flat-square" alt="Lua" />
  <img src="https://img.shields.io/badge/License-MIT-orange?style=flat-square" alt="MIT" />
  <img src="https://img.shields.io/badge/Qt-5.15%20%7C%206.x-41cd52?style=flat-square" alt="Qt" />
</p>

---

## ✨ Features

| Feature | Description | Entry |
| --- | --- | --- |
| 🗂 Project management | Create/open Qt projects with standard structure, multi-module workspaces | `:QtNewProject` |
| 🎨 UI Designer | Create/edit `.ui` files and launch Qt Designer in one key | `:QtDesigner` |
| ⚙️ Class generation | Generate paired C++ classes from `.ui` files via `uic` | `:QtCreateClass` |
| 🔨 Build system | Auto-detects CMake / qmake / xmake, CMake Presets support | `:QtBuild` |
| 🐞 Debugging | nvim-dap integration, auto-locates the executable | `:QtDebug` |
| 🔌 Toolchain manager | Auto-discovers local Qt toolchains; the host picks and it persists | `:QtSelectKit` |
| 📝 Custom templates | Template data lives in plain files + host override API | [docs/TEMPLATES.md](docs/TEMPLATES.md) |

## 📦 Installation

> The repo name is `qt-assistant.nvim` (lazy.nvim recognizes the `.nvim` suffix).

[folke/lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "2774326573/qt-assistant.nvim",
    cmd = { "QtAssistant", "QtNewProject", "QtDesigner", "QtBuild", "QtRun" }, -- lazy-load
    config = function()
        require('qt-assistant').setup({
            enable_default_keymaps = true,  -- <leader>q* keymaps
            build_system = "auto",          -- CMake -> qmake -> xmake auto-detection
        })
    end
}
```

[wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use { '2774326573/qt-assistant.nvim', config = function() require('qt-assistant').setup() end }
```

## 🚀 30-second quick start

```vim
:QtNewProject MyApp widget_app    " create a project
:QtNewUi mainwindow               " new UI file, opens Designer
:QtCreateClass MainWin main_window mainwindow.ui   " generate class from .ui
:QtBuild                          " build
:QtRun                            " run
```

Keymaps (Leader + q): `qa` main UI · `qp/qo` project · `qu/qe/qd` UI · `qb/qr` build/run.

## 📚 Documentation

| Document | Content |
| --- | --- |
| [docs/USAGE.md](docs/USAGE.md) | Full command table, keymaps, workflows, debugging, xmake, vcpkg, CMake Presets, troubleshooting |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Layered architecture & module map (app / core / ui / templates) |
| [docs/TOOLCHAIN.md](docs/TOOLCHAIN.md) | Qt toolchain discovery, broadcast, host selection & persistence |
| [docs/TEMPLATES.md](docs/TEMPLATES.md) | Template directory, placeholder syntax, host customization API |
| [docs/NEW_FEATURES.md](docs/NEW_FEATURES.md) | Feature iteration log |

### Offline docs `:QtDocs` (zero-config)

`setup()` runs an async bootstrap (never blocks startup):

- First run auto-downloads the Qt 6 offline docset (~190MB, official Kapeli feed) and extracts it to `stdpath("data")/qt-docsets/`
- Auto pre-clones [outline.nvim](https://github.com/hedyhli/outline.nvim) (falls back to a gh-proxy mirror), so opening a page shows a heading outline sidebar
- Checks the markdown treesitter parser (auto `:TSInstall markdown` when nvim-treesitter is present)
- Fully idempotent: ready items are skipped; a failed item only warns and never breaks other features

```lua
require('qt-assistant').setup({
    docs = {
        docset_path = nil,      -- default: stdpath("data")/qt-docsets/Qt.docset
        docset_url = "https://kapeli.com/feeds/Qt.tgz",
        auto_bootstrap = true,  -- set false for fully manual
        keep_archive = false,   -- delete the .tgz after extraction
        python = nil,           -- auto-detected (stdlib sqlite3 powers the index query)
        limit = 50,
    },
})
```

Usage: put the cursor on a symbol and press `<leader>qh`, or run `:QtDocs <symbol>` (Tab-completed); pages render in-buffer as markdown (tables, fenced code) with a jumpable outline tree.

> 简体中文文档：每个专题都有 `docs/*.zh-CN.md` 版本，README 中文版见 [README.zh-CN.md](README.zh-CN.md)。

## 🔧 Minimal configuration

```lua
require('qt-assistant').setup({
    build_system = "auto",                    -- "cmake" | "qmake" | "xmake" | "auto"

    qt_tools = {                              -- omit for auto-detection; explicit paths win
        -- designer_path = "E:/install/Qt5.12/5.12.12/msvc2017_64/bin/designer.exe",
        -- uic_path = "...",
        -- qmake_path = "...",
    },

    qt_discovery = {                          -- toolchain auto-broadcast (see docs/TOOLCHAIN.md)
        enabled = true,
        auto_broadcast = true,
    },

    templates = {                             -- host template overrides (see docs/TEMPLATES.md)
        custom_dir = nil,                     -- host template dir (overrides same-name built-ins)
        override = {},                        -- per-template file override
    },

    vcpkg = { enabled = false },              -- vcpkg support
})
```

## 🧪 Tests

```bash
nvim --headless -n -i NONE -u tests/minimal_init.lua -c "lua dofile('tests/run.lua')"
```

## 📄 License

[MIT](LICENSE) © [2774326573](https://github.com/2774326573)
