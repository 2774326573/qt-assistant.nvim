# 架构 / Architecture

> **简体中文** | [English](ARCHITECTURE.md)

> 本文档描述 qt-assistant.nvim 的分层结构与模块地图。重构目标：**按功能拆分模块，主模块只做接线**。

## 分层总览

```
app   (接线层)     qt-assistant.lua            # setup / keymaps / 懒加载接线
                   plugin/qt-assistant.lua     # 全部 :Qt* 用户命令注册
core  (逻辑层)     lua/qt-assistant/core/*.lua # 纯逻辑, 不持有 UI
ui    (展示层)     lua/qt-assistant/ui/init.lua# 窗口界面 / 信息展示
data  (模板数据)   templates/*.tmpl            # 纯文本模板, 可被宿主覆盖
tests              tests/run.lua               # headless 回归
```

依赖方向：`app → core → config`；`core → (core.class / core.templates / core.system)`；`ui → core`。
**core 不依赖 ui**，保证逻辑可 headless 测试。

## core/ 模块地图

| 模块 | 职责 | 备注 |
| --- | --- | --- |
| `core/config.lua` | 配置默认值/校验/读写 (`get/set_value`) | 所有可调项的唯一入口 |
| `core/toolchain.lua` | Qt 工具链探测 + 广播 + 宿主选择/持久化 | `:QtSelectKit` `:QtKitList`；详见 [TOOLCHAIN.md](TOOLCHAIN.md) |
| `core/discovery` … | （探测逻辑已并入 toolchain） | — |
| `core/project_manager.lua` | 工程创建/打开/多模块 | `:QtNewProject` 系列 |
| `core/build_manager.lua` | 构建调度（CMake/qmake/xmake 三系统分发） | `:QtBuild` 系列 |
| `core/cmake.lua` | CMakePresets 生成、CMakeLists 格式化/备份/追加源文件 | `:QtCMakePresets` 等 |
| `core/class.lua` | 类生成流程（模板 + 文件 + CMake 联动） | 原 `core.lua`；`:QtCreateClass` |
| `core/templates.lua` | 模板加载器 + 渲染引擎 + 宿主自定义解析链 | 详见 [TEMPLATES.md](TEMPLATES.md) |
| `core/designer.lua` | Qt Designer / .ui 文件操作 | `:QtDesigner` 系列 |
| `core/file_manager.lua` | 目标目录决策与文件落盘 | |
| `core/scripts.lua` | 工程脚本管理（内置 + 宿主覆盖） | `:QtScripts` |
| `core/lsp.lua` | clangd/compile_commands 辅助 | |
| `core/debug.lua` | nvim-dap 集成与适配器探测 | `:QtDebug` 系列 |
| `core/history.lua` | 最近工程记录 | |
| `core/system.lua` | 平台判断、路径拼接、外部进程 | |

## ui/ 模块地图

`ui/init.lua` 提供所有弹窗/界面（主界面、类创建器、脚本管理器、构建状态等）。
原则：ui 只负责**呈现**，业务结果由 core 返回值驱动。

## data/ 模板

`templates/*.tmpl` 为纯文本模板（56 个），占位符语法 `{{VAR}}`、`{{#VAR}}...{{/VAR}}`、`{{^VAR}}...{{/VAR}}`。
宿主可用 `config.templates.custom_dir/override` 或 `M.register_template()` 覆盖任意模板，详见 [TEMPLATES.md](TEMPLATES.md)。

## require 约定

- core 内部互引：`require('qt-assistant.core.xxx')`
- ui 引用 core：`require('qt-assistant.core.xxx')`
- 引用 ui：`require('qt-assistant.ui')`（`ui/init.lua`）
- 主模块：`require('qt-assistant')`

新增 core 模块时同步更新本表与 `tests/run.lua` 的模块清单。
