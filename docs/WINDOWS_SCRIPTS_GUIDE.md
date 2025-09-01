# Qt Assistant Windows Scripts Guide

## 概述

Qt Assistant 为 Windows 用户提供了完整的开发脚本套件，支持多种 C++ 标准和 Visual Studio 版本。

## 生成的脚本文件

创建项目时会自动生成以下脚本：

### 1. `build.bat` - 构建脚本
**用法:**
```batch
build.bat [BuildType] [CxxStandard]
```

**示例:**
```batch
build.bat                    # 默认 Debug C++17
build.bat Debug             # Debug C++17  
build.bat Release           # Release C++17
build.bat Debug 11          # Debug C++11
build.bat Release 20        # Release C++20
```

**功能:**
- 自动检测 Visual Studio 版本 (VS2017/2019/2022)
- 支持 C++11/14/17/20/23 标准
- 智能错误处理和诊断信息

### 2. `run.bat` - 运行脚本
**用法:**
```batch
run.bat [BuildType]
```

**示例:**
```batch
run.bat          # 运行 Debug 版本
run.bat Debug    # 运行 Debug 版本
run.bat Release  # 运行 Release 版本
```

**功能:**
- 自动检测可执行文件位置
- 显示项目和 C++ 标准信息
- 错误提示和解决建议

### 3. `clean.bat` - 清理脚本
**用法:**
```batch
clean.bat
```

**功能:**
- 删除 build 目录
- 重置项目构建状态

### 4. `setup.bat` - 环境检测脚本
**用法:**
```batch
setup.bat
```

**功能:**
- 检测 CMake 安装
- 检测 Qt 安装 (Qt5/Qt6)
- 检测 Visual Studio 版本
- 检测 Git 安装
- 提供安装指导

### 5. `dev.bat` - 开发者菜单
**用法:**
```batch
dev.bat
```

**交互菜单选项:**
- `1` - 构建项目 (Debug)
- `2` - 构建项目 (Release)
- `3` - 运行项目 (Debug)
- `4` - 运行项目 (Release)
- `5` - 清理构建目录
- `6` - 打开 Qt Designer
- `7` - 在 Qt Creator 中打开项目
- `8` - 环境设置检测
- `9` - Visual Studio 环境设置
- `A` - **高级构建选项** (新增)
- `0` - 退出

### 6. `fix_msvc.bat` - MSVC 修复脚本
**用法:**
```batch
fix_msvc.bat
```

**功能:**
- 自动检测并使用可用的 VS 版本
- 修复 MSVC C++17 编译错误
- 清理并重新配置项目

## 高级构建选项 (dev.bat -> A)

新增的高级构建菜单提供：

### A.1 - 使用特定 C++ 标准构建
- 选择 C++11/14/17/20/23
- 选择 Debug/Release
- 自动调用 build.bat 并传递参数

### A.2 - 显示当前构建配置
- 显示当前 C++ 标准
- 显示 CMake 配置信息
- 显示 Qt 版本信息

### A.3 - 重新生成构建配置
- 选择新的 C++ 标准
- 清理并重新配置项目
- 适用于切换 C++ 标准

## C++ 标准支持

### C++11 (Qt5 兼容)
```batch
build.bat Debug 11
build.bat Release 11
```
- Qt5: 完全支持
- Qt6: 支持但缺少 C++17 特性
- MSVC: VS2015+ 良好支持

### C++14 (Qt5 兼容)
```batch
build.bat Debug 14
build.bat Release 14
```
- Qt5: 完全支持
- Qt6: 支持但缺少 C++17 特性
- MSVC: VS2017+ 良好支持

### C++17 (推荐)
```batch
build.bat Debug 17
build.bat Release 17
```
- Qt5: 完全支持
- Qt6: 最低要求
- MSVC: VS2017+ 完全支持

### C++20 (现代 C++)
```batch
build.bat Debug 20
build.bat Release 20
```
- Qt5: 有限支持
- Qt6: 良好支持
- MSVC: VS2022+ 良好支持

### C++23 (最新标准)
```batch
build.bat Debug 23
build.bat Release 23
```
- Qt6: 实验性支持
- MSVC: VS2022 17.5+ 部分支持

## Visual Studio 支持

脚本自动检测并支持：

### VS2017
- C++11/14/17 完全支持
- C++20/23 有限支持
- 自动使用 "Visual Studio 15 2017" 生成器

### VS2019
- C++11/14/17 完全支持
- C++20 良好支持
- 自动使用 "Visual Studio 16 2019" 生成器

### VS2022
- 所有 C++ 标准完全支持
- 自动使用 "Visual Studio 17 2022" 生成器

## 故障排除

### 构建失败
1. 运行 `setup.bat` 检查环境
2. 尝试 `fix_msvc.bat` 修复配置
3. 使用 `dev.bat -> 9` 设置 VS 环境

### C++ 标准不兼容
1. 使用 `dev.bat -> A -> 3` 重新配置
2. 选择兼容的 C++ 标准
3. 参考兼容性矩阵

### Qt 版本问题
- C++11/14: 使用 Qt5
- C++17+: 优先 Qt6，可用 Qt5
- C++20+: 推荐 Qt6

## 示例工作流程

### 创建新项目
```vim
" 在 Neovim 中
:QtNewProject MyApp widget_app 17    " C++17 项目
```

### 构建和运行
```batch
# 在项目目录中
build.bat Debug 17     # 构建 C++17 Debug 版本
run.bat Debug          # 运行 Debug 版本
```

### 切换 C++ 标准
```batch
# 方法 1: 直接构建
build.bat Debug 20     # 构建 C++20 版本

# 方法 2: 完全重新配置
dev.bat                # 选择 A -> 3，重新配置为 C++20
```

### 环境诊断
```batch
setup.bat              # 检查开发环境
fix_msvc.bat           # 修复 MSVC 问题
```

## VS Code 集成

自动生成的 VS Code 配置：

### `.vscode/launch.json`
- Qt Debug 配置
- Qt Release 配置
- 自动预构建任务

### `.vscode/tasks.json`
- Build Debug 任务
- Build Release 任务  
- Clean 任务

## 注意事项

1. **路径问题**: 避免中文路径和空格
2. **权限问题**: 以管理员身份运行可能需要的操作
3. **环境变量**: 确保 Qt、CMake、VS 工具在 PATH 中
4. **C++ 标准**: 选择与目标环境兼容的标准
5. **Qt 版本**: C++17+ 项目推荐使用 Qt6