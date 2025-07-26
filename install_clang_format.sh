#!/bin/bash
echo "Installing clang-format..."

# 检查是否已安装
if command -v clang-format >/dev/null 2>&1; then
    echo "clang-format is already installed: $(clang-format --version)"
    exit 0
fi

# 尝试使用包管理器安装
if command -v apt >/dev/null 2>&1; then
    echo "Using apt to install clang-format..."
    sudo apt update && sudo apt install -y clang-format
elif command -v dnf >/dev/null 2>&1; then
    echo "Using dnf to install clang-format..."
    sudo dnf install -y clang-tools-extra
elif command -v yum >/dev/null 2>&1; then
    echo "Using yum to install clang-format..."
    sudo yum install -y clang-tools-extra
else
    echo "No supported package manager found."
    echo "Please install clang-format manually:"
    echo "  Ubuntu/Debian: sudo apt install clang-format"
    echo "  CentOS/RHEL/Fedora: sudo dnf install clang-tools-extra"
    exit 1
fi

# 验证安装
if command -v clang-format >/dev/null 2>&1; then
    echo "✅ clang-format installed successfully: $(clang-format --version)"
else
    echo "❌ Failed to install clang-format"
    exit 1
fi