# Qt Assistant v1.1.0 安装指南

## 📦 快速安装

### 使用 lazy.nvim (推荐)

```lua
{
    'onewu867/qt-assistant.nvim',
    version = 'v1.1.0',
    ft = {'cpp', 'c', 'cmake'},
    cmd = {
        'QtAssistant', 'QtCreateClass', 'QtCreateUI', 'QtCreateModel',
        'QtSmartSelector', 'QtChooseProject', 'QtQuickSwitcher', 'QtGlobalSearch',
        'QtSearchProjects', 'QtRecentProjects', 'QtOpenProject', 'QtNewProject',
        'QtProjectManager', 'QtBuildProject', 'QtRunProject', 'QtCleanProject',
        'QtOpenDesigner', 'QtDesignerManager', 'QtSystemInfo'
    },
    config = function()
        require('qt-assistant').setup({
            enable_default_keymaps = true,
            global_search = {
                enabled = true,
                max_depth = 3,
                include_system_paths = true,
                custom_search_paths = {},
                exclude_patterns = {
                    "node_modules", ".git", ".vscode", 
                    "build", "target", "dist", "out"
                }
            }
        })
    end
}
```

### 使用 packer.nvim

```lua
use {
    'onewu867/qt-assistant.nvim',
    tag = 'v1.1.0',
    config = function()
        require('qt-assistant').setup()
    end
}
```

### 手动安装

1. 下载 `qt-assistant-v1.1.0.zip` 解压到 Neovim 插件目录
2. 在配置文件中添加：
```lua
require('qt-assistant').setup()
```

## 🚀 新功能快速体验

### 全局项目搜索
```vim
:QtGlobalSearch
# 或使用快捷键
<leader>qpg
```

### 快速项目切换
```vim
:QtQuickSwitcher
# 或使用快捷键
<leader>qpw
```

### 智能项目选择器
```vim
:QtSmartSelector
# 或使用快捷键
<leader>qpo
```

## 📋 v1.1.0 新增快捷键

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<leader>qpo` | 智能项目打开 | 自动搜索并打开最相关的项目 |
| `<leader>qpc` | 手动项目选择 | 从所有找到的项目中手动选择 |
| `<leader>qpw` | 快速项目切换 | 在最近项目间快速切换 |
| `<leader>qpg` | 全局项目搜索 | 搜索所有驱动器中的Qt项目 |
| `<leader>qps` | 本地项目搜索 | 在当前目录及其子目录中搜索 |
| `<leader>qpr` | 最近项目列表 | 显示最近访问的项目 |

## ⚙️ 配置说明

### 全局搜索配置 (新增)

```lua
global_search = {
    enabled = true,                    -- 启用全局搜索
    max_depth = 3,                     -- 最大搜索深度
    include_system_paths = true,       -- 包含系统路径
    custom_search_paths = {            -- 自定义搜索路径
        "/path/to/your/projects",
        "D:\\MyProjects"  -- Windows 示例
    },
    exclude_patterns = {               -- 排除模式
        "node_modules", ".git", ".vscode", 
        "build", "target", "dist", "out",
        "__pycache__", ".cache", "tmp", "temp"
    }
}
```

## 🔄 从 v1.0.0 升级

### 自动升级
如果使用包管理器，更新插件版本即可：

```lua
-- lazy.nvim
version = 'v1.1.0'

-- packer.nvim  
tag = 'v1.1.0'
```

### 配置兼容性
- ✅ 所有 v1.0.0 配置选项完全兼容
- ✅ 所有现有快捷键继续工作
- ✅ 新功能为可选，不影响现有工作流程

### 快捷键变更
- ❌ `<leader>qp` 已删除（功能重复）
- ✅ 使用 `<leader>qpo` 代替
- ✅ 新增多个项目搜索快捷键

## ⚠️ 注意事项

1. **首次使用全局搜索**: 第一次运行可能需要较长时间建立索引
2. **性能考虑**: 可通过 `max_depth` 和 `exclude_patterns` 优化搜索性能
3. **权限要求**: 全局搜索需要读取文件系统权限
4. **存储空间**: 最近项目列表存储在 `~/.local/share/nvim/qt-assistant-recent-projects.json`

## 🐛 故障排除

### 全局搜索问题
```lua
-- 如果搜索过慢，降低搜索深度
global_search = {
    max_depth = 2,  -- 减少到2层
}

-- 如果搜索结果太多，增加排除模式
exclude_patterns = {
    "node_modules", ".git", ".vscode", 
    "build", "target", "dist", "out",
    "vendor", "third_party"  -- 添加更多排除项
}
```

### 权限问题
确保 Neovim 有权限访问搜索路径：
```bash
# Linux/macOS
ls -la /path/to/search

# Windows - 以管理员身份运行 Neovim（如需要）
```

## 📞 支持

- 问题反馈: [GitHub Issues](https://github.com/onewu867/qt-assistant.nvim/issues)
- 功能请求: [GitHub Discussions](https://github.com/onewu867/qt-assistant.nvim/discussions)
- 文档: [README.md](README.md)

---

**祝愿Qt开发愉快！** 🎉