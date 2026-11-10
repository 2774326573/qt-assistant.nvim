# 模板系统与宿主自定义

> **简体中文** | [English](TEMPLATES.md)

> 模板数据不再内嵌在 Lua 里（原 `templates.lua` 超过 100KB），已拆分到仓库根目录 `templates/*.tmpl` —— **纯文本、可直接编辑**，并开放宿主自定义接口。

## 目录与命名

```
templates/
├── cmake_widget_app.tmpl        # widget 工程 CMakeLists.txt
├── cmake_console_app.tmpl
├── cmake_multi_project.tmpl
├── main_qml.tmpl                # Quick/QML 入口
├── qml_qrc.tmpl
├── main_window_header.tmpl      # 类模板 (header/source/ui)
├── main_window_source.tmpl
├── main_window_ui.tmpl
├── calculator_header.tmpl       # 等内置示例类
├── doc_project_guide.tmpl       # 文档生成模板
└── ... (共 56 个)
```

命名规则：`<用途>.tmpl`。模板名 = 文件名去掉 `.tmpl`。

## 占位符语法

| 语法 | 行为 |
| --- | --- |
| `{{VAR}}` | 替换为 `variables.VAR` |
| `{{#VAR}}…{{/VAR}}` | `variables.VAR` 为真时保留块内容，否则删除 |
| `{{^VAR}}…{{/VAR}}` | 取反条件块 |

示例（`main_window_header.tmpl` 片段）：

```cpp
#ifndef {{HEADER_GUARD}}
#define {{HEADER_GUARD}}
{{#HAS_UI_FILE}}
QT_BEGIN_NAMESPACE
class Ui_{{UI_CLASS_NAME}};
QT_END_NAMESPACE
{{/HAS_UI_FILE}}
class {{CLASS_NAME}} : public QMainWindow { ... };
```

## 宿主自定义接口（优先级高 → 低）

### 1. 运行时注册（Lua API）

```lua
local templates = require('qt-assistant.core.templates')
templates.register_template('cmake_widget_app', [[自定义 CMakeLists 内容 ...]])
```

### 2. 单模板文件覆盖

```lua
require('qt-assistant').setup({
    templates = {
        override = {
            cmake_widget_app = 'C:/my-templates/CMakeLists.txt.tmpl',
        },
    },
})
```

### 3. 宿主模板目录（整目录覆盖）

```lua
require('qt-assistant').setup({
    templates = {
        custom_dir = 'C:/my-templates/',   -- 其内 <模板名>.tmpl 覆盖同名内置
    },
})
```

配套命令：`:QtTemplatesOpenCustomDir` 用资源管理器打开；`:QtTemplatesReload` 重载内置模板。

未覆盖的模板自动回退到内置 `templates/` 目录 —— 你只需要放想改的那几个文件。

## 与代码的约定

- `core/templates.lua` 只做 **加载 + 渲染**，不含业务；
- `core/project_manager.lua` / `core/class.lua` 通过 `render_template(name, variables)` 消费；
- 新增模板：在 `templates/` 放 `<name>.tmpl`，即可用 `render_template('<name>', vars)`；
- 修改渲染语法/新增函数请同步更新 `tests/run.lua` 并跑回归。

## 迁移说明

v20.x 起内置模板全部数据化（56 个 `.tmpl`），渲染结果与旧内嵌版本**逐字节一致**（有自动化对比验证）。
若你曾直接修改过 `templates.lua` 里的字符串，请把改动迁移到对应的 `.tmpl` 文件或使用 override 接口。
