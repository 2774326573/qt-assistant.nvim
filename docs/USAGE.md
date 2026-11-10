# Full usage manual

> **English** | [简体中文](USAGE.zh-CN.md)

> Complete reference for commands / keymaps / workflows. Overview lives in the [README](../README.md).

## Contents

- [Command table](#command-table)
- [Project & class types](#project--class-types)
- [Keymaps](#keymaps)
- [Debugging](#debugging)
- [xmake support](#xmake-support)
- [Script manager](#script-manager)
- [CMake Presets & export](#cmake-presets--export)
- [vcpkg integration](#vcpkg-integration)
- [Multi-module workflow](#multi-module-workflow)
- [Cross-platform notes](#cross-platform-notes)
- [Troubleshooting](#troubleshooting)
- [Performance](#performance)

## Command table

| Command | Description | Example |
| --- | --- | --- |
| `:QtAssistant` | Main interface | |
| `:QtHelp` | Help | |
| `:QtDoctor` | build/tools/vcpkg/debugger diagnostics | |
| `:QtNewProject <name> <type> [cxx] [tests\|gtest] [xmake]` | Create project | `:QtNewProject MyApp widget_app 17 gtest xmake` |
| `:QtOpenProject [path]` | Open project | `:QtOpenProject ~/MyProject` |
| `:QtAddModule <name> <type> [tests\|gtest]` | Add module (multi-project) | `:QtAddModule core shared_lib gtest` |
| `:QtNewUi <filename>` | New UI file | `:QtNewUi mainwindow` |
| `:QtEditUi [filename]` | Edit existing UI | `:QtEditUi mainwindow.ui` |
| `:QtDesigner [file]` | Open Qt Designer | `:QtDesigner` |
| `:QtCreateClass <name> <type> [ui]` | Generate Qt class (optionally from UI) | `:QtCreateClass MainWin main_window main.ui` |
| `:QtBuild` | Build (CMake/qmake/xmake) | |
| `:QtRun` | Run | |
| `:QtClean` | Clean | |
| `:QtInstall [prefix]` | Install | |
| `:QtScripts` | Project script manager | |
| `:QtCMakePresets [generator]` | Generate CMakePresets.json | `:QtCMakePresets Ninja` |
| `:QtBuildPreset [preset]` | Build with preset | `:QtBuildPreset debug` |
| `:QtCMakeFormat` / `:QtCMakeBackup` | Format / backup CMakeLists.txt | |
| `:QtDebugSetup` / `:QtDebug` / `:QtDebugAttach` / `:QtDebugStatus` | Debugging family | |
| `:QtSelectKit` | Pick local Qt toolchain | see [TOOLCHAIN.md](TOOLCHAIN.md) |
| `:QtKitList` | List discovered toolchains | |
| `:QtTemplatesReload` / `:QtTemplatesOpenCustomDir` | Reload templates / open host template dir | see [TEMPLATES.md](TEMPLATES.md) |

## Project & class types

**Single-module projects**: `widget_app` (Widgets desktop), `quick_app` (Quick/QML), `console_app`

**Multi-module projects**: `multi_project` (root workspace), `shared_lib`, `static_lib`, `plugin` (module types)

**Class types**: `main_window` / `dialog` / `widget` / `model` / `delegate` / `thread` / `utility` / `singleton`

## Keymaps

Default preset is **minimal**; set `keymaps.preset = "full"` for extras.

**Core workflow**

| Key | Action |
| --- | --- |
| `<leader>qa` / `<leader>qh` | main UI / help |
| `<leader>qp` / `<leader>qo` | new / open project |
| `<leader>qu` / `<leader>qe` / `<leader>qd` / `<leader>qf` | new UI / edit UI / Designer / class-from-UI |
| `<leader>qb` / `<leader>qr` | build / run |
| `<leader>qdb` / `<leader>qda` | debug / attach (needs nvim-dap) |

**full preset extras**: `<leader>qA` build+run, `<leader>qb1/4/7/20` build per standard,
`<leader>qsc/qss/qsr` show config / select standard / reconfigure.

**Context-aware** (active when the matching file type is open):

| Key | File type | Action |
| --- | --- | --- |
| `<leader>gd` | `.ui` | open current UI in Designer |
| `<leader>gc` | `.ui` | generate class from current UI |
| `<leader>gu` | `.h/.cpp` | find & open the matching UI |

**Debug keys** (installed by `:QtDebugSetup` or `debug.keymaps = true`): `F5/F10/F11/F12`, `<leader>db` breakpoint.

## Debugging

Requires [nvim-dap](https://github.com/mfussenegger/nvim-dap) (bundled with LazyVim's clangd extra).

```vim
:QtDebugSetup    " one-time init and self-check
:QtDebug         " build Debug config and start a session
:QtDebugAttach   " attach to a running process
:QtDebugStatus   " inspect debug configuration
```

- Adapter priority (Windows): CodeLLDB → `cppvsdbg`(OpenDebugAD7) → LLDB → GDB; Linux: GDB 14+ DAP by default
- cdb is probed only; it cannot be driven by nvim-dap and opens in a terminal instead
- GDB sessions enable Qt pretty-printing
- Without nvim-dap the commands notify instead of crashing

## xmake support

`:QtBuild/QtRun/QtClean/QtInstall` use `xmake.lua` automatically when the project has no
`CMakeLists.txt` and no `*.pro`; force with `build_system = "xmake"`. Generate the file:

```vim
:QtNewProject MyApp widget_app 17 xmake
```

or set `project = { generate_xmake = true }` globally. Generated files use xmake Qt rules
(`qt.widgetapp` / `qt.quickapp` / `qt.console` / `qt.static` / `qt.shared`).

## Script manager

`:QtScripts` opens the script menu with built-ins `build / clean / run / debug / test`.
Press `i` to create `<project>/scripts/`; a same-name script overrides the built-in;
scripts can run in a terminal or the background, or be edited.

## CMake Presets & export

- `:QtCMakePresets [generator]` writes a `CMakePresets.json` with `debug/release/relwithdebinfo`
- `:QtBuildPreset [preset]` builds with a preset
- After a successful build, outputs export to `export/<project>/bin|lib`; on Windows
  `windeployqt` deploys the Qt runtime when available
- Configure via `export = { enabled = true, deploy_qt = true, include_tests = true, include_demo = true }`

## vcpkg integration

```lua
vcpkg = { enabled = true }   -- vcpkg_root / toolchain_file auto-detected, or set explicitly
```

Probe order: `VCPKG_ROOT` → `~/vcpkg`, `~/.vcpkg`, `C:/vcpkg`, `C:/dev/vcpkg`, `C:/Tools/vcpkg`,
`/usr/local/vcpkg`, `/opt/vcpkg`. When enabled, CMake configuration includes the toolchain;
project templates do **not** auto-enable just because `VCPKG_ROOT` exists — set
`vcpkg.enabled = true` explicitly or pass `-DQT_ASSISTANT_USE_VCPKG=ON`. Qt installed through
vcpkg is found under `VCPKG_ROOT/installed/*/tools/*` as a fallback for designer/uic/qmake.

## Multi-module workflow

```vim
:QtNewProject MyProject multi_project
:QtAddModule core shared_lib gtest
:QtAddModule ui shared_lib
:QtAddModule myplugin plugin
:QtAddModule app widget_app
```

Generates a root CMakeLists plus per-module directories (src/include/CMakeLists), see the
structure diagram in the README.

## Cross-platform notes

- **Linux**: full support via system Qt packages (Ubuntu/Arch/RHEL)
- **macOS**: Homebrew / official installer (Apple Silicon included); deployment requires `.app`
- **Windows**: official installers (MinGW/MSVC) both supported; qmake builds auto-pick
  `mingw32-make`/`nmake` (nmake without `-j`); clangd `compile_commands` is platform-aware,
  `bear` skipped when only nmake exists

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Designer/uic not found | `:QtDoctor` for paths; `:QtSelectKit` to pick a toolchain; or set explicit `qt_tools` |
| Build fails | `:QtHelp` for system info → check CMakeLists version detection → ensure the build dir is writable |
| No debug symbols | Build Debug first (`:QtDebug` does it automatically) or `cmake -DCMAKE_BUILD_TYPE=Debug` |
| nvim-dap missing | `:QtDebug*` will tell you to install mfussenegger/nvim-dap |
| Broadcast says "no match" | toolchain path differs from probed roots → `:QtSelectKit` or add the path to `qt_discovery.roots` |

## Performance

- 0ms startup impact (cmd/keys lazy-load + `vim.schedule` broadcast)
- Command response <50ms; builds and external tools run asynchronously
