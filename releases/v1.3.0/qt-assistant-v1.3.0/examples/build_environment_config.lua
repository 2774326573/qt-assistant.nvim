-- Qt Assistant Build Environment Configuration Example
-- Place this configuration in your Neovim init.lua or a separate config file

require('qt-assistant').setup({
    -- Build environment configuration
    build_environment = {
        -- Custom Visual Studio installation paths
        -- Leave empty ("") for auto-detection
        vs2017_path = "D:\\install\\visualStudio\\2017\\Community",  -- Your VS2017 path
        vs2019_path = "",  -- Auto-detect VS2019
        vs2022_path = "",  -- Auto-detect VS2022
        
        -- Preferred Visual Studio version: "2017", "2019", "2022"
        -- This affects which version is prioritized during auto-detection
        prefer_vs_version = "2017",  -- Recommended for Qt 5.12
        
        -- MinGW path (for alternative compilation)
        mingw_path = "",  -- Auto-detect MinGW
        
        -- Qt version detection: "auto", "5", "6"
        qt_version = "auto"
    },
    
    -- Other Qt Assistant configurations...
    project_root = vim.fn.getcwd(),
    directories = {
        source = "src",
        include = "include", 
        ui = "ui",
        resource = "resource",
        scripts = "scripts"
    },
    naming_convention = "snake_case",
    auto_update_cmake = true,
    enable_default_keymaps = true
})

-- Example usage after setup:
-- 1. Use :QtConfig to interactively configure build paths
-- 2. Use leader + q + p + c for quick configuration access
-- 3. Run :QtScripts to regenerate scripts with new settings
-- 4. Use leader + q + e + m to setup MSVC with custom paths