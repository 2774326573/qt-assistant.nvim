# 脚本模板更新文档

基于当前项目的脚本作为模板，neovim-qt-assistant 扩展的脚本功能已全面更新。

## 主要更新内容

### 1. 基于当前项目的脚本模板

**原始模板特点**：
- 简洁高效的错误处理（`|| exit 1`）
- 相对路径导航（`cd "$(dirname "$0")/.." || exit 1`）
- 智能可执行文件查找
- 并行编译支持（`-j $(nproc)`）

**新的脚本结构**：
- 所有脚本从项目根目录开始执行
- 统一的错误处理机制
- 自动项目名称检测和替换

### 2. 新增功能

#### 自动项目名称检测
```lua
-- 从 CMakeLists.txt 提取项目名称
local project_match = line:match("project%s*%(%s*([%w_%-]+)")

-- 从 .pro 文件获取项目名称
local pro_name = vim.fn.fnamemodify(pro_files[1], ":t:r")

-- 默认使用目录名称
return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
```

#### Qt版本自动检测
```lua
-- 从 CMakeLists.txt 检测
if line:match("find_package%s*%(%s*Qt6") then
    return 6
elseif line:match("find_package%s*%(%s*Qt5") then
    return 5
end
```

#### 智能构建系统检测
- CMake (`CMakeLists.txt`)
- qmake (`*.pro`)
- Make (`Makefile`)

### 3. 更新后的脚本模板

#### Unix/Linux 构建脚本
```bash
#!/bin/bash
echo "Building Qt project with CMake..."
cd "$(dirname "$0")/.." || exit 1
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Debug .. || exit 1
cmake --build . --config Debug -j $(nproc) || exit 1
echo "Build completed successfully!"
```

#### Unix/Linux 运行脚本
```bash
#!/bin/bash
echo "Running Qt project..."
cd "$(dirname "$0")/.." || exit 1
if [ ! -d "build" ]; then
  echo "Build directory not found! Please build first."
  exit 1
fi
cd build
if [ -x "./bin/{{PROJECT_NAME}}" ]; then
  echo "Running ./bin/{{PROJECT_NAME}}..."
  ./bin/{{PROJECT_NAME}}
elif [ -x "./{{PROJECT_NAME}}" ]; then
  echo "Running ./{{PROJECT_NAME}}..."
  ./{{PROJECT_NAME}}
else
  echo "Executable {{PROJECT_NAME}} not found!"
  exit 1
fi
```

#### Windows 部署脚本
```batch
@echo off
echo Deploying Qt{{QT_VERSION}} project...
if not exist "build" (
    echo Build directory not found! Please build first.
    pause
    exit /b 1
)
cd build
if not exist "deploy" mkdir deploy
for %%f in (*.exe) do (
    copy "%%f" deploy\
)
REM Use appropriate deployment tool based on Qt version
echo Using Qt{{QT_VERSION}} deployment tool...
windeployqt deploy\
echo Deployment completed!
pause
```

### 4. 新增命令

#### Vim 命令
- `:QtScriptGenerator` - 交互式脚本生成器
- `:QtGenerateAllScripts` - 快速生成所有脚本
- `:QtDetectBuildSystem` - 检测项目构建系统

#### 快捷键
**脚本执行**：
- `<leader>qsb` - 执行构建脚本
- `<leader>qsr` - 执行运行脚本
- `<leader>qsd` - 执行调试脚本
- `<leader>qsc` - 执行清理脚本
- `<leader>qst` - 执行测试脚本
- `<leader>qsp` - 执行部署脚本

**脚本管理**：
- `<leader>qsg` - 脚本生成器
- `<leader>qsa` - 生成所有脚本

### 5. 脚本类型支持

支持的脚本类型：
- **build** - 构建脚本
- **run** - 运行脚本
- **debug** - 调试脚本
- **clean** - 清理脚本
- **test** - 测试脚本
- **deploy** - 部署脚本

### 6. 跨平台兼容性

#### Unix/Linux/macOS
- Bash 脚本（`.sh`）
- 自动执行权限设置
- gdb/lldb 调试支持

#### Windows
- 批处理脚本（`.bat`）
- Visual Studio/MinGW 支持
- 自动 DLL 部署

### 7. 智能变量替换

模板支持的变量：
- `{{PROJECT_NAME}}` - 项目名称
- `{{QT_VERSION}}` - Qt版本号

### 8. 使用示例

#### 交互式生成所有脚本
```vim
:QtGenerateAllScripts
```
输出：
```
Generating scripts for cmake build system...
Generated: build.sh
Generated: run.sh
Generated: debug.sh
Generated: clean.sh
Generated: test.sh
Generated: deploy.sh
Generated 6 scripts
All scripts generated successfully in: /path/to/project/scripts
```

#### 生成单个脚本
```vim
:lua require('qt-assistant').generate_single_script('build')
```

#### 交互式脚本生成器
```vim
:QtScriptGenerator
```
显示菜单：
```
=== Script Generator ===

0. Generate All Scripts

1. Generate 构建脚本
2. Generate 运行脚本
3. Generate 调试脚本
4. Generate 清理脚本
5. Generate 测试脚本
6. Generate 部署脚本
```

### 9. 构建系统检测

#### 自动检测结果
```vim
:QtDetectBuildSystem
```
输出：
```
Detected build system: cmake
```

支持的构建系统：
- `cmake` - CMake 构建系统
- `qmake` - Qt qmake 构建系统
- `make` - 标准 Makefile
- `unknown` - 未知构建系统

### 10. 错误处理和健壮性

#### 目录安全检查
```bash
cd "$(dirname "$0")/.." || exit 1
```

#### 构建失败处理
```bash
cmake -DCMAKE_BUILD_TYPE=Debug .. || exit 1
cmake --build . --config Debug -j $(nproc) || exit 1
```

#### 可执行文件智能查找
```bash
if [ -x "./bin/{{PROJECT_NAME}}" ]; then
  echo "Running ./bin/{{PROJECT_NAME}}..."
  ./bin/{{PROJECT_NAME}}
elif [ -x "./{{PROJECT_NAME}}" ]; then
  echo "Running ./{{PROJECT_NAME}}..."
  ./{{PROJECT_NAME}}
else
  echo "Executable {{PROJECT_NAME}} not found!"
  exit 1
fi
```

### 11. Qt5/Qt6 兼容性

#### 版本检测
- 从 `CMakeLists.txt` 自动检测
- 与 qt-version 模块集成
- 默认 Qt6 支持

#### 版本特定功能
- Windows 部署工具选择
- 构建参数优化
- 模板内容适配

## 总结

更新后的脚本模板系统提供了：

✅ **基于实际项目的模板** - 从当前项目提取最佳实践  
✅ **智能检测** - 自动识别项目名称、Qt版本、构建系统  
✅ **跨平台支持** - Windows、Linux、macOS 完全兼容  
✅ **健壮的错误处理** - 失败时立即退出，避免连锁错误  
✅ **用户友好** - 交互式界面，快捷键支持  
✅ **高度自动化** - 一键生成所有必需脚本  

这些更新使得 neovim-qt-assistant 扩展的脚本功能更加实用和可靠，完全基于真实项目的最佳实践。