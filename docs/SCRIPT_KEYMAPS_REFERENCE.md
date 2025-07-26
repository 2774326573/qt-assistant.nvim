# Qt Assistant 快捷键参考

此文档包含所有 Qt Assistant 插件的快捷键映射和命令参考。

**版本**: v1.2.0  
**最后更新**: 2025-07-26

## 脚本执行快捷键

| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qsb` | Script Build | 执行构建脚本 |
| `<leader>qsr` | Script Run | 执行运行脚本 |
| `<leader>qsd` | Script Debug | 执行调试脚本 |
| `<leader>qsc` | Script Clean | 执行清理脚本 |
| `<leader>qst` | Script Test | 执行测试脚本 |
| `<leader>qsp` | Script Deploy | 执行部署脚本 |

## 脚本管理快捷键

| 快捷键 | 功能 | 描述 |
|--------|------|------|
| `<leader>qsa` | Generate All Scripts | 一键生成所有脚本 |
| `<leader>qsg` | Generate Scripts | 生成项目脚本 |
| `<leader>qsG` | Script Generator | 交互式脚本生成器 |

## 对应的 Vim 命令

| 快捷键 | Vim 命令 | 说明 |
|--------|----------|------|
| `<leader>qsb` | `:QtScript build` | 运行构建脚本 |
| `<leader>qsr` | `:QtScript run` | 运行项目 |
| `<leader>qsd` | `:QtScript debug` | 调试项目 |
| `<leader>qsc` | `:QtScript clean` | 清理项目 |
| `<leader>qst` | `:QtScript test` | 运行测试 |
| `<leader>qsp` | `:QtScript deploy` | 部署项目 |
| `<leader>qsa` | `:QtGenerateAllScripts` | 生成所有脚本 |
| `<leader>qsg` | `:QtGenerateScripts` | 生成项目脚本 |
| `<leader>qsG` | `:QtScriptGenerator` | 脚本生成器 |

## 系统信息快捷键

| 快捷键 | Vim 命令 | 说明 |
|--------|----------|------|
| `<leader>qis` | `:QtSystemInfo` | 显示系统信息 |
| `<leader>qik` | `:QtKeymaps` | 显示快捷键映射 |

## 基础操作快捷键

| 快捷键 | Vim 命令 | 说明 |
|--------|----------|------|
| `<leader>qc` | `:QtAssistant` | 打开主界面 |
| `<leader>qh` | `:help qt-assistant` | 显示帮助文档 |

## 类创建快捷键

| 快捷键 | Vim 命令 | 说明 |
|--------|----------|------|
| `<leader>qcc` | `:QtQuickClass` | 快速类创建器 |
| `<leader>qcw` | `:QtCreateMainWindow` | 创建主窗口类 |
| `<leader>qcd` | `:QtCreateDialog` | 创建对话框类 |
| `<leader>qcv` | `:QtCreateWidget` | 创建控件类 |
| `<leader>qcm` | `:QtCreateModelClass` | 创建模型类 |

## 项目管理快捷键

| 快捷键 | Vim 命令 | 说明 |
|--------|----------|------|
| `<leader>qpo` | `:QtSmartSelector` | 智能项目选择器 |
| `<leader>qpm` | `:QtProjectManager` | 项目管理器 |
| `<leader>qpc` | `:QtChooseProject` | 选择项目 |
| `<leader>qpw` | `:QtQuickSwitcher` | 快速项目切换 |
| `<leader>qpr` | `:QtRecentProjects` | 最近项目 |
| `<leader>qps` | `:QtSearchProjects` | 搜索项目 |
| `<leader>qpg` | `:QtGlobalSearch` | 全局搜索 |

## 构建管理快捷键

| 快捷键 | Vim 命令 | 说明 |
|--------|----------|------|
| `<leader>qb` | `:QtBuildProject` | 构建项目 |
| `<leader>qr` | `:QtRunProject` | 运行项目 |
| `<leader>qcl` | `:QtCleanProject` | 清理项目 |
| `<leader>qbs` | `:QtBuildStatus` | 构建状态 |

## UI设计师快捷键

| 快捷键 | Vim 命令 | 说明 |
|--------|----------|------|
| `<leader>qud` | `:QtOpenDesigner` | 打开设计师 |
| `<leader>quc` | `:QtOpenDesignerCurrent` | 打开当前文件设计师 |
| `<leader>qum` | `:QtDesignerManager` | 设计师管理器 |

## 典型工作流程

### 首次使用
1. `<leader>qsa` - 生成所有项目脚本
2. `<leader>qsb` - 构建项目
3. `<leader>qsr` - 运行项目

### 日常开发
1. `<leader>qsb` - 构建项目
2. `<leader>qsr` - 运行项目
3. `<leader>qsd` - 调试问题
4. `<leader>qst` - 运行测试
5. `<leader>qsc` - 清理临时文件

### 项目部署
1. `<leader>qsb` - 最终构建
2. `<leader>qst` - 运行测试确保质量
3. `<leader>qsp` - 部署项目

## 记忆技巧

快捷键采用助记符设计：
- `qs` = **Q**t **S**cript
- `b` = **B**uild (构建)
- `r` = **R**un (运行)
- `d` = **D**ebug (调试)
- `c` = **C**lean (清理)
- `t` = **T**est (测试)
- `p` = De**p**loy (部署)
- `a` = **A**ll (全部生成脚本)
- `g` = **G**enerate (生成脚本)
- `G` = **G**enerator (交互式生成器)
- `qi` = **Q**t **I**nfo (系统信息)
- `s` = **S**ystem (系统)
- `k` = **K**eymaps (快捷键)

## 脚本位置

所有生成的脚本位于项目的 `scripts/` 目录下：

### Unix/Linux/macOS
- `scripts/build.sh`
- `scripts/run.sh`
- `scripts/debug.sh`
- `scripts/clean.sh`
- `scripts/test.sh`
- `scripts/deploy.sh`

### Windows
- `scripts/build.bat`
- `scripts/run.bat`
- `scripts/debug.bat`
- `scripts/clean.bat`
- `scripts/test.bat`
- `scripts/deploy.bat`

## 注意事项

1. **首次使用**：运行 `<leader>qsa` 生成脚本后才能使用执行快捷键
2. **权限设置**：Unix 系统会自动设置脚本执行权限
3. **错误处理**：脚本执行失败时会显示详细错误信息
4. **终端输出**：脚本在 Neovim 终端中运行，可以看到实时输出
5. **项目检测**：脚本会自动检测项目名称和 Qt 版本

## 故障排除

### 常见问题

#### 1. 快捷键不工作
- **症状**：按快捷键没有反应
- **解决方案**：
  - 检查 `<leader>` 键设置（通常是 `\` 或空格）
  - 确认插件已正确加载：`:lua print(vim.g.loaded_qt_assistant)`
  - 重启 Neovim 并重新加载配置

#### 2. 系统信息显示错误
- **症状**：执行 `<leader>qis` 报错 "attempt to concatenate field 'hostname' (a nil value)"
- **状态**：✅ 已修复 (v1.2.0)
- **说明**：系统信息函数已添加 nil 值保护

#### 3. 主界面循环依赖错误
- **症状**：执行 `<leader>qc` 报错 "loop or previous error loading module 'qt-assistant.core'"
- **状态**：✅ 已修复 (v1.2.0) 
- **说明**：UI 模块已重构避免循环依赖

#### 4. 脚本快捷键缺失
- **症状**：`<leader>qsc`, `<leader>qst`, `<leader>qsp`, `<leader>qsa` 不工作
- **状态**：✅ 已修复 (v1.2.0)
- **说明**：已添加所有缺失的脚本管理快捷键

### 获取帮助

- 使用 `<leader>qh` 查看内置帮助
- 使用 `<leader>qik` 查看所有快捷键映射
- 使用 `<leader>qis` 查看系统信息和工具状态

### 版本历史

- **v1.2.0** (2025-07-26): 修复循环依赖和快捷键问题
- **v1.1.0**: 添加脚本管理功能
- **v1.0.0**: 初始版本