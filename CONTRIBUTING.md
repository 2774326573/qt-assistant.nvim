# 贡献指南 / Contributing Guide

感谢您对Qt Assistant项目的关注！我们欢迎各种形式的贡献。

## 🤝 如何贡献

### 报告问题 / Reporting Issues
- 使用GitHub Issues报告bug或提出功能请求
- 提供详细的错误信息和复现步骤
- 包含您的系统信息（OS、Neovim版本等）

### 提交代码 / Code Contributions
1. Fork这个仓库
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -am 'Add some feature'`
4. 推送到分支：`git push origin feature/your-feature`
5. 创建Pull Request

## 📋 开发准备

### 环境要求
- Neovim 0.8+
- Lua 5.1+
- Git
- Qt开发环境（用于测试）

### 设置开发环境
```bash
# 克隆仓库
git clone https://github.com/onewu867/qt-assistant.nvim.git
cd qt-assistant.nvim

# 在Neovim配置中添加本地路径
# 在你的init.lua中添加：
vim.opt.rtp:prepend("path/to/qt-assistant.nvim")
```

### 测试
```bash
# 运行语法检查和基础测试
./scripts/test.sh

# 手动测试
nvim test.cpp
:QtAssistant
```

## 🎯 开发指南

### 代码规范
- 使用一致的缩进（2个空格）
- 为函数和模块添加注释
- 遵循现有的代码风格
- 变量和函数使用snake_case命名

### 模块结构
```
lua/qt-assistant/
├── init.lua          # 主入口
├── core.lua          # 核心功能
├── templates.lua     # 模板系统
├── file_manager.lua  # 文件管理
├── cmake.lua         # CMake集成
├── ui.lua            # 用户界面
├── project_manager.lua # 项目管理
├── build_manager.lua # 构建管理
├── designer.lua      # UI设计师集成
├── scripts.lua       # 脚本管理
└── system.lua        # 系统检测
```

### 添加新功能
1. 在相应模块中实现功能
2. 更新main `init.lua`文件
3. 添加相应的命令和快捷键
4. 更新文档
5. 添加测试用例

### 添加新模板
1. 在`templates.lua`中添加模板定义
2. 支持变量替换：`{{CLASS_NAME}}`, `{{FILE_NAME}}`等
3. 支持条件语句：`{{#CONDITION}}...{{/CONDITION}}`
4. 测试模板生成

## 📚 文档贡献

### 更新文档
- README.md - 主要文档
- doc/qt-assistant.txt - Vim帮助文档
- CHANGELOG.md - 变更日志
- 示例配置文件

### 文档规范
- 使用中英文双语
- 提供清晰的示例
- 保持格式一致
- 及时更新版本信息

## 🔍 测试指南

### 测试清单
- [ ] 基本功能测试
- [ ] 跨平台兼容性
- [ ] 错误处理
- [ ] 边界情况
- [ ] 性能测试

### 手动测试步骤
1. 创建测试项目
2. 测试类创建功能
3. 测试构建功能
4. 测试UI设计师集成
5. 测试脚本管理
6. 测试跨平台功能

## 🐛 调试技巧

### 启用调试模式
```lua
require('qt-assistant').setup({
    debug = {
        enabled = true,
        log_level = "DEBUG"
    }
})
```

### 查看日志
```vim
:e ~/.local/share/nvim/qt-assistant.log
```

### 常见问题
- 模块加载错误：检查lua路径
- 命令不存在：检查插件是否正确加载
- 构建失败：检查Qt环境和构建工具

## 🚀 发布流程

### 版本号规范
使用语义化版本：`MAJOR.MINOR.PATCH`
- MAJOR：不兼容的API更改
- MINOR：向后兼容的功能添加
- PATCH：向后兼容的问题修复

### 发布步骤
1. 更新VERSION文件
2. 更新CHANGELOG.md
3. 运行测试：`./scripts/test.sh`
4. 创建发布包：`./scripts/release.sh`
5. 创建Git标签
6. 创建GitHub Release

## 📞 联系方式

- GitHub Issues：提交bug报告和功能请求
- 邮件：[你的邮箱]
- 讨论：GitHub Discussions

## 📜 许可证

本项目采用MIT许可证。贡献代码即表示您同意您的贡献将在MIT许可证下发布。

---

再次感谢您的贡献！🎉
EOF < /dev/null