#\!/bin/bash
# Qt Assistant 发布脚本

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION_FILE="$PROJECT_DIR/VERSION"

echo "=== Qt Assistant Release Script ==="

# 检查版本文件
if [ \! -f "$VERSION_FILE" ]; then
    echo "Error: VERSION file not found"
    exit 1
fi

VERSION=$(cat "$VERSION_FILE")
echo "Current version: $VERSION"

# 验证插件结构
echo "Validating plugin structure..."

# 检查必需文件
required_files="README.md CHANGELOG.md VERSION lua/qt-assistant.lua plugin/qt-assistant.lua doc/qt-assistant.txt"

for file in $required_files; do
    if [ ! -f "$PROJECT_DIR/$file" ]; then
        echo "Error: Required file missing: $file"
        exit 1
    fi
done

# 检查Lua文件语法
echo "Checking Lua syntax..."
find "$PROJECT_DIR/lua" -name "*.lua" -exec luac -p {} \; 2>/dev/null || {
    echo "Warning: Lua syntax check skipped (luac not found)"
}

# 创建发布包
RELEASE_DIR="$PROJECT_DIR/release"
PACKAGE_NAME="qt-assistant.nvim-v$VERSION"
PACKAGE_DIR="$RELEASE_DIR/$PACKAGE_NAME"

echo "Creating release package..."
rm -rf "$RELEASE_DIR"
mkdir -p "$PACKAGE_DIR"

# 复制文件
cp -r "$PROJECT_DIR/lua" "$PACKAGE_DIR/"
cp -r "$PROJECT_DIR/plugin" "$PACKAGE_DIR/"
cp -r "$PROJECT_DIR/doc" "$PACKAGE_DIR/"
cp "$PROJECT_DIR/README.md" "$PACKAGE_DIR/"
cp "$PROJECT_DIR/CHANGELOG.md" "$PACKAGE_DIR/"
cp "$PROJECT_DIR/VERSION" "$PACKAGE_DIR/"
cp "$PROJECT_DIR/LICENSE" "$PACKAGE_DIR/" 2>/dev/null || echo "LICENSE file not found, skipping..."

# 创建压缩包
cd "$RELEASE_DIR"
tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME"
zip -r "$PACKAGE_NAME.zip" "$PACKAGE_NAME"

echo "Release package created:"
echo "  - $RELEASE_DIR/$PACKAGE_NAME.tar.gz"
echo "  - $RELEASE_DIR/$PACKAGE_NAME.zip"

# 生成校验和
sha256sum "$PACKAGE_NAME.tar.gz" > "$PACKAGE_NAME.tar.gz.sha256"
sha256sum "$PACKAGE_NAME.zip" > "$PACKAGE_NAME.zip.sha256"

echo "Checksums generated"

# 显示发布信息
echo ""
echo "=== Release Information ==="
echo "Version: $VERSION"
echo "Package: $PACKAGE_NAME"
echo "Files included:"
find "$PACKAGE_DIR" -type f | sed 's|'"$PACKAGE_DIR"'||' | sort

echo ""
echo "=== Next Steps ==="
echo "1. Test the plugin package"
echo "2. Create Git tag: git tag -a v$VERSION -m 'Release v$VERSION'"
echo "3. Push tag: git push origin v$VERSION"
echo "4. Create GitHub release with the generated packages"
echo "5. Update plugin managers (if applicable)"

echo ""
echo "Release preparation completed successfully\!"
EOF < /dev/null