# Qt Assistant 代码格式化设置指南

## 问题诊断

如果保存C++文件时没有自动格式化，请按以下步骤排查：

### 1. 检查格式化工具是否已安装

```bash
# 检查clang-format是否已安装
which clang-format

# 如果没有输出，说明未安装
```

### 2. 安装clang-format

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install clang-format
```

#### CentOS/RHEL/Fedora
```bash
sudo dnf install clang-tools-extra
```

#### macOS
```bash
brew install clang-format
```

#### Windows
```bash
winget install LLVM.LLVM
```

### 3. 验证安装
```bash
clang-format --version
```

### 4. 在Neovim中测试格式化功能

打开一个C++文件，运行：
```vim
:QtFormatterStatus
```

这会显示格式化工具的状态。

### 5. 手动测试格式化

```vim
:QtFormatFile
```

## 配置选项

### 启用自动格式化（默认已启用）
```lua
require('qt-assistant').setup({
    auto_format = {
        enabled = true,
        formatter = "clang_format",
        on_save = true,
    },
})
```

### 禁用自动格式化
```lua
require('qt-assistant').setup({
    auto_format = {
        enabled = false,
    },
})
```

### 创建项目特定的格式化配置
```vim
:QtCreateClangFormat
```

这会在项目根目录创建`.clang-format`配置文件。

## 常见问题

### Q: 为什么保存时没有格式化？
A: 
1. 确保clang-format已安装
2. 确保文件类型是C++（.cpp, .h, .hpp等）
3. 确保auto_format.enabled = true

### Q: 如何查看格式化错误？
A: 运行`:QtFormatterStatus`查看详细状态

### Q: 如何使用astyle代替clang-format？
A: 
```lua
require('qt-assistant').setup({
    auto_format = {
        formatter = "astyle",
    },
})
```

## 手动安装clang-format（如果apt被阻止）

1. 下载预编译二进制文件：
```bash
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.1/clang+llvm-17.0.1-x86_64-linux-gnu-ubuntu-22.04.tar.xz
tar xf clang+llvm-17.0.1-x86_64-linux-gnu-ubuntu-22.04.tar.xz
cp clang+llvm-17.0.1-x86_64-linux-gnu-ubuntu-22.04/bin/clang-format ~/.local/bin/
```

2. 确保~/.local/bin在PATH中：
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```