# 变更日志 / Changelog

本文档记录了Qt Assistant插件的所有重要变更。

## [1.0.0] - 2025-07-25

### 🔧 重要修复 / Critical Fixes
- **循环依赖问题修复**: 完全解决了模块间的循环依赖问题，提升插件稳定性和加载性能
  - 创建独立配置管理器 (`qt-assistant/config.lua`)
  - 重构主模块，采用内联配置管理避免循环依赖
  - 修复plugin入口，使用延迟加载机制
  - 更新所有子模块，使用新的配置管理器
  - **保持配置接口兼容**: 主模块的 `setup()` 函数保持可用，配置选项完全兼容

- **Init.lua模块冲突修复**: 解决了导致setup函数不可用的关键问题
  - 移除冲突的 `lua/qt-assistant/init.lua` 文件
  - 确保 `require('qt-assistant')` 正确加载主模块
  - 彻底解决 "attempt to call field 'setup' (a nil value)" 错误

### ⚠️ 配置变更说明 / Configuration Changes
- **推荐配置方式**: 继续使用 `require('qt-assistant').setup({})` 进行配置
- **配置选项**: 所有配置选项保持不变，完全向后兼容
- **内部重构**: 虽然内部架构有重大变化，但用户配置接口保持稳定
- **故障排除**: 如果遇到 `setup` 函数不存在的错误，请确保：
  1. 插件已正确安装和加载
  2. 使用正确的模块路径：`require('qt-assistant').setup({})`
  3. 检查是否有语法错误或配置冲突

### 🚀 新增功能 / Added
- **类创建功能**: 支持创建多种类型的Qt类（主窗口、对话框、控件、模型、代理、线程、工具类）
- **项目管理系统**: 智能检测和管理Qt项目，支持CMake、qmake、Meson构建系统
- **UI设计师集成**: 与Qt Designer、Qt Creator无缝集成，支持UI文件预览和同步
- **构建管理系统**: 一键构建、运行、清理项目，支持并行构建和多种构建类型
- **智能文件管理**: 根据类类型自动组织文件结构，支持多种命名规范
- **代码模板系统**: 丰富的内置模板，支持变量替换和条件语句
- **项目脚本管理**: 自动生成构建、运行、调试、测试脚本
- **多系统支持**: 完整支持Windows、macOS、Linux三大平台
- **交互式界面**: 提供友好的用户界面进行各种操作
- **快捷键映射**: 丰富的快捷键组合提升开发效率

### 🌍 跨平台特性 / Cross-Platform Features
- **智能路径处理**: 自动适配不同系统的路径分隔符
- **平台特定脚本**: Windows生成.bat文件，Unix系统生成.sh文件
- **Qt工具检测**: 智能查找各系统中的Qt Designer、Qt Creator等工具
- **构建系统适配**: 自动适配不同系统的构建命令和可执行文件格式

### 📋 支持的类类型 / Supported Class Types
- `main_window` - 主窗口类 (QMainWindow)
- `dialog` - 对话框类 (QDialog)
- `widget` - 自定义控件类 (QWidget)
- `model` - 数据模型类 (QAbstractItemModel)
- `delegate` - 代理类 (QStyledItemDelegate)
- `thread` - 线程类 (QThread)
- `utility` - 工具类 (QObject)
- `singleton` - 单例类 (QObject)

### 🎹 快捷键映射 / Key Mappings
- `<leader>qc` - 打开Qt Assistant
- `<leader>qpo` - 打开项目
- `<leader>qb` - 构建项目
- `<leader>qr` - 运行项目
- `<leader>qud` - 打开Qt Designer
- 更多快捷键请参考README.md

### 🔧 构建系统支持 / Build System Support
- **CMake** - 完整支持，包括自动更新CMakeLists.txt
- **qmake** - 支持.pro文件项目
- **Meson** - 支持meson.build项目

### 📚 文档和帮助 / Documentation
- 详细的README.md文档
- 完整的配置选项说明
- 故障排除指南
- 使用示例和最佳实践

### 🛠️ 技术规格 / Technical Specifications
- **最低Neovim版本**: 0.8+
- **Lua版本**: 5.1+
- **支持平台**: Windows 10+, macOS 10.15+, Linux各主流发行版
- **依赖**: 无外部依赖，纯Lua实现

---

## 未来计划 / Future Plans

### [1.1.0] - 计划中
- [ ] 模板自定义功能增强
- [ ] 更多Qt类类型支持
- [ ] 项目模板扩展
- [ ] 性能优化
- [ ] 更多语言支持

### [1.2.0] - 计划中
- [ ] Git集成
- [ ] 代码生成增强
- [ ] 单元测试支持
- [ ] 文档生成

---

## 贡献者 / Contributors

感谢所有为这个项目做出贡献的开发者！

---

格式说明：
- 🚀 新增功能
- 🔧 改进
- 🐛 修复
- 📚 文档
- 🔒 安全
- ⚡ 性能
- 🌍 国际化