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
    auto_rebuild_on_cmake_change = false,
    
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

-- Optional: Custom keymaps
-- vim.keymap.set('n', '<leader>qt', '<cmd>QtAssistant<cr>', { desc = 'Open Qt Assistant' })
-- vim.keymap.set('n', '<leader>qd', '<cmd>QtDesigner<cr>', { desc = 'Open Qt Designer' })
-- vim.keymap.set('n', '<leader>qb', '<cmd>QtBuild<cr>', { desc = 'Build Qt Project' })
-- vim.keymap.set('n', '<leader>qr', '<cmd>QtRun<cr>', { desc = 'Run Qt Project' })