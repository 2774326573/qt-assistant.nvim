#\!/bin/bash
# Qt Assistant 测试脚本

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Qt Assistant Test Script ==="

# 检查Lua文件语法
echo "Checking Lua syntax..."
find "$PROJECT_DIR/lua" -name "*.lua" | while read -r file; do
    echo "Checking: $file"
    if command -v luac >/dev/null 2>&1; then
        luac -p "$file" || {
            echo "Syntax error in: $file"
            exit 1
        }
    else
        echo "luac not found, skipping syntax check"
        break
    fi
done

# 检查必需文件
echo "Checking required files..."
required_files="README.md CHANGELOG.md VERSION lua/qt-assistant.lua plugin/qt-assistant.lua"

for file in $required_files; do
    if [ ! -f "$PROJECT_DIR/$file" ]; then
        echo "Error: Required file missing: $file"
        exit 1
    else
        echo "✓ $file"
    fi
done

# 检查模块加载
echo "Testing module loading..."
if command -v nvim >/dev/null 2>&1; then
    # 创建临时测试文件
    temp_test="$PROJECT_DIR/test_load.lua"
    cat > "$temp_test" << 'TESTEOF'
-- 测试模块加载
local function test_module_loading()
    local modules = {
        'qt-assistant',
        'qt-assistant.core',
        'qt-assistant.templates',
        'qt-assistant.file_manager',
        'qt-assistant.cmake',
        'qt-assistant.ui',
        'qt-assistant.project_manager',
        'qt-assistant.build_manager',
        'qt-assistant.designer',
        'qt-assistant.scripts',
        'qt-assistant.system'
    }
    
    for _, module in ipairs(modules) do
        local ok, result = pcall(require, module)
        if ok then
            print("✓ " .. module)
        else
            print("✗ " .. module .. ": " .. tostring(result))
            return false
        end
    end
    return true
end

if test_module_loading() then
    print("All modules loaded successfully\!")
    os.exit(0)
else
    print("Module loading failed\!")
    os.exit(1)
fi
TESTEOF

    # 运行测试
    if nvim --headless -c "luafile $temp_test" -c "qa\!" 2>/dev/null; then
        echo "✓ Module loading test passed"
    else
        echo "✗ Module loading test failed"
    fi
    
    # 清理
    rm -f "$temp_test"
else
    echo "Neovim not found, skipping module loading test"
fi

echo "All tests completed\!"
EOF < /dev/null