# Templates & host customization

> **English** | [简体中文](TEMPLATES.zh-CN.md)

> Template data is no longer embedded in Lua (the old `templates.lua` exceeded 100KB).
> It now lives in `templates/*.tmpl` at the repo root — **plain text, directly editable** —
> and a host customization API is exposed.

## Directory & naming

```
templates/
├── cmake_widget_app.tmpl        # CMakeLists.txt for widget projects
├── cmake_console_app.tmpl
├── cmake_multi_project.tmpl
├── main_qml.tmpl                # Quick/QML entry
├── qml_qrc.tmpl
├── main_window_header.tmpl      # class templates (header/source/ui)
├── main_window_source.tmpl
├── main_window_ui.tmpl
├── calculator_header.tmpl       # built-in sample classes
├── doc_project_guide.tmpl       # documentation templates
└── ... (56 files)
```

Naming: `<purpose>.tmpl`. Template name = file name without `.tmpl`.

## Placeholder syntax

| Syntax | Behavior |
| --- | --- |
| `{{VAR}}` | replaced by `variables.VAR` |
| `{{#VAR}}…{{/VAR}}` | block kept when `variables.VAR` is truthy, otherwise removed |
| `{{^VAR}}…{{/VAR}}` | inverted conditional block |

Example (`main_window_header.tmpl` excerpt):

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

## Host customization API (priority high → low)

### 1. Runtime registration (Lua API)

```lua
local templates = require('qt-assistant.core.templates')
templates.register_template('cmake_widget_app', [[your custom CMakeLists ...]])
```

### 2. Per-template file override

```lua
require('qt-assistant').setup({
    templates = {
        override = {
            cmake_widget_app = 'C:/my-templates/CMakeLists.txt.tmpl',
        },
    },
})
```

### 3. Host template directory (directory-wide override)

```lua
require('qt-assistant').setup({
    templates = {
        custom_dir = 'C:/my-templates/',   -- <template>.tmpl overrides same-name built-ins
    },
})
```

Companion commands: `:QtTemplatesOpenCustomDir` (open the dir in Explorer) and
`:QtTemplatesReload` (reload built-ins).

Un-overridden templates automatically fall back to the built-in `templates/` directory —
you only provide the files you actually want to change.

## Code contract

- `core/templates.lua` only **loads and renders**; it contains no business logic;
- `core/project_manager.lua` / `core/class.lua` consume via `render_template(name, variables)`;
- Adding a template: drop `<name>.tmpl` into `templates/`, then call
  `render_template('<name>', vars)`;
- If you change the render syntax or add functions, update `tests/run.lua` and run the suite.

## Migration notes

Since v20.x all built-in templates are data files (56 `.tmpl`), and the rendered output is
**byte-identical** to the old embedded version (verified by an automated comparison).
If you previously edited strings inside `templates.lua`, migrate those changes to the
matching `.tmpl` file or use the override API.
