# Architecture

> **English** | [简体中文](ARCHITECTURE.zh-CN.md)

> This document describes the layered structure and module map of qt-assistant.nvim.
> Refactoring goal: **split by function; the main module only wires things together**.

## Layers

```
app   (wiring)    qt-assistant.lua            # setup / keymaps / lazy-load wiring
                  plugin/qt-assistant.lua     # all :Qt* user commands
core  (logic)     lua/qt-assistant/core/*.lua # pure logic, no UI
ui    (presentation) lua/qt-assistant/ui/init.lua # windows / info panels
data  (templates) templates/*.tmpl            # plain-text templates, host-overridable
tests              tests/run.lua               # headless regression
```

Dependency direction: `app → core → config`; `core → (core.class / core.templates / core.system)`; `ui → core`.
**core never depends on ui**, keeping logic headless-testable.

## core/ module map

| Module | Responsibility | Notes |
| --- | --- | --- |
| `core/config.lua` | defaults / validation / `get/set_value` | single source of truth for options |
| `core/toolchain.lua` | Qt toolchain discovery + broadcast + host selection/persistence | `:QtSelectKit` `:QtKitList`; see [TOOLCHAIN.md](TOOLCHAIN.md) |
| `core/project_manager.lua` | project create/open/multi-module | `:QtNewProject` family |
| `core/build_manager.lua` | build dispatch (CMake/qmake/xmake) | `:QtBuild` family |
| `core/cmake.lua` | CMakePresets generation, CMakeLists format/backup/append | `:QtCMakePresets` etc. |
| `core/class.lua` | class generation flow (templates + files + CMake) | formerly `core.lua`; `:QtCreateClass` |
| `core/templates.lua` | template loader + render engine + host override chain | see [TEMPLATES.md](TEMPLATES.md) |
| `core/designer.lua` | Qt Designer / `.ui` operations | `:QtDesigner` family |
| `core/file_manager.lua` | target-dir decisions and file creation | |
| `core/scripts.lua` | project scripts (built-ins + host overrides) | `:QtScripts` |
| `core/lsp.lua` | clangd / compile_commands helpers | |
| `core/debug.lua` | nvim-dap integration & adapter probing | `:QtDebug` family |
| `core/history.lua` | recent projects | |
| `core/system.lua` | platform checks, path join, processes | |

## ui/ module map

`ui/init.lua` provides every window/panel (main interface, class creator, script manager, build status...).
Principle: ui only **renders**; business results come from core return values.

## data/ templates

`templates/*.tmpl` are plain-text templates (56 files) with `{{VAR}}`,
`{{#VAR}}...{{/VAR}}` and `{{^VAR}}...{{/VAR}}` syntax.
The host can override any of them via `config.templates.custom_dir/override` or
`M.register_template()`, see [TEMPLATES.md](TEMPLATES.md).

## require conventions

- inside core: `require('qt-assistant.core.xxx')`
- ui referencing core: `require('qt-assistant.core.xxx')`
- referencing ui: `require('qt-assistant.ui')` (`ui/init.lua`)
- main module: `require('qt-assistant')`

When adding a core module, update this table and the module list in `tests/run.lua`.
