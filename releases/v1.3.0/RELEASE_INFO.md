# Qt Assistant v1.3.0 Release Information

**发布日期**: 2025-07-27
**版本**: v1.3.0
**发布名称**: qt-assistant-v1.3.0

## 📦 发布文件

### 下载链接
- **TAR.GZ**: [qt-assistant-v1.3.0.tar.gz](qt-assistant-v1.3.0.tar.gz)
- **ZIP**: [qt-assistant-v1.3.0.zip](qt-assistant-v1.3.0.zip)

### 校验和 (SHA256)
```
60c0e4c0bdeaf2ec1e46af35a4371467ea2e986bc4bfea0b6ddb71db57746247  qt-assistant-v1.3.0.tar.gz
8ecad1409d564a2a263121247ca2ddb39802410aad7d81e6796bfc3d9586966d  qt-assistant-v1.3.0.zip
```

## 🚀 安装方法

### Lazy.nvim
```lua
{
    "onewu867/qt-assistant.nvim",
    version = "v1.3.0",
    config = function()
        require('qt-assistant').setup({})
    end
}
```

### Packer.nvim
```lua
use {
    'onewu867/qt-assistant.nvim',
    tag = 'v1.3.0',
    config = function()
        require('qt-assistant').setup({})
    end
}
```

### 手动安装
1. 下载 [qt-assistant-v1.3.0.tar.gz](qt-assistant-v1.3.0.tar.gz)
2. 解压到 Neovim 配置目录
3. 在 init.lua 中添加配置

## 📋 发布内容

### 核心文件
- `lua/` - 插件核心代码
- `plugin/` - 插件入口文件
- `doc/` - 帮助文档
- `examples/` - 配置示例
- `docs/` - 详细文档

### 文档
- `README.md` - 主要文档
- `CHANGELOG.md` - 变更日志
- `docs/RELEASE_NOTES_v1.3.0.md` - 发布说明
- `docs/WINDOWS_QT5_VS2017_GUIDE.md` - Windows Qt5 配置指南

## 🔗 相关链接

- [GitHub Repository](https://github.com/onewu867/qt-assistant.nvim)
- [发布说明](docs/RELEASE_NOTES_v1.3.0.md)
- [Windows Qt5 指南](docs/WINDOWS_QT5_VS2017_GUIDE.md)
- [问题反馈](https://github.com/onewu867/qt-assistant.nvim/issues)

---
*发布时间: Sun Jul 27 00:22:10 CST 2025*
