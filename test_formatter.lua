-- 测试格式化功能的脚本
print("Testing Qt Assistant Formatter...")

-- 添加当前路径到package.path
package.path = package.path .. ";/home/one_wu/neovim-qt-assistant/lua/?.lua"

-- 尝试加载formatter模块
local ok, formatter = pcall(require, "qt-assistant.formatter")
if not ok then
    print("❌ Failed to load formatter module:", formatter)
    return
end

print("✅ Formatter module loaded successfully")

-- 测试检测可用格式化工具
local available = formatter.detect_available_formatters()
print("Available formatters:", #available)
for i, fmt in ipairs(available) do
    print("  " .. i .. ". " .. fmt.formatter.name)
end

if #available == 0 then
    print("❌ No formatters available")
    print("💡 Install clang-format: sudo apt install clang-format")
else
    print("✅ Formatters are available")
end