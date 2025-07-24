# Qt Assistant v1.0.0 - Neovim插件首次发布 🎉

一个功能丰富的Neovim插件，专为Qt/C++开发者设计，提供完整的Qt项目开发工具链。

## 🚀 主要特性

### ✨ 智能类创建系统
- **8种Qt类类型**：主窗口、对话框、控件、模型、代理、线程、工具类、自定义类
- **智能模板引擎**：支持变量替换和条件语句
- **自动文件管理**：根据类类型智能组织项目结构

### 🏗️ 项目管理系统  
- **多构建系统支持**：CMake、qmake、Meson
- **智能项目检测**：自动识别Qt项目配置
- **一键构建运行**：集成构建、清理、运行功能

### 🎨 UI设计师集成
- **Qt Designer集成**：无缝编辑.ui文件
- **Qt Creator支持**：项目文件同步
- **实时预览**：UI文件变更监控

### 🌍 跨平台支持
- **完整支持**：Windows、macOS、Linux
- **智能路径处理**：自动适配系统路径格式
- **平台特定脚本**：生成对应的执行脚本

### 💻 开发体验
- **交互式界面**：友好的用户操作界面
- **丰富快捷键**：提升开发效率
- **智能补全**：集成Qt API提示

## 📦 安装方式

### lazy.nvim
```lua
{
  "2774326573/qt-assistant.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("qt-assistant").setup({
      -- 您的配置
    })
  end,
}
```

### packer.nvim
```lua
use {
  "2774326573/qt-assistant.nvim",
  requires = { "nvim-lua/plenary.nvim" },
  config = function()
    require("qt-assistant").setup()
  end
}
```

### 手动安装
```bash
# 下载发布包
wget https://github.com/2774326573/qt-assistant.nvim/releases/download/v1.0.0/qt-assistant.nvim-v1.0.0.tar.gz

# 解压到Neovim配置目录
tar -xzf qt-assistant.nvim-v1.0.0.tar.gz -C ~/.config/nvim/
```

## 🔧 基础配置

```lua
require("qt-assistant").setup({
  -- 类创建配置
  class_creation = {
    namespace_style = "nested",    -- "nested" 或 "prefix"
    include_guards = true,         -- 是否使用include guards
    copyright_header = true,       -- 是否添加版权声明
  },
  
  -- 构建配置
  build = {
    cmake_generator = "Unix Makefiles",
    parallel_jobs = 4,
    build_type = "Debug",
  },
  
  -- UI集成
  designer = {
    qt_designer_cmd = "designer",
    qt_creator_cmd = "qtcreator",
    auto_open = true,
  },
  
  -- 快捷键配置
  keymaps = {
    create_class = "<leader>qc",
    build_project = "<leader>qb",
    run_project = "<leader>qr",
    open_designer = "<leader>qd",
  }
})
```

## 🎯 快速开始

1. **创建Qt类**：`:QtAssistant` 或 `<leader>qc`
2. **构建项目**：`:QtBuild` 或 `<leader>qb`  
3. **运行项目**：`:QtRun` 或 `<leader>qr`
4. **打开Designer**：`:QtDesigner` 或 `<leader>qd`

## 📚 文档

- [完整文档](https://github.com/2774326573/qt-assistant.nvim/blob/main/README.md)
- [贡献指南](https://github.com/2774326573/qt-assistant.nvim/blob/main/CONTRIBUTING.md)
- [Vim帮助](https://github.com/2774326573/qt-assistant.nvim/blob/main/doc/qt-assistant.txt)

## 🐛 问题反馈

如果您遇到问题或有功能建议，请：
- 提交 [GitHub Issues](https://github.com/2774326573/qt-assistant.nvim/issues)
- 参与 [GitHub Discussions](https://github.com/2774326573/qt-assistant.nvim/discussions)

## 🤝 贡献

欢迎贡献代码！请查看我们的[贡献指南](https://github.com/2774326573/qt-assistant.nvim/blob/main/CONTRIBUTING.md)。

## 📄 许可证

本项目采用 [MIT 许可证](https://github.com/2774326573/qt-assistant.nvim/blob/main/LICENSE)。

## 🙏 致谢

感谢所有为Qt和Neovim生态系统做出贡献的开发者！

---

**适用于Qt/C++开发者和Neovim用户** 💜
