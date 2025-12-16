-- Example configuration for Qt Assistant Plugin
-- Copy this to your init.lua or put it in a separate file

-- Basic setup
require('qt-assistant').setup({
    -- Project settings
    project_root = vim.fn.getcwd(),
    
    -- Directory structure  
    directories = {
        source = "src",
        include = "include", 
        ui = "ui",
        resource = "resources"
    },
    
    -- Auto update CMakeLists.txt when adding files
    auto_update_cmake = true,
    
    -- Qt tools paths (will auto-detect if not specified)
    qt_tools = {
        designer_path = "designer",
        uic_path = "uic",
        qmake_path = "qmake", 
        cmake_path = "cmake",
        creator_path = "qtcreator"
    },
    
    -- Enable default keymaps
    enable_default_keymaps = true
})

-- Force LF line endings for CMake files to avoid CRLF warnings
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "CMakeLists.txt", "*.cmake" },
    callback = function()
        vim.opt_local.fileformat = "unix"
        vim.opt_local.fileformats = { "unix" }
    end,
})
