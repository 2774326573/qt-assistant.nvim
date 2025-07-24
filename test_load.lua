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
