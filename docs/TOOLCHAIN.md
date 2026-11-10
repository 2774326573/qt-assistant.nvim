# Qt toolchain: discovery · broadcast · host selection

> **English** | [简体中文](TOOLCHAIN.zh-CN.md)

> On startup the plugin **auto-discovers** local Qt toolchains and broadcasts the result.
> The host (you) picks which one to use via a command; the choice persists and is re-applied
> on every start.

## Quick usage

```vim
:QtSelectKit     " toolchain picker (vim.ui.select; snacks UI in LazyVim)
:QtKitList       " list all discovered toolchains as a notification
:QtDoctor        " build system / Qt tools / vcpkg / debugger diagnostics
```

The auto-broadcast notification looks like:

```
QtAssistant broadcast: found 1 Qt toolchain (current config is healthy).
Active: bin  @  E:/install/Qt5.12/5.12.12/msvc2017_64/bin
Use :QtSelectKit to choose, :QtKitList for details.
```

## Discovery logic (`core/toolchain.lua`)

- Scans the configured roots (limited depth) for **bin directories containing `qmake` or `uic`**;
- Records per kit: bin path, kit name and an availability table
  (qmake/uic/designer/moc/rcc/windeployqt);
- Discovery is strictly read-only — it never writes into your Qt installation.

Default roots:

```lua
qt_discovery = {
    enabled = true,        -- false: disable discovery/broadcast/commands
    auto_broadcast = true, -- broadcast once even when healthy (notify only, non-blocking)
    roots = {
        'C:/Qt', 'D:/Qt', 'E:/Qt', 'E:/Dev/Qt', 'C:/Program Files/Qt',
        'C:/install', 'D:/install', 'E:/install',
    },
},
```

## Selection & persistence

- `:QtSelectKit` applies immediately (updates the running `qt_tools.*`) and stores
  `{ bin, kit }` into `stdpath('data')/qt-assistant/selected_kit.json`;
- On the next start the saved choice is **only re-applied when the explicitly configured
  toolchain is unavailable** (with a notification);
- Explicit `qt_tools` always beats auto-selection — if both exist, yours wins.

Priority (high → low):

1. Explicit `qt_tools.*` from `setup()` (when valid)
2. Persisted `:QtSelectKit` choice (auto re-applied when explicit config fails)
3. Built-in PATH / common-path probing

## Design motivation

- On Windows several Qt installations often coexist (multi-version installers, vcpkg,
  portable archives) and hardcoded paths rot quickly;
- "Assistant broadcasts, host decides": the plugin only discovers and presents —
  **configuration authority always stays with the host**, and can differ per machine/project.
