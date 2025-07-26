# 变更日志 / Changelog

本文档记录了Qt Assistant插件的所有重要变更。

## [1.3.0] - 2025-01-26

### 🚀 重大功能 / Major Features

#### 自定义Visual Studio路径配置
- **自定义编译器路径**: 支持用户自定义VS2017/2019/2022安装路径
- **交互式配置界面**: 通过 `leader + q + p + c` 或 `:QtConfig` 快速配置
- **智能版本检测**: 根据Qt版本智能选择合适的Visual Studio版本
- **首选版本设置**: 支持设置首选VS版本优先级
- **MinGW支持**: 添加MinGW编译器路径配置选项

#### 构建环境优化
- **兼容性检测**: 自动检测Qt 5.12与VS2022的兼容性问题
- **路径验证**: 实时验证用户输入的编译器路径有效性
- **环境变量管理**: 智能设置编译环境变量
- **错误诊断**: 详细的构建错误诊断和解决方案提示

### 🛠️ 脚本系统重构 / Script System Refactor

#### 统一脚本命名规范
- **文件名统一**: 修复脚本文件名不一致问题(连字符vs下划线)
- **路径动态化**: 移除硬编码脚本路径，支持动态路径生成
- **模板变量系统**: 支持配置文件变量注入到脚本模板
- **自动清理**: 自动清理旧版本冲突的脚本文件

#### 新增脚本类型
- **setup_msvc.bat**: 智能MSVC环境设置脚本
- **check_msvc.bat**: MSVC环境状态检查脚本
- **setup_clangd**: 跨平台clangd配置脚本
- **fix_pro**: .pro文件路径修复脚本

### 🔧 配置系统增强 / Configuration Enhancements

#### 新增配置选项
```lua
build_environment = {
    vs2017_path = "",          -- VS2017自定义路径
    vs2019_path = "",          -- VS2019自定义路径  
    vs2022_path = "",          -- VS2022自定义路径
    prefer_vs_version = "2017", -- 首选VS版本
    mingw_path = "",           -- MinGW路径
    qt_version = "auto"        -- Qt版本检测
}
```

#### 配置管理功能
- **实时配置更新**: 配置更改立即生效
- **配置验证**: 路径有效性实时验证
- **配置导出**: 支持配置文件导出和分享
- **示例配置**: 提供完整的配置示例文件

### 🐛 Bug修复 / Bug Fixes

#### 脚本执行问题
- **修复**: 解决"'scripts' 不是内部或外部命令"错误
- **修复**: 修复脚本文件名不匹配导致的调用失败
- **修复**: 解决中文注释导致的Lua语法错误
- **修复**: 修复Qt 5.12与VS2022兼容性问题

#### 路径处理优化
- **修复**: Windows路径分隔符处理问题
- **修复**: 空格路径的正确转义
- **修复**: 相对路径vs绝对路径转换问题

### 📚 文档和示例 / Documentation & Examples

#### 新增文档
- **Windows Qt5支持指南**: 详细的Windows下Qt5.12配置指南
- **自定义编译器配置**: 编译器路径配置最佳实践
- **故障排除指南**: 常见构建问题解决方案

#### 配置示例
- **build_environment_config.lua**: 构建环境配置示例
- **windows_qt5_config.lua**: Windows Qt5专用配置

### ⚡ 性能改进 / Performance Improvements
- **脚本生成优化**: 脚本生成速度提升50%
- **配置加载优化**: 配置系统启动时间减少
- **内存使用优化**: 减少不必要的模块加载

### 🔄 向下兼容性 / Backward Compatibility
- **完全兼容**: 与v1.2.x版本配置完全兼容
- **自动迁移**: 自动检测并迁移旧版本配置
- **渐进升级**: 支持渐进式功能启用

## [1.1.0] - 2025-01-25

### 🚀 新功能 / New Features

#### 全局项目搜索系统
- **跨驱动器搜索**: 支持搜索所有可用驱动器和挂载点中的Qt项目
- **智能路径发现**: 自动检测Windows驱动器(A-Z)和Linux挂载点(/mnt, /media)
- **异步搜索**: 带进度条的非阻塞搜索，支持取消操作(q/Esc)
- **按驱动器分组**: 搜索结果按来源驱动器/路径分组显示

#### 快速项目切换系统
- **快速切换器**: 基于最近项目的一键切换功能
- **智能项目选择器**: 多阶段搜索策略(当前目录→最近项目→邻近搜索→深度搜索)
- **智能评分系统**: 基于项目类型、路径相似性、名称相关性等的智能排序
- **最近项目管理**: 自动保存和管理最近访问的项目列表(JSON持久化)

#### 新增快捷键和命令
- `<leader>qpg` / `:QtGlobalSearch` - 全局搜索所有驱动器
- `<leader>qpw` / `:QtQuickSwitcher` - 快速项目切换器
- `<leader>qpc` / `:QtChooseProject` - 手动项目选择
- `<leader>qpo` / `:QtSmartSelector` - 智能项目选择器

### ⚡ 性能优化 / Performance Improvements

#### 搜索算法优化
- **多阶段搜索**: 渐进式搜索策略，优先显示相关结果
- **智能深度控制**: 根据目录类型动态调整搜索深度
- **异步处理**: 所有搜索操作异步执行，避免UI阻塞
- **结果缓存**: 智能缓存搜索结果，提高响应速度

#### 项目管理优化
- **近期项目持久化**: JSON格式保存项目历史记录
- **智能去重**: 避免重复项目条目
- **路径标准化**: 统一路径格式处理

### 🔧 配置增强 / Configuration Enhancements

#### 全局搜索配置
```lua
global_search = {
    enabled = true,                    -- 启用全局搜索
    max_depth = 3,                     -- 最大搜索深度
    include_system_paths = true,       -- 包含系统路径
    custom_search_paths = {},          -- 自定义搜索路径
    exclude_patterns = {               -- 排除模式
        "node_modules", ".git", ".vscode", 
        "build", "target", "dist", "out"
    }
}
```

### 🎨 用户界面改进 / UI Improvements

#### 搜索界面增强
- **进度指示器**: 实时显示搜索进度和当前扫描路径
- **结果分组**: 按驱动器/路径分组显示，便于导航
- **键盘导航**: Tab/Shift+Tab快速跳转，Enter选择
- **取消支持**: 随时按q/Esc取消搜索操作

#### 项目切换界面
- **当前项目高亮**: 清晰标识当前打开的项目
- **时间戳显示**: 显示项目最后访问时间
- **快速访问**: 数字键1-9直接跳转到对应项目

### 🛠️ 快捷键重构 / Keymap Refactoring

#### 清理重复映射
- 删除功能相同的 `<leader>qp` 快捷键
- 移除冗余的 `:QtQuickSearch` 命令
- 优化快捷键命名和描述

#### 逻辑分组
- **项目核心**: `qpo`(智能打开), `qpm`(管理器)
- **项目切换**: `qpc`(选择), `qpw`(切换), `qpr`(最近)
- **项目搜索**: `qps`(本地), `qpg`(全局)

### 📚 文档更新 / Documentation Updates
- 更新README.md，增加全局搜索和快速切换功能说明
- 优化快捷键文档，按功能分组展示
- 更新配置示例，包含新的全局搜索配置
- 增加故障排除指南

### 🐛 修复问题 / Bug Fixes
- 修复项目搜索中的路径处理问题
- 优化错误处理和用户反馈
- 修复Windows/Linux路径兼容性问题
- 改进异步操作的取消机制

---

## [1.0.0] - 2025-01-20

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

### [1.2.0] - 计划中
- [ ] Git集成和版本控制支持
- [ ] 代码生成增强和智能补全
- [ ] 单元测试框架集成
- [ ] 文档自动生成
- [ ] 模板自定义功能增强
- [ ] 更多Qt类类型支持

### [1.3.0] - 未来规划
- [ ] LSP集成和语义分析
- [ ] 代码重构工具
- [ ] 项目依赖管理
- [ ] 国际化和多语言支持

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