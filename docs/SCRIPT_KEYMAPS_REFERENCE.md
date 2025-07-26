# Qt Assistant 脚本快捷键参考

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