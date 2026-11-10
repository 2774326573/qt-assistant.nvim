# Qt 工具链：探测 · 广播 · 宿主选择

> **简体中文** | [English](TOOLCHAIN.md)

> 插件会在启动时**自动探测**本机 Qt 工具链并广播结果；宿主（你）通过命令自主选择使用哪一套，选择会被持久化，下次启动自动沿用。

## 快速使用

```vim
:QtSelectKit     " 弹出工具链选择器 (vim.ui.select, LazyVim 下由 snacks 接管)
:QtKitList       " 以通知列出全部探测结果
:QtDoctor        " 打印构建系统/Qt 工具/vcpkg/调试器诊断
```

自动广播通知形如：

```
Qt助手 自动广播: 发现 1 个 Qt 工具链 (当前配置的工具链完好)。
当前生效: bin  @  E:/install/Qt5.12/5.12.12/msvc2017_64/bin
用 :QtSelectKit 选择, :QtKitList 列详情。
```

## 探测逻辑 (`core/toolchain.lua`)

- 扫描根目录（可在配置中增删），按限定深度寻找**含 `qmake` 或 `uic` 的 bin 目录**；
- 对每个 kit 记录：bin 路径、kit 名、可用工具表（qmake/uic/designer/moc/rcc/windeployqt）；
- 探测是纯只读操作，不会写你的 Qt 安装目录。

默认探测根：

```lua
qt_discovery = {
    enabled = true,        -- false: 关闭探测/广播/命令
    auto_broadcast = true, -- 即使工具链完好也广播一次 (仅通知, 不打断输入)
    roots = {
        'C:/Qt', 'D:/Qt', 'E:/Qt', 'E:/Dev/Qt', 'C:/Program Files/Qt',
        'C:/install', 'D:/install', 'E:/install',
    },
},
```

## 选择与持久化

- `:QtSelectKit` 选择后立即应用（写入运行中的 `qt_tools.*`）并把 `{ bin, kit }` 存入
  `stdpath('data')/qt-assistant/selected_kit.json`；
- 下次启动：**仅当显式配置的工具链不可用时**才会自动沿用上次选择（并通知）；
- 显式 `qt_tools` 配置永远优先于自动选择——两者冲突时以你写的为准。

优先级（高 → 低）：

1. `setup()` 中显式给出的 `qt_tools.*`（有效时）
2. 上次 `:QtSelectKit` 的持久化选择（显式配置失效时自动沿用）
3. 内置 PATH/常见路径探测

## 设计动机

- Qt 在 Windows 上可能同时存在多套安装（官方安装器多版本、vcpkg、绿解包），
  硬编码路径容易过期；
- "助手广播、宿主自选"：插件只负责发现与呈现，**配置决定权始终在宿主手里**，
  每台机器/每个项目都可不同。
