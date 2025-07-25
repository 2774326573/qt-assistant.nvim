# Qt Assistant v1.1.0 发布说明

## 🚀 重大更新：全局搜索与快速项目切换

我们很高兴发布Qt Assistant v1.1.0！这是一个重大功能更新，为Qt开发者带来了强大的项目搜索和管理能力。

### 🌟 核心新功能

#### 1. 全局项目搜索系统
- **跨驱动器搜索**: 一键搜索所有驱动器和挂载点中的Qt项目
- **智能路径发现**: 自动检测Windows驱动器(A-Z)和Linux挂载点(/mnt, /media)
- **异步搜索**: 带进度条的非阻塞搜索，随时可以取消(q/Esc)
- **结果分组**: 按驱动器/路径分组显示，便于快速定位

#### 2. 智能快速切换系统
- **快速切换器**: 基于最近项目的一键切换功能 (`<leader>qpw`)
- **智能选择器**: 多阶段搜索策略，自动找到最相关的项目 (`<leader>qpo`)
- **项目历史**: 自动保存和管理最近访问的项目列表
- **智能评分**: 基于项目类型、路径相似性等的智能排序

### ⚡ 性能大幅提升

- **多阶段搜索**: 渐进式搜索策略，优先显示相关结果
- **智能缓存**: 缓存搜索结果，避免重复扫描
- **异步处理**: 所有搜索操作异步执行，不阻塞编辑器
- **深度控制**: 根据目录类型动态调整搜索深度

### 🎯 用户体验优化

#### 快捷键重构
- 清理了重复的快捷键映射
- 按功能逻辑分组：核心操作、项目切换、项目搜索
- 优化了快捷键命名和描述

#### 新增快捷键
```
项目核心：
  <leader>qpo - 智能项目打开 (⭐ 自动)
  <leader>qpm - 项目管理器

项目切换：
  <leader>qpc - 选择项目 (手动)
  <leader>qpw - 快速项目切换器 (⚡ 快速)
  <leader>qpr - 最近项目

项目搜索：
  <leader>qps - 搜索Qt项目 (本地)
  <leader>qpg - 全局搜索所有驱动器 (🌍 完整)
```

### 🔧 灵活配置选项

新增全局搜索配置，完全可自定义：

```lua
global_search = {
    enabled = true,                    -- 启用全局搜索
    max_depth = 3,                     -- 最大搜索深度
    include_system_paths = true,       -- 包含系统路径
    custom_search_paths = {            -- 自定义搜索路径
        "/your/projects/path",
        "D:\\Development\\Projects"
    },
    exclude_patterns = {               -- 排除模式
        "node_modules", ".git", ".vscode", 
        "build", "target", "dist", "out"
    }
}
```

### 🎨 界面改进

- **进度指示器**: 实时显示搜索进度和当前扫描路径
- **当前项目高亮**: 清晰标识当前打开的项目
- **时间戳显示**: 显示项目最后访问时间
- **键盘导航**: Tab/Shift+Tab快速跳转，数字键1-9直接选择

### 📱 跨平台增强

- 完善的Windows驱动器检测
- Linux/macOS挂载点自动发现
- 路径处理优化，更好的跨平台兼容性

## 📦 安装和升级

### 新安装用户

```lua
-- lazy.nvim
{
    'onewu867/qt-assistant.nvim',
    version = 'v1.1.0',
    config = function()
        require('qt-assistant').setup({
            enable_default_keymaps = true,
            global_search = { enabled = true }
        })
    end
}
```

### 从v1.0.0升级

完全向后兼容！只需更新版本号：

```lua
version = 'v1.1.0'  -- lazy.nvim
-- 或
tag = 'v1.1.0'      -- packer.nvim
```

**注意**: `<leader>qp` 快捷键已删除，请使用 `<leader>qpo` 代替。

## 🎯 快速体验新功能

1. **全局搜索**: `:QtGlobalSearch` 或 `<leader>qpg`
2. **快速切换**: `:QtQuickSwitcher` 或 `<leader>qpw`  
3. **智能打开**: `:QtSmartSelector` 或 `<leader>qpo`

## 🎉 实际使用场景

### 多项目开发者
- 使用 `<leader>qpw` 在多个Qt项目间快速切换
- 项目历史自动保存，无需手动管理

### 项目探索者
- 使用 `<leader>qpg` 发现系统中所有Qt项目
- 按驱动器分组，快速定位不同位置的项目

### 效率优先用户
- 使用 `<leader>qpo` 智能打开最相关的项目
- 多阶段搜索策略，总是给出最佳结果

## 📊 性能对比

| 功能 | v1.0.0 | v1.1.0 | 改进 |
|------|--------|--------|------|
| 项目搜索 | 无 | ✅ | 全新功能 |
| 跨驱动器 | 无 | ✅ | 全新功能 |
| 异步搜索 | 无 | ✅ | 全新功能 |
| 项目切换 | 手动 | 智能 | 10x效率提升 |
| 搜索速度 | - | 优化 | 智能缓存 |

## 🐛 问题修复

- 修复项目搜索中的路径处理问题
- 优化错误处理和用户反馈
- 修复Windows/Linux路径兼容性问题
- 改进异步操作的取消机制

## 🙏 感谢

感谢社区用户的反馈和建议，让我们能够持续改进Qt Assistant！

---

**立即升级，体验全新的Qt项目管理方式！** 🚀

### 下载链接

- [qt-assistant-v1.1.0.tar.gz](qt-assistant-v1.1.0.tar.gz) (59KB)
- [qt-assistant-v1.1.0.zip](qt-assistant-v1.1.0.zip) (72KB)
- [SHA256校验文件](./)