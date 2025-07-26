# Windows Qt5 支持文档

neovim-qt-assistant 插件现已完全支持 Windows 下的 Qt5 开发。

## 主要特性

### 1. 自动版本检测
- 自动检测项目中使用的 Qt 版本（Qt5 或 Qt6）
- 支持从 CMakeLists.txt 中识别 Qt 版本
- 自动扫描 Windows 常见 Qt 安装路径

### 2. Qt5 专用模板
- Qt5 兼容的头文件模板（使用传统的 `namespace Ui` 声明）
- Qt5 专用的 CMake 配置模板
- 支持 Qt5 的构建系统配置
- Windows 特定的 DLL 部署支持

### 3. Windows 环境自动配置
- 自动设置 Qt5 环境变量
- 支持多种编译器工具链（MSVC、MinGW）
- 自动配置 PATH 和 Qt 相关环境变量

## 配置说明

### 基本配置

```lua
require('qt-assistant').setup({
    qt_project = {
        version = "Qt5", -- 强制使用 Qt5，也可以设置为 "auto"
        qt5_path = "C:\\Qt\\5.15.2", -- Qt5 安装路径
        qt6_path = "C:\\Qt\\6.2.0",   -- 如果同时安装了 Qt6
        auto_detect = true,
        build_type = "Debug",
        cmake_minimum_version = "3.5", -- Qt5 兼容
        cxx_standard = "14", -- Qt5 兼容
    },
    
    -- Windows 特定配置
    global_search = {
        custom_search_paths = {
            "C:\\Projects",
            "D:\\Dev",
        },
    },
    
    designer = {
        designer_path = "designer.exe",
        creator_path = "qtcreator.exe",
    },
})
```

### 自动检测配置

```lua
require('qt-assistant').setup({
    qt_project = {
        version = "auto", -- 自动检测版本
        auto_detect = true,
    },
})
```

## 支持的 Qt5 模板

### 1. Qt5 主窗口模板
- 使用 `namespace Ui { class ClassName; }` 声明
- 兼容 Qt5 的信号槽连接方式
- 支持传统的 Qt5 构建方式

### 2. Qt5 对话框模板
- Qt5 兼容的对话框基类
- 传统的 accept/reject 处理方式
- 支持 Qt5 的模态对话框

### 3. Qt5 CMake 模板
- 使用 `find_package(Qt5)` 
- 设置 `CMAKE_AUTOMOC ON` 等自动化选项
- 支持 Qt5 的模块链接方式
- Windows 特定的 windeployqt 集成

## 使用方法

### 1. 检测 Qt 版本

```vim
:QtVersionInfo     " 显示详细的 Qt 版本信息
:QtDetectVersion   " 快速检测当前项目的 Qt 版本
```

或使用快捷键：
- `<leader>qvi` - 显示 Qt 版本信息
- `<leader>qvd` - 检测 Qt 版本

### 2. 创建 Qt5 类

插件会自动根据检测到的 Qt 版本选择合适的模板：

```vim
:QtCreateMainWindow MyWindow
:QtCreateDialog MyDialog
:QtCreateWidget MyWidget
```

### 3. 构建 Qt5 项目

```vim
:QtBuildProject    " 自动检测 Qt 版本并构建
:QtRunProject      " 运行项目
:QtCleanProject    " 清理项目
```

或使用快捷键：
- `<leader>qb` - 构建项目
- `<leader>qr` - 运行项目
- `<leader>qcl` - 清理项目

## Windows 特定功能

### 1. 自动 DLL 部署
Qt5 CMake 模板包含自动 DLL 部署功能：

```cmake
# 自动复制 Qt5 DLL 到输出目录
if(WIN32)
    add_custom_command(TARGET ProjectName POST_BUILD
        COMMAND ${QT5_WINDEPLOYQT_EXECUTABLE} $<TARGET_FILE:ProjectName>
        COMMENT "Deploying Qt5 libraries")
endif()
```

### 2. 多编译器支持
自动检测并支持以下编译器工具链：
- MSVC 2019/2017/2015
- MinGW 8.1/7.3

### 3. 环境变量自动设置
插件会自动设置以下环境变量：
- `PATH` - 添加 Qt5 bin 目录
- `QTDIR` - Qt5 安装目录
- `Qt5_DIR` - Qt5 CMake 配置目录

## 故障排除

### 1. Qt5 未检测到
检查 Qt5 是否安装在标准路径：
- `C:\Qt\5.15.2`
- `C:\Program Files\Qt`
- `C:\Program Files (x86)\Qt`

或手动设置路径：
```lua
qt_project = {
    qt5_path = "D:\\Qt\\5.15.2", -- 自定义路径
}
```

### 2. 构建失败
确保已安装：
- CMake (3.5+)
- 适当的编译器 (MSVC 或 MinGW)
- Qt5 开发库

### 3. Designer 无法打开
检查 designer.exe 路径：
```lua
designer = {
    designer_path = "C:\\Qt\\5.15.2\\msvc2019_64\\bin\\designer.exe",
}
```

## 示例配置

参考 `examples/windows_qt5_config.lua` 文件获取完整的 Windows Qt5 配置示例。

## 版本兼容性

- **Qt5**: 5.12+ (推荐 5.15.2)
- **Qt6**: 6.2+ (同时支持)
- **CMake**: 3.5+ (Qt5), 3.16+ (Qt6)
- **C++ 标准**: C++14 (Qt5), C++17 (Qt6)

## 更新日志

### v1.2.0
- 添加完整的 Windows Qt5 支持
- 自动版本检测功能
- Qt5 专用模板系统
- Windows 环境自动配置
- 多编译器工具链支持