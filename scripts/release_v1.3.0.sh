#!/bin/bash
# Qt Assistant v1.3.0 Release Script
# 发布脚本 - 自动化版本发布流程

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 版本信息
VERSION="1.3.0"
RELEASE_DATE=$(date +"%Y-%m-%d")
RELEASE_NAME="qt-assistant-v${VERSION}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Qt Assistant v${VERSION} Release Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 获取脚本所在目录的上级目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo -e "${YELLOW}项目根目录: ${PROJECT_ROOT}${NC}"
echo ""

# 检查是否在正确的目录
if [ ! -f "${PROJECT_ROOT}/VERSION" ]; then
    echo -e "${RED}错误: 找不到 VERSION 文件，请确保在项目根目录运行此脚本${NC}"
    exit 1
fi

# 验证版本号
CURRENT_VERSION=$(cat "${PROJECT_ROOT}/VERSION")
if [ "$CURRENT_VERSION" != "$VERSION" ]; then
    echo -e "${RED}错误: VERSION 文件中的版本号 ($CURRENT_VERSION) 与期望版本 ($VERSION) 不匹配${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 版本验证通过: v${VERSION}${NC}"

# 创建发布目录
RELEASE_DIR="${PROJECT_ROOT}/releases/v${VERSION}"
mkdir -p "${RELEASE_DIR}"

echo -e "${YELLOW}创建发布目录: ${RELEASE_DIR}${NC}"

# 复制核心文件到发布目录
echo -e "${YELLOW}复制核心文件...${NC}"

# 创建发布包结构
PACKAGE_DIR="${RELEASE_DIR}/${RELEASE_NAME}"
mkdir -p "${PACKAGE_DIR}"

# 复制必要文件
cp "${PROJECT_ROOT}/README.md" "${PACKAGE_DIR}/"
cp "${PROJECT_ROOT}/CHANGELOG.md" "${PACKAGE_DIR}/"
cp "${PROJECT_ROOT}/LICENSE" "${PACKAGE_DIR}/"
cp "${PROJECT_ROOT}/VERSION" "${PACKAGE_DIR}/"

# 复制代码目录
cp -r "${PROJECT_ROOT}/lua" "${PACKAGE_DIR}/"
cp -r "${PROJECT_ROOT}/plugin" "${PACKAGE_DIR}/"
cp -r "${PROJECT_ROOT}/doc" "${PACKAGE_DIR}/"

# 复制示例文件
mkdir -p "${PACKAGE_DIR}/examples"
cp -r "${PROJECT_ROOT}/examples/"* "${PACKAGE_DIR}/examples/"

# 复制文档
mkdir -p "${PACKAGE_DIR}/docs"
cp -r "${PROJECT_ROOT}/docs/"* "${PACKAGE_DIR}/docs/"

echo -e "${GREEN}✓ 文件复制完成${NC}"

# 创建压缩包
echo -e "${YELLOW}创建压缩包...${NC}"

cd "${RELEASE_DIR}"

# 创建 .tar.gz 压缩包
tar -czf "${RELEASE_NAME}.tar.gz" "${RELEASE_NAME}"
echo -e "${GREEN}✓ 创建了 ${RELEASE_NAME}.tar.gz${NC}"

# 创建 .zip 压缩包
zip -r "${RELEASE_NAME}.zip" "${RELEASE_NAME}" > /dev/null
echo -e "${GREEN}✓ 创建了 ${RELEASE_NAME}.zip${NC}"

# 计算校验和
echo -e "${YELLOW}计算校验和...${NC}"

# SHA256 校验
sha256sum "${RELEASE_NAME}.tar.gz" > "${RELEASE_NAME}.tar.gz.sha256"
sha256sum "${RELEASE_NAME}.zip" > "${RELEASE_NAME}.zip.sha256"

echo -e "${GREEN}✓ 校验和计算完成${NC}"

# 生成发布信息文件
echo -e "${YELLOW}生成发布信息...${NC}"

cat > "${RELEASE_DIR}/RELEASE_INFO.md" << EOF
# Qt Assistant v${VERSION} Release Information

**发布日期**: ${RELEASE_DATE}
**版本**: v${VERSION}
**发布名称**: ${RELEASE_NAME}

## 📦 发布文件

### 下载链接
- **TAR.GZ**: [${RELEASE_NAME}.tar.gz](${RELEASE_NAME}.tar.gz)
- **ZIP**: [${RELEASE_NAME}.zip](${RELEASE_NAME}.zip)

### 校验和 (SHA256)
\`\`\`
$(cat "${RELEASE_NAME}.tar.gz.sha256")
$(cat "${RELEASE_NAME}.zip.sha256")
\`\`\`

## 🚀 安装方法

### Lazy.nvim
\`\`\`lua
{
    "onewu867/qt-assistant.nvim",
    version = "v${VERSION}",
    config = function()
        require('qt-assistant').setup({})
    end
}
\`\`\`

### Packer.nvim
\`\`\`lua
use {
    'onewu867/qt-assistant.nvim',
    tag = 'v${VERSION}',
    config = function()
        require('qt-assistant').setup({})
    end
}
\`\`\`

### 手动安装
1. 下载 [${RELEASE_NAME}.tar.gz](${RELEASE_NAME}.tar.gz)
2. 解压到 Neovim 配置目录
3. 在 init.lua 中添加配置

## 📋 发布内容

### 核心文件
- \`lua/\` - 插件核心代码
- \`plugin/\` - 插件入口文件
- \`doc/\` - 帮助文档
- \`examples/\` - 配置示例
- \`docs/\` - 详细文档

### 文档
- \`README.md\` - 主要文档
- \`CHANGELOG.md\` - 变更日志
- \`docs/RELEASE_NOTES_v${VERSION}.md\` - 发布说明
- \`docs/WINDOWS_QT5_VS2017_GUIDE.md\` - Windows Qt5 配置指南

## 🔗 相关链接

- [GitHub Repository](https://github.com/onewu867/qt-assistant.nvim)
- [发布说明](docs/RELEASE_NOTES_v${VERSION}.md)
- [Windows Qt5 指南](docs/WINDOWS_QT5_VS2017_GUIDE.md)
- [问题反馈](https://github.com/onewu867/qt-assistant.nvim/issues)

---
*发布时间: $(date)*
EOF

echo -e "${GREEN}✓ 发布信息生成完成${NC}"

# 显示发布统计
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}           发布统计信息${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "${YELLOW}版本:${NC} v${VERSION}"
echo -e "${YELLOW}发布日期:${NC} ${RELEASE_DATE}"
echo -e "${YELLOW}发布目录:${NC} ${RELEASE_DIR}"

echo ""
echo -e "${YELLOW}发布文件:${NC}"
ls -la "${RELEASE_DIR}"/*.tar.gz "${RELEASE_DIR}"/*.zip 2>/dev/null | while read line; do
    echo -e "  ${GREEN}✓${NC} $line"
done

echo ""
echo -e "${YELLOW}文件大小:${NC}"
du -h "${RELEASE_DIR}"/*.tar.gz "${RELEASE_DIR}"/*.zip 2>/dev/null

echo ""
echo -e "${YELLOW}校验和文件:${NC}"
ls -la "${RELEASE_DIR}"/*.sha256 2>/dev/null | while read line; do
    echo -e "  ${GREEN}✓${NC} $line"
done

# 生成 Git 标签建议
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}            Git 发布建议${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "${YELLOW}建议执行以下 Git 命令完成发布:${NC}"
echo ""
echo -e "${GREEN}# 1. 提交所有更改${NC}"
echo "git add ."
echo "git commit -m \"Release v${VERSION}: Add custom VS path configuration\""
echo ""
echo -e "${GREEN}# 2. 创建标签${NC}"
echo "git tag -a v${VERSION} -m \"Release v${VERSION}\""
echo ""
echo -e "${GREEN}# 3. 推送到远程仓库${NC}"
echo "git push origin main"
echo "git push origin v${VERSION}"
echo ""
echo -e "${GREEN}# 4. 创建 GitHub Release${NC}"
echo "gh release create v${VERSION} \\"
echo "  releases/v${VERSION}/${RELEASE_NAME}.tar.gz \\"
echo "  releases/v${VERSION}/${RELEASE_NAME}.zip \\"
echo "  --title \"Qt Assistant v${VERSION}\" \\"
echo "  --notes-file docs/RELEASE_NOTES_v${VERSION}.md"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}    🎉 v${VERSION} 发布准备完成! 🎉${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}下一步:${NC}"
echo -e "1. 检查发布文件: ${RELEASE_DIR}"
echo -e "2. 验证压缩包内容"
echo -e "3. 执行上述 Git 命令"
echo -e "4. 在 GitHub 上创建 Release"
echo ""
echo -e "${GREEN}发布脚本执行完成! ✨${NC}"