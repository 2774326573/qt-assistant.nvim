# Qt Assistant Keybindings Guide

## 概述

Qt Assistant 提供了完整的快捷键系统，与最新的 C++ 标准支持功能完全集成。所有快捷键默认启用，使用 `<leader>q` 作为前缀。

## 快捷键映射总览

### 核心功能
| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qa` | Qt Assistant | 打开主界面 |
| `<leader>qh` | Qt Help | 显示帮助信息 |

### 项目管理
| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qp` | 新建项目 (交互式) | 支持 C++ 标准选择 |
| `<leader>qP` | 快速新建项目 | C++17 Widget 应用 |
| `<leader>qo` | 打开项目 | 浏览并打开现有项目 |

### UI 设计器
| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qd` | Qt Designer | 打开 Qt Designer |
| `<leader>qu` | 新建 UI 文件 | 创建新的界面文件 |
| `<leader>qe` | 编辑 UI | 编辑当前/选择 UI 文件 |

### 类创建
| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qc` | 创建类 (交互式) | 智能类生成向导 |
| `<leader>qf` | 从 UI 创建类 | 基于当前 UI 文件生成类 |

### 构建系统 (支持 C++ 标准)
| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qb` | 构建项目 | 使用默认配置构建 |
| `<leader>qb1` | **C++11 构建** | 使用 C++11 标准构建 |
| `<leader>qb4` | **C++14 构建** | 使用 C++14 标准构建 |
| `<leader>qb7` | **C++17 构建** | 使用 C++17 标准构建 |
| `<leader>qb20` | **C++20 构建** | 使用 C++20 标准构建 |
| `<leader>qr` | 运行项目 | 执行构建后的应用程序 |
| `<leader>qq` | 快速构建运行 | 一键构建并运行 |

### 配置和标准管理 (新增)
| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qsc` | **显示当前配置** | 查看 C++ 标准、Qt 版本等 |
| `<leader>qss` | **选择 C++ 标准** | 交互式选择 C++ 标准 |
| `<leader>qsr` | **重新配置项目** | 清理并重新配置 |

### LSP 集成
| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qls` | 设置 Qt LSP | 配置 clangd 支持 |
| `<leader>qlg` | 生成编译命令 | 生成 compile_commands.json |
| `<leader>qlt` | LSP 状态 | 显示 LSP 服务状态 |

### 调试系统
| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qdb` | 调试应用 | 启动 Qt 应用调试 |
| `<leader>qda` | 附加到进程 | 附加调试器到 Qt 进程 |

## 使用场景示例

### 快速开发工作流

#### 1. 创建新项目
```vim
<leader>qP          " 快速创建 C++17 项目
" 或
<leader>qp          " 交互选择项目类型和 C++ 标准
```

#### 2. 开发过程
```vim
<leader>qd          " 打开 Qt Designer 设计界面
<leader>qc          " 创建新的 Qt 类
<leader>qf          " 从 UI 文件生成对应的类
```

#### 3. 构建测试
```vim
<leader>qb7         " 使用 C++17 构建
<leader>qr          " 运行应用程序
" 或
<leader>qq          " 一键构建并运行
```

#### 4. 配置管理
```vim
<leader>qsc         " 查看当前项目配置
<leader>qss         " 切换 C++ 标准
<leader>qsr         " 重新配置项目
```

### 不同 C++ 标准的构建

#### C++11 项目 (兼容性优先)
```vim
<leader>qb1         " 使用 C++11 构建
```
- 适用于需要支持老旧系统的项目
- Qt5 完全支持
- MSVC 2015+ 支持

#### C++17 项目 (推荐)
```vim
<leader>qb7         " 使用 C++17 构建
```
- 现代 C++ 特性
- Qt5/Qt6 都支持
- 最佳兼容性

#### C++20 项目 (现代特性)
```vim
<leader>qb20        " 使用 C++20 构建
```
- 最新 C++ 特性
- Qt6 推荐
- VS2022+ / GCC 10+ 支持

### 项目配置查看

#### 查看当前配置
```vim
<leader>qsc
```
显示浮动窗口：
```
=== Qt Project Configuration ===

C++ Standard: C++17
Qt Version: 6.8.1
Build Type: Debug

Project Root: /path/to/project
```

#### 切换 C++ 标准
```vim
<leader>qss
```
显示选择菜单：
```
Select C++ Standard:
1. C++11 (Qt5 compatible)
2. C++14 (Qt5 compatible)
3. C++17 (Qt5/Qt6 compatible, recommended)
4. C++20 (Modern C++, Qt6 preferred)
5. C++23 (Latest standard)
```

## 文件类型特定快捷键

### UI 文件 (.ui)
当编辑 `.ui` 文件时，额外可用：
| 快捷键 | 功能 |
|--------|------|
| `<leader>gd` | 在 Designer 中打开 |
| `<leader>gc` | 生成对应的 C++ 类 |

### C++ 文件 (.h/.cpp)
当编辑 C++ 文件时，额外可用：
| 快捷键 | 功能 |
|--------|------|
| `<leader>gu` | 查找并打开关联的 UI 文件 |

## 自定义配置

### 启用默认快捷键
```lua
require('qt-assistant').setup({
    enable_default_keymaps = true  -- 默认启用
})
```

### 手动设置快捷键
```lua
require('qt-assistant').setup({
    enable_default_keymaps = false
})

-- 手动设置部分快捷键
require('qt-assistant').setup_keymaps()
```

### 自定义快捷键
```lua
vim.keymap.set('n', '<leader>qt', '<cmd>QtAssistant<cr>', { desc = 'Qt Assistant' })

-- C++ 标准特定构建
vim.keymap.set('n', '<F5>', function()
    require('qt-assistant').build_with_std("17")
end, { desc = 'Build with C++17' })

-- 配置查看
vim.keymap.set('n', '<F6>', function()
    require('qt-assistant').show_current_config()
end, { desc = 'Show Qt Config' })
```

## 提示和技巧

### 1. 快速记忆
- `<leader>q` + 功能首字母
- `<leader>qb` + 数字 = C++ 标准构建
- `<leader>qs` + 字母 = 设置/配置

### 2. 工作流优化
- 使用 `<leader>qP` 快速创建标准项目
- 使用 `<leader>qq` 快速构建运行
- 使用 `<leader>qsc` 随时查看项目状态

### 3. C++ 标准选择
- C++11/14: 用于兼容性
- C++17: 推荐的平衡选择
- C++20+: 现代特性开发

### 4. 键盘优先
- 所有功能都可通过键盘快捷键访问
- 浮动窗口支持 `q` 或 `Esc` 快速关闭
- 交互选择支持数字键快速选择

## 故障排除

### 快捷键不工作
1. 检查 `enable_default_keymaps = true`
2. 确认没有键位冲突
3. 手动调用 `setup_keymaps()`

### 构建快捷键失败
1. 确认在 Qt 项目根目录
2. 检查 Windows 脚本是否存在
3. 验证 CMake 和编译器配置

### 配置显示错误
1. 确认项目已构建过
2. 检查 `build/CMakeCache.txt` 存在
3. 重新运行构建命令

通过这套完整的快捷键系统，你可以完全通过键盘高效地进行 Qt 开发，无需鼠标操作！